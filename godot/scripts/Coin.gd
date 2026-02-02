extends RigidBody3D

@export var mesh_radius: float = 0.105
@export var mesh_height: float = 0.02
@export var collision_radius: float = 0.15
@export var collision_height: float = 0.008

@onready var mesh_instance: MeshInstance3D = $Mesh
@onready var collision_shape: CollisionShape3D = $Collision
var _settle_time: float = 0.0
var _alive_time: float = 0.0
const _SETTLE_LINEAR := 0.12
const _SETTLE_ANGULAR := 0.12
const _SETTLE_DELAY := 0.4
const _MAX_SETTLE_TIME := 2.0
const _MAX_LINEAR := 0.3
const _MAX_ANGULAR := 0.3

func _ready() -> void:
	_apply_sizes()
	can_sleep = true
	sleeping = false

func _physics_process(delta: float) -> void:
	if sleeping:
		return
	_alive_time += delta
	if linear_velocity.length() < _SETTLE_LINEAR and angular_velocity.length() < _SETTLE_ANGULAR:
		_settle_time += delta
		if _settle_time >= _SETTLE_DELAY:
			freeze = true
			sleeping = true
	else:
		_settle_time = 0.0
	if _alive_time >= _MAX_SETTLE_TIME:
		if linear_velocity.length() < _MAX_LINEAR and angular_velocity.length() < _MAX_ANGULAR:
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
