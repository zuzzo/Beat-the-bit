extends Node

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
		var card_set: String = str((entry as Dictionary).get("set", ""))
		if card_set != set_id:
			continue
		var normalized_type: String = _normalize_card_type(str((entry as Dictionary).get("type", "")))
		if normalized_type != "":
			(entry as Dictionary)["type"] = normalized_type
		cards.append(entry)
		var ctype := str(entry.get("type", ""))
		match ctype:
			"scontro", "concatenamento", "maledizione", "missione":
				deck_adventure.append(entry)
			"evento":
				# Shared board events (e.g. Regno del male) are not adventure-deck cards.
				if str(entry.get("id", "")) == "shared_regno_del_male":
					cards_shared.append(entry)
				else:
					deck_adventure.append(entry)
			"equipaggiamento", "istantaneo":
				deck_treasures.append(entry)
			"boss":
				deck_boss.append(entry)
			"boss_finale":
				deck_boss_finale.append(entry)
			"personaggio":
				cards_characters.append(entry)
			_:
				pass

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
