extends Node3D

@export var color: Color = Color(0.2, 0.2, 0.2, 1.0)

@onready var pivot: Node3D = $Pivot
@onready var mesh: MeshInstance3D = $Pivot/Mesh
@onready var outline: MeshInstance3D = $Pivot/Outline

var base_scale: Vector3 = Vector3.ONE
var base_mesh_scale: Vector3 = Vector3.ONE
var is_face_up: bool = false
var is_animating: bool = false
var flip_uv_x: bool = false
var front_material: StandardMaterial3D
var back_material: StandardMaterial3D
var side_material: StandardMaterial3D

const CARD_SIZE: Vector2 = Vector2(1.4, 2.0)
const CARD_THICKNESS: float = 0.04

func _ready() -> void:
	base_scale = scale
	base_mesh_scale = mesh.scale
	_initialize_card_materials()
	mesh.mesh = _build_card_mesh(CARD_SIZE, CARD_THICKNESS)
	mesh.set_surface_override_material(0, front_material)
	mesh.set_surface_override_material(1, back_material)
	mesh.set_surface_override_material(2, side_material)
	outline.visible = false
	pivot.rotation = Vector3.ZERO
	set_face_up(false)
	_apply_face_materials()

func _initialize_card_materials() -> void:
	var base := StandardMaterial3D.new()
	if mesh.material_override is StandardMaterial3D:
		base = (mesh.material_override as StandardMaterial3D).duplicate() as StandardMaterial3D
	# Per-surface materials must not be overridden globally.
	mesh.material_override = null
	base.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	base.cull_mode = BaseMaterial3D.CULL_DISABLED
	front_material = base.duplicate() as StandardMaterial3D
	back_material = base.duplicate() as StandardMaterial3D
	side_material = base.duplicate() as StandardMaterial3D
	front_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	side_material.albedo_color = color.darkened(0.15)

