extends Node

const DEFAULT_DECK_ID := "GnG"

const DECKS := {
	"GnG": {
		"label": "Ghosts 'n Goblins",
		"card_set": "GnG",
		"cards_path": "res://data/decks/gng/cards.json",
		"config_path": "res://data/decks/gng/deck.json"
	},
	"GoldenAxe": {
		"label": "Golden Axe",
		"card_set": "GoldenAxe",
		"cards_path": "res://data/decks/golden_axe/cards.json",
		"config_path": "res://data/decks/golden_axe/deck.json"
	}
}

func list_deck_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in DECKS.keys():
		ids.append(str(key))
	ids.sort()
	if ids.has(DEFAULT_DECK_ID):
		ids.erase(DEFAULT_DECK_ID)
		ids.push_front(DEFAULT_DECK_ID)
	return ids

func get_deck(deck_id: String) -> Dictionary:
	var key := deck_id.strip_edges()
	var deck: Dictionary = {}
	if DECKS.has(key):
		deck = (DECKS[key] as Dictionary).duplicate(true)
	else:
		deck = (DECKS[DEFAULT_DECK_ID] as Dictionary).duplicate(true)
	var config_path: String = str(deck.get("config_path", "")).strip_edges()
	if not config_path.is_empty():
		var loaded: Dictionary = _load_json_dictionary(config_path)
		if not loaded.is_empty():
			deck = _merge_dictionaries(deck, loaded)
	return deck

func get_card_set(deck_id: String) -> String:
	var deck := get_deck(deck_id)
	return str(deck.get("card_set", DEFAULT_DECK_ID))

func get_deck_label(deck_id: String) -> String:
	var deck := get_deck(deck_id)
	return str(deck.get("label", deck_id))

func get_cards_path(deck_id: String) -> String:
	var deck := get_deck(deck_id)
	return str(deck.get("cards_path", "res://data/decks/gng/cards.json"))

func _load_json_dictionary(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return (parsed as Dictionary).duplicate(true)
	return {}

func _merge_dictionaries(base: Dictionary, override: Dictionary) -> Dictionary:
	var out: Dictionary = base.duplicate(true)
	for key in override.keys():
		var value: Variant = override[key]
		if out.has(key) and out[key] is Dictionary and value is Dictionary:
			out[key] = _merge_dictionaries(out[key] as Dictionary, value as Dictionary)
		else:
			out[key] = value
	return out
