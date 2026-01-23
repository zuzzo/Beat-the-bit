extends Node

const CARDS_PATH := "res://data/cards.json"

var cards: Array = []
var deck_adventure: Array = []
var deck_treasures: Array = []
var deck_boss: Array = []
var deck_boss_finale: Array = []
var cards_characters: Array = []
var cards_shared: Array = []

func _ready() -> void:
	load_cards()

func load_cards() -> void:
	cards.clear()
	deck_adventure.clear()
	deck_treasures.clear()
	deck_boss.clear()
	deck_boss_finale.clear()
	cards_characters.clear()
	cards_shared.clear()

	var file := FileAccess.open(CARDS_PATH, FileAccess.READ)
	if file == null:
		push_warning("cards.json non trovato")
		return
	var raw := file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed == null:
		push_warning("cards.json non valido")
		return

	for entry in parsed:
		if not (entry is Dictionary):
			continue
		cards.append(entry)
		var ctype := str(entry.get("type", ""))
		match ctype:
			"scontro", "concatenamento", "maledizione", "evento":
				deck_adventure.append(entry)
			"equipaggiamento", "istantaneo", "missione":
				deck_treasures.append(entry)
			"boss":
				deck_boss.append(entry)
			"boss_finale":
				deck_boss_finale.append(entry)
			"personaggio":
				cards_characters.append(entry)
			_:
				pass
