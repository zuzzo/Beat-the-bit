extends RigidBody3D

@onready var token: Node = $Token
var _settle_time: float = 0.0
var _alive_time: float = 0.0
const _SETTLE_LINEAR := 0.12
const _SETTLE_ANGULAR := 0.12
const _SETTLE_DELAY := 0.4
const _MAX_SETTLE_TIME := 2.0
const _MAX_LINEAR := 0.3
const _MAX_ANGULAR := 0.3

func _ready() -> void:
	add_to_group("reward_tokens")
	can_sleep = true
	sleeping = false

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
	# Hard stop to avoid tiny residual vibrations once the token has landed.
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	var rot := global_rotation
	rot.x = 0.0
	rot.z = 0.0
	global_rotation = rot
	freeze = true
	sleeping = true

func set_token_texture(texture_path: String) -> void:
	if token != null and token.has_method("set_token_texture"):
		token.call_deferred("set_token_texture", texture_path)