func _build_card_mesh(size: Vector2, thickness: float) -> ArrayMesh:
	var half_w := size.x * 0.5
	var half_h := size.y * 0.5
	var half_t := thickness * 0.5

	var mesh_out := ArrayMesh.new()

	var st_front := SurfaceTool.new()
	st_front.begin(Mesh.PRIMITIVE_TRIANGLES)
	_add_quad(st_front,
		Vector3(-half_w, -half_h, half_t),
		Vector3(half_w, -half_h, half_t),
		Vector3(half_w, half_h, half_t),
		Vector3(-half_w, half_h, half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(0.0, 0.0, 1.0)
	)
	st_front.commit(mesh_out)

	var st_back := SurfaceTool.new()
	st_back.begin(Mesh.PRIMITIVE_TRIANGLES)
	_add_quad(st_back,
		Vector3(half_w, -half_h, -half_t),
		Vector3(-half_w, -half_h, -half_t),
		Vector3(-half_w, half_h, -half_t),
		Vector3(half_w, half_h, -half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(0.0, 0.0, -1.0)
	)
	st_back.commit(mesh_out)

	var st_sides := SurfaceTool.new()
	st_sides.begin(Mesh.PRIMITIVE_TRIANGLES)
	_add_quad(st_sides,
		Vector3(half_w, -half_h, half_t),
		Vector3(half_w, -half_h, -half_t),
		Vector3(half_w, half_h, -half_t),
		Vector3(half_w, half_h, half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(1.0, 0.0, 0.0)
	)
	_add_quad(st_sides,
		Vector3(-half_w, -half_h, -half_t),
		Vector3(-half_w, -half_h, half_t),
		Vector3(-half_w, half_h, half_t),
		Vector3(-half_w, half_h, -half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(-1.0, 0.0, 0.0)
	)
	_add_quad(st_sides,
		Vector3(-half_w, half_h, half_t),
		Vector3(half_w, half_h, half_t),
		Vector3(half_w, half_h, -half_t),
		Vector3(-half_w, half_h, -half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(0.0, 1.0, 0.0)
	)
	_add_quad(st_sides,
		Vector3(-half_w, -half_h, -half_t),
		Vector3(half_w, -half_h, -half_t),
		Vector3(half_w, -half_h, half_t),
		Vector3(-half_w, -half_h, half_t),
		Vector2(0.0, 1.0),
		Vector2(1.0, 1.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, 0.0),
		Vector3(0.0, -1.0, 0.0)
	)
	st_sides.commit(mesh_out)

	return mesh_out

func _add_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, uv_a: Vector2, uv_b: Vector2, uv_c: Vector2, uv_d: Vector2, normal: Vector3) -> void:
	st.set_normal(normal)
	st.set_uv(uv_a)
	st.add_vertex(a)
	st.set_normal(normal)
	st.set_uv(uv_b)
	st.add_vertex(b)
	st.set_normal(normal)
	st.set_uv(uv_c)
	st.add_vertex(c)
	st.set_normal(normal)
	st.set_uv(uv_a)
	st.add_vertex(a)
	st.set_normal(normal)
	st.set_uv(uv_c)
	st.add_vertex(c)
	st.set_normal(normal)
	st.set_uv(uv_d)
	st.add_vertex(d)

func set_card_texture(texture_path: String) -> void:
	if texture_path.is_empty():
		push_warning("Card texture path vuoto: fallback materiale neutro.")
		_set_neutral_material()
		return
	var texture := load(texture_path)
	if texture == null:
		push_warning("Texture carta non trovata: %s (fallback neutro)." % texture_path)
		_set_neutral_material()
		return
	var mat := front_material.duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	if flip_uv_x:
		mat.uv1_scale = Vector3(-1.0, 1.0, 1.0)
	front_material = mat
	_apply_face_materials()

func set_texture_flip_x(value: bool) -> void:
	flip_uv_x = value
	if front_material != null:
		front_material.uv1_scale = Vector3(-1.0, 1.0, 1.0) if flip_uv_x else Vector3(1.0, 1.0, 1.0)
		_apply_face_materials()

func _set_neutral_material() -> void:
	var mat := front_material.duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 0.9, 0.2, 1.0)
	mat.albedo_texture = null
	front_material = mat
	_apply_face_materials()

func set_highlighted(active: bool) -> void:
	outline.visible = active

func set_dragging(active: bool) -> void:
	if active:
		mesh.sorting_offset = 100.0
		outline.sorting_offset = 100.0
		scale = base_scale * 1.03
	else:
		scale = base_scale
		# Non resettare il sorting_offset qui - verra gestito da _update_all_card_sorting_offsets

func set_sorting_offset(value: float) -> void:
	mesh.sorting_offset = value
	outline.sorting_offset = value

func set_face_up(value: bool) -> void:
	is_face_up = value
	_apply_face_materials()

func is_face_up_now() -> bool:
	return is_face_up

func flip_to_side(target_position: Vector3) -> void:
	if is_animating:
		return
	is_animating = true
	pivot.rotation = Vector3.ZERO
	var dir := -1.0
	if has_meta("flip_dir"):
		dir = float(get_meta("flip_dir"))
	var sign := 1.0 if dir >= 0.0 else -1.0
	var rotate_on_lifted_axis := false
	if has_meta("flip_rotate_on_lifted_axis"):
		rotate_on_lifted_axis = bool(get_meta("flip_rotate_on_lifted_axis"))
		set_meta("flip_rotate_on_lifted_axis", false)
	var pre_lift_y: float = global_position.y
	var pre_lift_duration: float = 0.14
	if has_meta("flip_pre_lift_y"):
		pre_lift_y = float(get_meta("flip_pre_lift_y"))
		set_meta("flip_pre_lift_y", global_position.y)
	if has_meta("flip_pre_lift_duration"):
		pre_lift_duration = max(0.05, float(get_meta("flip_pre_lift_duration")))
		set_meta("flip_pre_lift_duration", 0.14)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if pre_lift_y > global_position.y + 0.001:
		var lift_pos := global_position
		lift_pos.y = pre_lift_y
		tween.tween_property(self, "global_position", lift_pos, pre_lift_duration)
	var half := 1.2 * 0.5
	tween.tween_property(pivot, "rotation:y", sign * PI * 0.5, half)
	tween.tween_property(pivot, "rotation:y", sign * PI, half)
	if rotate_on_lifted_axis:
		# Keep the lifted position during the flip; move to target only after rotation.
		tween.tween_property(self, "global_position", target_position, 0.2)
	else:
		tween.parallel().tween_property(self, "global_position", target_position, 1.2)
	tween.tween_callback(func() -> void:
		global_position = target_position
		rotation.y += deg_to_rad(randf_range(-2.0, 2.0))
		if has_meta("flip_force_face_up") and bool(get_meta("flip_force_face_up")):
			set_face_up(true)
			set_meta("flip_force_face_up", false)
		is_animating = false
	)


func set_back_texture(texture_path: String) -> void:
	if texture_path.is_empty():
		return
	var texture := load(texture_path)
	if texture == null:
		return
	var mat := back_material.duplicate() as StandardMaterial3D
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	back_material = mat
	_apply_face_materials()

func _apply_face_materials() -> void:
	if mesh == null:
		return
	if front_material == null or back_material == null:
		return
	if is_face_up:
		mesh.set_surface_override_material(0, front_material)
		mesh.set_surface_override_material(1, back_material)
	else:
		mesh.set_surface_override_material(0, back_material)
		mesh.set_surface_override_material(1, front_material)
