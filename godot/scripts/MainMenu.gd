extends Control

@onready var deck_option: OptionButton = $Center/VBox/DeckOption

func _ready() -> void:
    deck_option.add_item("Ghosts 'n Goblins", 0)
    deck_option.selected = 0

func _on_start_pressed() -> void:
    var deck_id := "GnG"
    if deck_option.selected != 0:
        deck_id = "GnG"
    GameConfig.selected_deck_id = deck_id
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_deck_option_item_selected(_index: int) -> void:
    pass

func _on_visibility_changed() -> void:
    pass
