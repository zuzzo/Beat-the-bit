extends Node3D

@onready var outline: MeshInstance3D = $Outline
@onready var body: MeshInstance3D = $Body
@onready var label: Label3D = $Label

func _ready() -> void:
	outline.visible = false
	if label is Label3D:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_update_label()

func set_highlighted(active: bool) -> void:
	outline.visible = active

func set_dragging(active: bool) -> void:
	var offset := 300.0 if active else 0.0
	body.sorting_offset = offset
	outline.sorting_offset = offset

func set_label(text_value: String) -> void:
	label.text = text_value

func _update_label() -> void:
	if has_meta("pos_box_label"):
		label.text = str(get_meta("pos_box_label"))
