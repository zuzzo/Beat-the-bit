extends Control

var ADVENTURE_DIR := "res://assets/cards/ghost_n_goblins/adventure"
var BOSS_DIR := "res://assets/cards/ghost_n_goblins/boss"
var TREASURE_DIR := "res://assets/cards/ghost_n_goblins/treasure"
var SINGLE_DIR := "res://assets/cards/ghost_n_goblins/singles"

@onready var deck_option: OptionButton = $RootVBox/TopBar/DeckOption
@onready var filter_option: OptionButton = $RootVBox/EditorSplit/LeftPanel/FilterOption
@onready var card_list: ItemList = $RootVBox/EditorSplit/LeftPanel/CardList
@onready var preview_container: Control = $RootVBox/EditorSplit/RightPanel/PreviewContainer
@onready var preview: TextureRect = $RootVBox/EditorSplit/RightPanel/PreviewContainer/Preview
@onready var regno_overlay: Control = $RootVBox/EditorSplit/RightPanel/PreviewContainer/RegnoOverlay
@onready var details: Label = $RootVBox/EditorSplit/RightPanel/Details
@onready var regno_edit_toggle: Button = $RootVBox/EditorSplit/RightPanel/PreviewControls/RegnoEditToggle
@onready var regno_save_button: Button = $RootVBox/EditorSplit/RightPanel/PreviewControls/RegnoSave

var _cards: Array = []
var _display_cards: Array = []
var _adventure_index: Dictionary = {}
var _selected_card: Dictionary = {}
var _selected_entry: Dictionary = {}
var _regno_nodes: Array[Control] = []
var _regno_edit_mode: bool = false
var _regno_drag_index: int = -1
var _regno_drag_offset: Vector2 = Vector2.ZERO
var _regno_resizing: bool = false
var _regno_resize_start: Vector2 = Vector2.ZERO
var _regno_resize_mouse: Vector2 = Vector2.ZERO

const REGNO_ID := "shared_regno_del_male"
const REGNO_NODE_COUNT := 11

const EFFECT_DESCRIPTIONS := {
	"armor_extra_slot_1": "Aggiunge 1 slot equipaggiamento quando equipaggiata.",
	"armor_extra_slot_2": "Aggiunge 2 slot equipaggiamento quando equipaggiata.",
	"sacrifice_prevent_heart_loss": "Se sacrificata, previene una perdita di cuore.",
	"discard_revealed_adventure": "Scarta l'avventura rivelata.",
	"reroll_same_dice": "Rilancia i dadi selezionati.",
	"after_roll_minus_1_all_dice": "Dopo il lancio, -1 a tutti i dadi (min 1).",
	"after_roll_set_one_die_to_1": "Dopo il lancio, scegli un dado e impostalo a 1.",
	"reroll_5_or_6": "Rilancia i dadi con valore 5 o 6.",
	"halve_even_dice": "Dopo il lancio, dimezza i dadi pari.",
	"add_red_die": "Aggiunge un dado rosso.",
	"reflect_damage_poison": "Quando perdi un cuore, riflette danno/veleno.",
	"next_roll_minus_2_all_dice": "Nel prossimo lancio, -2 a tutti i dadi (min 1).",
	"lowest_die_applies_to_all": "Prima del lancio, il valore piu basso vale per tutti i dadi.",
	"deal_1_damage": "Infligge 1 danno immediato al nemico attivo.",
	"ignore_fatigue_if_all_different": "Se tutti i dadi sono diversi, ignori fatica.",
	"next_roll_double_then_remove_half": "Nel prossimo lancio, raddoppia i dadi e annulla la meta piu bassa.",
	"on_heart_loss_destroy_fatigue": "Quando perdi un cuore, rimuovi una fatica.",
	"regno_del_male_portal": "Avanza sul tracciato Regno del Male.",
	"sacrifice_open_portal": "Sacrifica per avanzare nel Regno del Male.",
	"bonus_damage_multiheart": "Dopo il danno, bonus contro nemici con piu cuori.",
	"reset_hearts_and_dice": "Ripristina cuori e dadi base.",
	"return_to_hand": "Ritorna in mano dopo l'uso.",
	"discard_hand_card_1": "Scarta 1 carta dalla mano."
}

