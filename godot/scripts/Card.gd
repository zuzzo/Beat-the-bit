extends Node3D

@export var color: Color = Color(0.2, 0.2, 0.2, 1.0)

@onready var pivot: Node3D = $Pivot
@onready var mesh: MeshInstance3D = $Pivot/Mesh
@onready var outline: MeshInstance3D = $Pivot/Outline
@onready var back_mesh: MeshInstance3D = $Pivot/Back

var base_scale: Vector3 = Vector3.ONE
var base_mesh_scale: Vector3 = Vector3.ONE
var is_face_up: bool = false
var is_animating: bool = false
var flip_uv_x: bool = false

func _ready() -> void:
	base_scale = scale
	base_mesh_scale = mesh.scale
	if mesh.material_override is StandardMaterial3D:
		var mat := mesh.material_override as StandardMaterial3D
		mat.albedo_color = color
		mat.cull_mode = BaseMaterial3D.CULL_BACK
	if back_mesh.material_override is StandardMaterial3D:
		var back_mat := back_mesh.material_override as StandardMaterial3D
		back_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	outline.visible = false
	pivot.rotation = Vector3.ZERO
	set_face_up(false)

func set_card_texture(texture_path: String) -> void:
	if texture_path.is_empty():
		_set_neutral_material()
		return
	var texture := load(texture_path)
	if texture == null:
		_set_neutral_material()
		return
	var mat := StandardMaterial3D.new()
	if mesh.material_override is StandardMaterial3D:
		mat = (mesh.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	if flip_uv_x:
		mat.uv1_scale = Vector3(-1.0, 1.0, 1.0)
	mesh.material_override = mat

func set_texture_flip_x(value: bool) -> void:
	flip_uv_x = value
	if mesh.material_override is StandardMaterial3D:
		var mat := mesh.material_override as StandardMaterial3D
		mat.uv1_scale = Vector3(-1.0, 1.0, 1.0) if flip_uv_x else Vector3(1.0, 1.0, 1.0)

func _set_neutral_material() -> void:
	var mat := StandardMaterial3D.new()
	if mesh.material_override is StandardMaterial3D:
		mat = (mesh.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 0.9, 0.2, 1.0)
	mat.albedo_texture = null
	mesh.material_override = mat

func set_highlighted(active: bool) -> void:
	outline.visible = active

func set_dragging(active: bool) -> void:
	if active:
		mesh.sorting_offset = 100.0
		back_mesh.sorting_offset = 100.0
		outline.sorting_offset = 100.0
		scale = base_scale * 1.03
	else:
		scale = base_scale
		# Non resettare il sorting_offset qui - verrà gestito da _update_all_card_sorting_offsets

func set_sorting_offset(value: float) -> void:
	mesh.sorting_offset = value
	back_mesh.sorting_offset = value
	outline.sorting_offset = value

func set_face_up(value: bool) -> void:
	is_face_up = value
	mesh.visible = is_face_up
	back_mesh.visible = not is_face_up
	if is_face_up:
		mesh.rotation = Vector3.ZERO

func is_face_up_now() -> bool:
	return is_face_up

func flip_to_side(target_position: Vector3) -> void:
	if is_animating:
		return
	is_animating = true
	pivot.rotation = Vector3.ZERO
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var half := 1.2 * 0.5
	tween.tween_property(pivot, "rotation:y", -PI * 0.5, half)
	tween.tween_callback(func() -> void:
		set_texture_flip_x(true)
		set_face_up(true)
	)
	tween.tween_property(pivot, "rotation:y", -PI, half)
	tween.parallel().tween_property(self, "global_position", target_position, 1.2)
	tween.tween_callback(func() -> void:
		global_position = target_position
		rotation.y += deg_to_rad(randf_range(-2.0, 2.0))
		is_animating = false
	)

func set_back_texture(texture_path: String) -> void:
	if texture_path.is_empty():
		return
	var texture := load(texture_path)
	if texture == null:
		return
	var mat := StandardMaterial3D.new()
	if back_mesh.material_override is StandardMaterial3D:
		mat = (back_mesh.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	back_mesh.material_override = mat
