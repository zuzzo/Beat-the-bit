extends RigidBody3D

@export var mesh_radius: float = 0.21
@export var mesh_height: float = 0.04
@export var collision_radius: float = 0.30
@export var collision_height: float = 0.016

@onready var mesh_instance: MeshInstance3D = $Mesh
@onready var collision_shape: CollisionShape3D = $Collision
var _settle_time: float = 0.0
var _alive_time: float = 0.0
const COIN_TEXTURE := preload("res://assets/Token/coin.png")
var _uv_scale := 2.0
var _uv_offset := Vector3(0.0, 0.0, 0.0)
var _mat: StandardMaterial3D
const _SETTLE_LINEAR := 0.12
const _SETTLE_ANGULAR := 0.12
const _SETTLE_DELAY := 0.4
const _MAX_SETTLE_TIME := 2.0
const _MAX_LINEAR := 0.3
const _MAX_ANGULAR := 0.3

func _ready() -> void:
	_apply_sizes()
	_apply_texture()
	add_to_group("coins")
	can_sleep = true
	sleeping = false

func _apply_texture() -> void:
	if mesh_instance == null:
		return
	_mat = StandardMaterial3D.new()
	_mat.albedo_texture = COIN_TEXTURE
	_mat.albedo_color = Color(1, 1, 1, 1)
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.metallic = 0.2
	_mat.roughness = 0.6
	_update_uv()
	mesh_instance.material_override = _mat


func _update_uv() -> void:
	if _mat == null:
		return
	_mat.uv1_scale = Vector3(_uv_scale, _uv_scale, 1.0)
	_mat.uv1_offset = _uv_offset

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_PLUS, KEY_KP_ADD:
				_uv_scale += 0.1
				_update_uv()
			KEY_MINUS, KEY_KP_SUBTRACT:
				_uv_scale = max(0.1, _uv_scale - 0.1)
				_update_uv()
			KEY_UP:
				_uv_offset.y -= 0.05
				_update_uv()
			KEY_DOWN:
				_uv_offset.y += 0.05
				_update_uv()
			KEY_LEFT:
				_uv_offset.x -= 0.05
				_update_uv()
			KEY_RIGHT:
				_uv_offset.x += 0.05
				_update_uv()

func _physics_process(delta: float) -> void:
	if sleeping:
		return
	_alive_time += delta
	if linear_velocity.length() < _SETTLE_LINEAR and angular_velocity.length() < _SETTLE_ANGULAR:
		_settle_time += delta
		if _settle_time >= _SETTLE_DELAY:
			_settle_now()
	else:
		_settle_time = 0.0
	if _alive_time >= _MAX_SETTLE_TIME:
		if linear_velocity.length() < _MAX_LINEAR and angular_velocity.length() < _MAX_ANGULAR:
			_settle_now()

func _settle_now() -> void:
	# Hard stop to avoid micro jitter while resting on the table.
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	var rot := global_rotation
	rot.x = 0.0
	rot.z = 0.0
	global_rotation = rot
	freeze = true
	sleeping = true

func _apply_sizes() -> void:
	if mesh_instance != null and mesh_instance.mesh is CylinderMesh:
		var mesh := mesh_instance.mesh as CylinderMesh
		mesh.top_radius = mesh_radius
		mesh.bottom_radius = mesh_radius
		mesh.height = mesh_height
	if collision_shape != null and collision_shape.shape is CylinderShape3D:
		var shape := collision_shape.shape as CylinderShape3D
		shape.radius = collision_radius
		shape.height = collision_height
