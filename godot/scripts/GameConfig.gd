extends Node

var selected_deck_id: String = "GnG"
var card_image_overrides: Dictionary = {}

const OVERRIDES_PATH := "user://card_overrides.json"

func load_overrides() -> void:
	card_image_overrides.clear()
	if not FileAccess.file_exists(OVERRIDES_PATH):
		return
	var file := FileAccess.open(OVERRIDES_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		card_image_overrides = parsed

func save_overrides() -> void:
	var file := FileAccess.open(OVERRIDES_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(card_image_overrides))