const TIMING_DESCRIPTIONS := {
	"before_roll": "Prima del lancio",
	"after_roll": "Dopo il lancio",
	"before_adventure": "Prima di rivelare l'avventura",
	"on_heart_loss": "Quando perdi cuori",
	"equip": "Quando equipaggiata",
	"on_play": "Quando usata",
	"any_time": "In qualunque momento",
	"after_damage": "Dopo il danno",
	"next_roll": "Al prossimo lancio"
}

func _ready() -> void:
	_populate_deck_option()
	filter_option.add_item("Tesori", 0)
	filter_option.add_item("Avventure", 1)
	filter_option.add_item("Boss", 2)
	filter_option.add_item("Carte singole", 3)
	filter_option.selected = 0
	GameConfig.load_overrides()
	_apply_selected_deck_dirs()
	_load_cards()
	_build_adventure_index()
	_refresh_list()
	card_list.item_selected.connect(_on_card_selected)
	filter_option.item_selected.connect(_on_filter_changed)
	deck_option.item_selected.connect(_on_deck_changed)
	regno_edit_toggle.pressed.connect(_on_regno_edit_toggled)
	regno_save_button.pressed.connect(_on_regno_save_pressed)
	regno_overlay.visible = false
	regno_save_button.disabled = true
	regno_edit_toggle.disabled = true
	preview_container.resized.connect(_on_preview_resized)

func _on_start_pressed() -> void:
	var deck_id: String = _selected_deck_id()
	GameConfig.selected_deck_id = deck_id
	CardDatabase.load_cards(deck_id)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _populate_deck_option() -> void:
	deck_option.clear()
	var ids: Array[String] = DeckRegistry.list_deck_ids()
	var selected_index: int = 0
	for i in ids.size():
		var id: String = ids[i]
		deck_option.add_item(DeckRegistry.get_deck_label(id), i)
		deck_option.set_item_metadata(i, id)
		if id == GameConfig.selected_deck_id:
			selected_index = i
	deck_option.selected = selected_index

func _selected_deck_id() -> String:
	if deck_option.selected < 0:
		return DeckRegistry.DEFAULT_DECK_ID
	var meta: Variant = deck_option.get_item_metadata(deck_option.selected)
	var deck_id: String = str(meta)
	if deck_id.strip_edges().is_empty():
		return DeckRegistry.DEFAULT_DECK_ID
	return deck_id

func _apply_selected_deck_dirs() -> void:
	var deck: Dictionary = DeckRegistry.get_deck(_selected_deck_id())
	var dirs: Dictionary = deck.get("asset_dirs", {}) as Dictionary
	ADVENTURE_DIR = str(dirs.get("adventure", ADVENTURE_DIR))
	BOSS_DIR = str(dirs.get("boss", BOSS_DIR))
	TREASURE_DIR = str(dirs.get("treasure", TREASURE_DIR))
	SINGLE_DIR = str(dirs.get("single", SINGLE_DIR))

func _on_deck_changed(_index: int) -> void:
	_apply_selected_deck_dirs()
	_load_cards()
	_build_adventure_index()
	_refresh_list()

