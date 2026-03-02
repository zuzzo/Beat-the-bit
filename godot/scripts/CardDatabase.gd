extends Node

const EFFECTS_REGISTRY := preload("res://scripts/effects/EffectsRegistry.gd")

var cards: Array = []
var deck_adventure: Array = []
var deck_treasures: Array = []
var deck_boss: Array = []
var deck_boss_finale: Array = []
var cards_characters: Array = []
var cards_shared: Array = []

func _ready() -> void:
	load_cards(GameConfig.selected_deck_id)

func load_cards(deck_id: String = "") -> void:
	cards.clear()
	deck_adventure.clear()
	deck_treasures.clear()
	deck_boss.clear()
	deck_boss_finale.clear()
	cards_characters.clear()
	cards_shared.clear()
	var selected_id: String = deck_id.strip_edges()
	if selected_id.is_empty():
		selected_id = GameConfig.selected_deck_id
	var set_id: String = DeckRegistry.get_card_set(selected_id)
	var cards_path: String = DeckRegistry.get_cards_path(selected_id)

	var file := FileAccess.open(cards_path, FileAccess.READ)
	if file == null:
		push_warning("cards.json non trovato: %s" % cards_path)
		return
	var raw := file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed == null:
		push_warning("cards.json non valido: %s" % cards_path)
		return

	for entry in parsed:
		if not (entry is Dictionary):
			continue
		var card_data: Dictionary = (entry as Dictionary).duplicate(true)
		var card_set: String = str(card_data.get("set", ""))
		if card_set != set_id:
			continue
		var normalized_type: String = _normalize_card_type(str(card_data.get("type", "")))
		if normalized_type != "":
			card_data["type"] = normalized_type
		_normalize_card_effects(card_data)
		var copies: int = max(1, int(card_data.get("copies", 1)))
		cards.append(card_data.duplicate(true))
		var ctype := str(card_data.get("type", ""))
		for _copy_idx in copies:
			var copy_data: Dictionary = card_data.duplicate(true)
			match ctype:
				"scontro", "concatenamento", "maledizione", "missione":
					deck_adventure.append(copy_data)
				"evento":
					# Shared board events (e.g. Regno del male) are not adventure-deck cards.
					if str(copy_data.get("id", "")) == "shared_regno_del_male":
						cards_shared.append(copy_data)
					else:
						deck_adventure.append(copy_data)
				"equipaggiamento", "istantaneo":
					deck_treasures.append(copy_data)
				"boss":
					deck_boss.append(copy_data)
				"boss_finale":
					deck_boss_finale.append(copy_data)
				"personaggio":
					cards_characters.append(copy_data)
				_:
					pass

func _normalize_card_effects(card_data: Dictionary) -> void:
	var effects: Array = card_data.get("effects", [])
	if not effects.is_empty():
		card_data["effects"] = EFFECTS_REGISTRY.canonicalize_effect_list(effects)
	var timed_effects: Array = card_data.get("timed_effects", [])
	if timed_effects.is_empty():
		return
	var normalized_timed: Array = []
	var seen: Dictionary = {}
	for item in timed_effects:
		if not (item is Dictionary):
			continue
		var data: Dictionary = (item as Dictionary).duplicate(true)
		var effect_name: String = EFFECTS_REGISTRY.canonical_effect_code(str(data.get("effect", "")))
		if effect_name == "":
			continue
		var when_name: String = str(data.get("when", "")).strip_edges().to_lower()
		var key: String = "%s|%s" % [when_name, effect_name]
		if seen.has(key):
			continue
		seen[key] = true
		data["effect"] = effect_name
		data["when"] = when_name
		normalized_timed.append(data)
	card_data["timed_effects"] = normalized_timed

func _normalize_card_type(raw_type: String) -> String:
	var t: String = raw_type.strip_edges().to_lower()
	if t == "":
		return ""
	match t:
		"encounter", "enemy", "adventure", "combat":
			return "scontro"
		"chain":
			return "concatenamento"
		"curse":
			return "maledizione"
		"mission", "missions", "missioni", "emissione", "emissioni", "zaino":
			return "missione"
		"event":
			return "evento"
		"equipment":
			return "equipaggiamento"
		"instant", "spell":
			return "istantaneo"
		"character":
			return "personaggio"
		"final_boss":
			return "boss_finale"
		_:
			return t
