extends Control

const CARDS_PATH := "res://data/cards.json"
const ADVENTURE_DIR := "res://assets/cards/ghost_n_goblins/adventure"
const BOSS_DIR := "res://assets/cards/ghost_n_goblins/boss"
const TREASURE_DIR := "res://assets/cards/ghost_n_goblins/treasure"
const SINGLE_DIR := "res://assets/cards/ghost_n_goblins/singles"

@onready var deck_option: OptionButton = $RootVBox/TopBar/DeckOption
@onready var filter_option: OptionButton = $RootVBox/EditorSplit/LeftPanel/FilterOption
@onready var card_list: ItemList = $RootVBox/EditorSplit/LeftPanel/CardList
@onready var preview: TextureRect = $RootVBox/EditorSplit/RightPanel/Preview
@onready var details: Label = $RootVBox/EditorSplit/RightPanel/Details

var _cards: Array = []
var _display_cards: Array = []
var _adventure_index: Dictionary = {}

func _ready() -> void:
	deck_option.add_item("Ghosts 'n Goblins", 0)
	deck_option.selected = 0
	filter_option.add_item("Tesori", 0)
	filter_option.add_item("Avventure", 1)
	filter_option.add_item("Boss", 2)
	filter_option.add_item("Carte singole", 3)
	filter_option.selected = 0
	GameConfig.load_overrides()
	_load_cards()
	_build_adventure_index()
	_refresh_list()
	card_list.item_selected.connect(_on_card_selected)
	filter_option.item_selected.connect(_on_filter_changed)

func _on_start_pressed() -> void:
	var deck_id := "GnG"
	if deck_option.selected != 0:
		deck_id = "GnG"
	GameConfig.selected_deck_id = deck_id
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _load_cards() -> void:
	_cards.clear()
	var file := FileAccess.open(CARDS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null:
		return
	for entry in parsed:
		if entry is Dictionary:
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
	if img_path != "":
		preview.texture = load(img_path)
	else:
		preview.texture = null
	details.text = _build_details(card)
	

func _build_details(card: Dictionary) -> String:
	var lines: Array[String] = []
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
	return "\n".join(lines)


func _category_for(card: Dictionary) -> String:
	var ctype := str(card.get("type", ""))
	if ctype in ["scontro", "concatenamento", "maledizione", "evento"]:
		return "adventure"
	if ctype in ["equipaggiamento", "istantaneo", "missione"]:
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