func _load_cards() -> void:
	_cards.clear()
	var cards_path: String = DeckRegistry.get_cards_path(_selected_deck_id())
	var set_id: String = DeckRegistry.get_card_set(_selected_deck_id())
	var file := FileAccess.open(cards_path, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		return
	for entry in parsed:
		if not (entry is Dictionary):
			continue
		var entry_set: String = str((entry as Dictionary).get("set", ""))
		if not entry_set.is_empty() and entry_set != set_id:
			continue
		_cards.append(entry)

func _build_adventure_index() -> void:
	_adventure_index.clear()
	var dir := DirAccess.open(ADVENTURE_DIR)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			var base := file_name.get_basename()
			var key := _normalize_name(base)
			key = _strip_variant_suffix(key)
			if not _adventure_index.has(key):
				_adventure_index[key] = []
			_adventure_index[key].append({
				"path": "%s/%s" % [ADVENTURE_DIR, file_name],
				"label": base
			})
		file_name = dir.get_next()
	dir.list_dir_end()

func _refresh_list() -> void:
	card_list.clear()
	_display_cards.clear()
	var filter_id := filter_option.selected
	for card in _cards:
		var category := _category_for(card)
		if not _filter_match(filter_id, category):
			continue
		var images := _get_card_images(card, category)
		if images.is_empty():
			_display_cards.append({"card": card, "image": "", "variant": ""})
		else:
			for img in images:
				_display_cards.append({"card": card, "image": img["path"], "variant": str(img.get("label", ""))})
	for entry in _display_cards:
		var card: Dictionary = entry["card"]
		var name := str(card.get("name", "Senza nome"))
		var variant := str(entry["variant"])
		var card_id := str(card.get("id", ""))
		if entry["image"] != "" and GameConfig.card_image_overrides.get(card_id, "") == entry["image"]:
			name = "%s [default]" % name
		if variant != "" and variant.to_lower() != name.to_lower():
			name = "%s (%s)" % [name, variant]
		var icon: Texture2D = null
		if entry["image"] != "":
			icon = load(entry["image"])
		card_list.add_item(name, icon)
	if card_list.item_count > 0:
		card_list.select(0)
		_on_card_selected(0)
	else:
		preview.texture = null
		details.text = ""

func _get_card_images(card: Dictionary, category: String) -> Array:
	var card_id := str(card.get("id", ""))
	var override_path := str(GameConfig.card_image_overrides.get(card_id, ""))
	if override_path != "":
		var out: Array = [{"path": override_path, "label": "default"}]
		if category == "adventure":
			var name := _normalize_name(str(card.get("name", "")))
			var key := _strip_variant_suffix(name)
			if _adventure_index.has(key):
				for img in _adventure_index[key]:
					if str(img.get("path", "")) != override_path:
						out.append(img)
		return out
	if card.has("image"):
		return [{"path": str(card["image"]), "label": ""}]
	var name := _normalize_name(str(card.get("name", "")))
	if category == "adventure":
		var key := _strip_variant_suffix(name)
		if _adventure_index.has(key):
			return _adventure_index[key]
	elif category == "boss":
		var path := _find_image_in_dir(BOSS_DIR, name)
		if path != "":
			return [{"path": path, "label": ""}]
	elif category == "treasure":
		var path_t := _find_image_in_dir(TREASURE_DIR, name)
		if path_t != "":
			return [{"path": path_t, "label": ""}]
	else:
		var path_s := _find_image_in_dir(SINGLE_DIR, name)
		if path_s != "":
			return [{"path": path_s, "label": ""}]
	return []

func _find_image_in_dir(dir_path: String, name_key: String) -> String:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ""
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			var base := _normalize_name(file_name.get_basename())
			if base == name_key:
				dir.list_dir_end()
				return "%s/%s" % [dir_path, file_name]
		file_name = dir.get_next()
	dir.list_dir_end()
	return ""

func _on_filter_changed(_index: int) -> void:
	_refresh_list()

func _on_card_selected(index: int) -> void:
	if index < 0 or index >= _display_cards.size():
		return
	var entry: Dictionary = _display_cards[index]
	var card: Dictionary = entry["card"]
	var img_path := str(entry["image"])
	_selected_card = card
	_selected_entry = entry
	if img_path != "":
		preview.texture = load(img_path)
	else:
		preview.texture = null
	details.text = _build_details(card)
	_update_regno_controls()
	

func _build_details(card: Dictionary) -> String:
	var lines: Array[String] = []
	var category: String = _category_for(card)
	lines.append("Nome: %s" % str(card.get("name", "")))
	lines.append("ID: %s" % str(card.get("id", "")))
	lines.append("Tipo: %s" % str(card.get("type", "")))
	if card.has("difficulty"):
		lines.append("Difficolta: %s" % str(card.get("difficulty")))
	if card.has("hearts"):
		lines.append("Cuori: %s" % str(card.get("hearts")))
	if card.has("cost"):
		lines.append("Costo: %s" % str(card.get("cost")))
	if card.has("effects"):
		lines.append("Effetti: %s" % ", ".join(card.get("effects", [])))
	if card.has("reward_brown"):
		lines.append("Reward brown: %s" % ", ".join(card.get("reward_brown", [])))
	if card.has("reward_silver"):
		lines.append("Reward silver: %s" % ", ".join(card.get("reward_silver", [])))
	if card.has("penalty_violet"):
		lines.append("Penalty violet: %s" % ", ".join(card.get("penalty_violet", [])))
	if card.has("timed_effects"):
		var entries: Array = []
		for item in card.get("timed_effects", []):
			if item is Dictionary:
				entries.append("%s: %s" % [str(item.get("when", "")), str(item.get("effect", ""))])
		if not entries.is_empty():
			lines.append("Effetti (timing): %s" % "; ".join(entries))
	if card.has("sacrifice_cost") or card.has("sacrifice_effect"):
		var cost := str(card.get("sacrifice_cost", ""))
		var effect := str(card.get("sacrifice_effect", ""))
		lines.append("Sacrifice: %s -> %s" % [cost, effect])
	if card.has("sacrifice_optional"):
		lines.append("Opzione: %s" % ", ".join(card.get("sacrifice_optional", [])))
	if category == "treasure":
		var understood: Array[String] = _describe_treasure_effects(card)
		if not understood.is_empty():
			lines.append("Effetto capito:")
			for entry in understood:
				lines.append("  - %s" % entry)
	return "\n".join(lines)

func _describe_treasure_effects(card: Dictionary) -> Array[String]:
	var out: Array[String] = []
	if card.has("timed_effects"):
		for item in card.get("timed_effects", []):
			if item is Dictionary:
				var eff: String = str(item.get("effect", ""))
				var when: String = str(item.get("when", ""))
				var eff_text: String = str(EFFECT_DESCRIPTIONS.get(eff, eff))
				var when_text: String = str(TIMING_DESCRIPTIONS.get(when, when))
				out.append("%s: %s" % [when_text, eff_text])
		return out
	if card.has("effects"):
		for eff in card.get("effects", []):
			var eff_name := str(eff)
			out.append(EFFECT_DESCRIPTIONS.get(eff_name, eff_name))
	return out

func _update_regno_controls() -> void:
	var is_regno := _is_regno_card(_selected_card)
	regno_edit_toggle.disabled = not is_regno
	regno_save_button.disabled = not (_regno_edit_mode and is_regno)
	if not is_regno:
		_set_regno_edit_mode(false)

func _is_regno_card(card: Dictionary) -> bool:
	return str(card.get("id", "")) == REGNO_ID

func _on_regno_edit_toggled() -> void:
	_set_regno_edit_mode(regno_edit_toggle.button_pressed)

func _set_regno_edit_mode(active: bool) -> void:
	_regno_edit_mode = active
	if not _regno_edit_mode:
		regno_overlay.visible = false
		regno_save_button.disabled = true
		_clear_regno_nodes()
		return
	if not _is_regno_card(_selected_card):
		regno_edit_toggle.button_pressed = false
		return
	if preview.texture == null:
		regno_edit_toggle.button_pressed = false
		return
	regno_overlay.visible = true
	regno_save_button.disabled = false
	_build_regno_nodes()

func _on_regno_save_pressed() -> void:
	if not _is_regno_card(_selected_card):
		return
	var nodes := _collect_regno_nodes_normalized()
	if nodes.is_empty():
		return
	_selected_card["track_nodes"] = nodes
	_save_cards()
	details.text = _build_details(_selected_card)

func _build_regno_nodes() -> void:
	_clear_regno_nodes()
	var stored: Array = _selected_card.get("track_nodes", [])
	var default_size: Vector2 = Vector2(40, 40)
	if preview.texture != null:
		var tex_size: Vector2 = preview.texture.get_size()
		var scale: float = min(preview.size.x / tex_size.x, preview.size.y / tex_size.y)
		var display: Vector2 = tex_size * scale
		var side: float = min(display.x, display.y) * 0.08
		if side < 24:
			side = 24
		default_size = Vector2(side, side)
	for i in REGNO_NODE_COUNT:
		var rect := _create_regno_node(i + 1)
		var pos := Vector2(10 + i * 6, 10 + i * 6)
		var size := default_size
		if stored is Array and i < stored.size() and stored[i] is Dictionary:
			var data: Dictionary = stored[i]
			var image_rect := _get_preview_image_rect()
			pos = image_rect.position + Vector2(float(data.get("x", 0.0)) * image_rect.size.x, float(data.get("y", 0.0)) * image_rect.size.y)
			var raw_size: Vector2 = Vector2(float(data.get("w", 0.0)) * image_rect.size.x, float(data.get("h", 0.0)) * image_rect.size.y)
			var side: float = max(raw_size.x, raw_size.y)
			size = Vector2(side, side)
		rect.position = pos
		rect.size = size
		regno_overlay.add_child(rect)
		_regno_nodes.append(rect)

func _clear_regno_nodes() -> void:
	for node in _regno_nodes:
		if node != null and node.is_inside_tree():
			node.queue_free()
	_regno_nodes.clear()

func _create_regno_node(index: int) -> Control:
	var panel := PanelContainer.new()
	panel.name = "RegnoNode_%d" % index
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.size = Vector2(40, 40)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color(1.0, 0.9, 0.2, 1.0)
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = str(index)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(label)
	panel.gui_input.connect(func(event: InputEvent) -> void:
		_on_regno_node_input(index - 1, event)
	)
	return panel

func _on_regno_node_input(index: int, event: InputEvent) -> void:
	if not _regno_edit_mode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_regno_drag_index = index
				_regno_drag_offset = event.position
			else:
				_regno_drag_index = -1
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_regno_resizing = true
				_regno_resize_start = _regno_nodes[index].size
				_regno_resize_mouse = event.position
			else:
				_regno_resizing = false
	elif event is InputEventMouseMotion:
		if _regno_drag_index == index and not _regno_resizing:
			var node := _regno_nodes[index]
			node.position += event.relative
		elif _regno_resizing:
			var delta: Vector2 = event.position - _regno_resize_mouse
			var new_size: Vector2 = (_regno_resize_start + Vector2(delta.x, delta.x)).clamp(Vector2(16, 16), Vector2(600, 600))
			for node in _regno_nodes:
				node.size = new_size

func _get_preview_image_rect() -> Rect2:
	if preview.texture == null:
		return Rect2(Vector2.ZERO, preview.size)
	var tex_size: Vector2 = preview.texture.get_size()
	var size: Vector2 = preview.size
	if tex_size.x <= 0 or tex_size.y <= 0:
		return Rect2(Vector2.ZERO, size)
	var scale: float = min(size.x / tex_size.x, size.y / tex_size.y)
	var display: Vector2 = tex_size * scale
	var offset: Vector2 = (size - display) * 0.5
	return Rect2(offset, display)

func _collect_regno_nodes_normalized() -> Array:
	var out: Array = []
	var image_rect := _get_preview_image_rect()
	if image_rect.size.x <= 0.0 or image_rect.size.y <= 0.0:
		return out
	for node in _regno_nodes:
		var pos := node.position - image_rect.position
		var x := pos.x / image_rect.size.x
		var y := pos.y / image_rect.size.y
		var w := node.size.x / image_rect.size.x
		var h := node.size.y / image_rect.size.y
		out.append({
			"x": snappedf(x, 0.0001),
			"y": snappedf(y, 0.0001),
			"w": snappedf(w, 0.0001),
			"h": snappedf(h, 0.0001)
		})
	return out

func _save_cards() -> void:
	var cards_path: String = DeckRegistry.get_cards_path(_selected_deck_id())
	var file := FileAccess.open(cards_path, FileAccess.WRITE)
	if file == null:
		return
	var json := JSON.stringify(_cards, "\t")
	file.store_string(json)

func _on_preview_resized() -> void:
	if _regno_edit_mode and _is_regno_card(_selected_card):
		_build_regno_nodes()


func _category_for(card: Dictionary) -> String:
	var ctype := str(card.get("type", ""))
	if str(card.get("id", "")) == REGNO_ID:
		return "single"
	if ctype in ["scontro", "concatenamento", "maledizione", "evento", "missione"]:
		return "adventure"
	if ctype in ["equipaggiamento", "istantaneo"]:
		return "treasure"
	if ctype in ["boss", "boss_finale"]:
		return "boss"
	return "single"

func _filter_match(filter_id: int, category: String) -> bool:
	match filter_id:
		0:
			return category == "treasure"
		1:
			return category == "adventure"
		2:
			return category == "boss"
		3:
			return category == "single"
	return true

func _normalize_name(name: String) -> String:
	var s := name.to_lower()
	s = s.replace("_", " ")
	s = s.replace("à", "a").replace("è", "e").replace("é", "e").replace("ì", "i").replace("ò", "o").replace("ù", "u")
	var out := ""
	for i in s.length():
		var ch := s[i]
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == " ":
			out += ch
	return out.strip_edges()

func _strip_variant_suffix(name: String) -> String:
	var parts := name.split(" ")
	if parts.size() > 1:
		var last := parts[parts.size() - 1]
		if last.is_valid_int():
			parts.remove_at(parts.size() - 1)
			return " ".join(parts)
	return name
