extends Node3D

@export var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
@export var token_scene: PackedScene = preload("res://scenes/RewardToken.tscn")
@export var spawn_height: float = 0.25
@export var base_spacing: float = 0.34
@export var jitter: float = 0.03
@export var coin_offset: Vector3 = Vector3(-0.9, 0.0, -0.3)
@export var token_offset: Vector3 = Vector3(0.9, 0.0, 0.3)
@export var coin_spacing_multiplier: float = 1.6
@export var coin_impulse_multiplier: float = 0.4
@export var coin_stack_step: float = 0.018
@export var coin_stack_jitter: float = 0.012

func spawn_coins(count: int, center: Vector3, spacing: float = -1.0) -> Array[RigidBody3D]:
	var use_spacing := spacing
	if use_spacing <= 0.0:
		use_spacing = base_spacing * coin_spacing_multiplier
	return _spawn_items(count, coin_scene, center + coin_offset, use_spacing, "", coin_impulse_multiplier)

func spawn_tokens(count: int, texture_path: String, center: Vector3, spacing: float = -1.0) -> Array[RigidBody3D]:
	var items := _spawn_items(count, token_scene, center + token_offset, spacing, texture_path, 1.0)
	return items

func spawn_coin_stack(count: int, center: Vector3) -> Array[RigidBody3D]:
	var spawned: Array[RigidBody3D] = []
	if count <= 0 or coin_scene == null:
		return spawned
	var base := center + coin_offset
	for i in count:
		var item := coin_scene.instantiate()
		add_child(item)
		if item is RigidBody3D:
			var body := item as RigidBody3D
			body.continuous_cd = true
			body.contact_monitor = true
			body.max_contacts_reported = 4
			body.collision_layer = 1
			body.collision_mask = 1
			body.global_position = Vector3(
				base.x + randf_range(-coin_stack_jitter, coin_stack_jitter),
				base.y + spawn_height + float(i) * coin_stack_step,
				base.z + randf_range(-coin_stack_jitter, coin_stack_jitter)
			)
			body.global_rotation = Vector3(0.0, randf_range(0.0, TAU), 0.0)
			body.apply_central_impulse(Vector3(
				randf_range(-0.03, 0.03),
				randf_range(0.01, 0.03),
				randf_range(-0.03, 0.03)
			))
			spawned.append(body)
	return spawned

func _spawn_items(count: int, scene: PackedScene, center: Vector3, spacing: float, texture_path: String, impulse_multiplier: float) -> Array[RigidBody3D]:
	var spawned: Array[RigidBody3D] = []
	if count <= 0 or scene == null:
		return spawned
	var grid := int(ceil(sqrt(float(count))))
	var use_spacing := spacing if spacing > 0.0 else base_spacing
	var start_x := -(grid - 1) * use_spacing * 0.5
	var start_z := -(grid - 1) * use_spacing * 0.5
	for i in count:
		var row := int(i / grid)
		var col := int(i % grid)
		var item := scene.instantiate()
		add_child(item)
		if item is RigidBody3D:
			var body := item as RigidBody3D
			body.continuous_cd = true
			body.contact_monitor = true
			body.max_contacts_reported = 4
			body.collision_layer = 1
			body.collision_mask = 1
			var pos := Vector3(
				center.x + start_x + col * use_spacing + randf_range(-jitter, jitter),
				center.y + spawn_height + randf_range(0.0, 0.2),
				center.z + start_z + row * use_spacing + randf_range(-jitter, jitter)
			)
			body.global_position = pos
			body.global_rotation = Vector3(
				randf_range(-0.2, 0.2),
				randf_range(0.0, TAU),
				randf_range(-0.2, 0.2)
			)
			body.apply_central_impulse(Vector3(
				randf_range(-0.3, 0.3) * impulse_multiplier,
				randf_range(0.2, 0.6) * impulse_multiplier,
				randf_range(-0.3, 0.3) * impulse_multiplier
			))
			if texture_path != "" and body.has_method("set_token_texture"):
				body.call_deferred("set_token_texture", texture_path)
			spawned.append(body)
	return spawned
