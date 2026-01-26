extends Node3D

@onready var body: MeshInstance3D = $Body
@onready var top: MeshInstance3D = $Top
@onready var bottom: MeshInstance3D = $Bottom
@onready var outline: MeshInstance3D = $Outline
@onready var hit_area: Area3D = $HitArea

func _ready() -> void:
	outline.visible = false

func set_token_texture(texture_path: String) -> void:
	if texture_path.is_empty():
		return
	var texture := load(texture_path)
	if texture == null:
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	top.material_override = mat
	var bottom_mat := mat.duplicate() as StandardMaterial3D
	bottom.material_override = bottom_mat

func set_highlighted(active: bool) -> void:
	outline.visible = active

func set_dragging(active: bool) -> void:
	var offset := 200.0 if active else 0.0
	body.sorting_offset = offset
	top.sorting_offset = offset
	bottom.sorting_offset = offset
	outline.sorting_offset = offset
