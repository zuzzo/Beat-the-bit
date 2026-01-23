extends Node3D

const DICE_SCENE := preload("res://scenes/Dice.tscn")
const CARD_SCENE := preload("res://scenes/Card.tscn")
const TABLE_Y := 0.0

@onready var camera: Camera3D = $Camera

var pan_active := false
var launch_start_time: float = -1.0
var pending_dice: Array[RigidBody3D] = []
var sum_label: Label
var roll_history: Array[int] = []
var roll_color_history: Array[String] = []
var dice_count: int = 1
var active_dice: Array[RigidBody3D] = []

func _ready() -> void:
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	_spawn_placeholders()
	_spawn_sum_label()
	print("Deck selezionato:", GameConfig.selected_deck_id)
	print("Carte avventura:", CardDatabase.deck_adventure.size())
	# Example usage with placeholders.
	var example_deck := ["c1", "c2", "c3", "c4", "c5"]
	DeckUtils.shuffle_deck(example_deck)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		dice_count = 1
		_clear_dice()
		roll_history.clear()
		roll_color_history.clear()
		sum_label.text = "Risultati: - | Colori: -"

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			launch_start_time = Time.get_ticks_msec() / 1000.0
		else:
			_release_launch(event.position)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			pan_active = true
		else:
			pan_active = false
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom(-1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom(1.0)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not pan_active:
		return
	var pan_speed := 0.006 * camera.global_position.y
	camera.global_position.x -= event.relative.x * pan_speed
	camera.global_position.z -= event.relative.y * pan_speed

func _zoom(direction: float) -> void:
	var pos := camera.global_position
	pos.y = clamp(pos.y + direction, 6.0, 40.0)
	camera.global_position = pos

func _release_launch(mouse_pos: Vector2) -> void:
	if launch_start_time < 0.0:
		return
	var held: float = max(0.0, (Time.get_ticks_msec() / 1000.0) - launch_start_time)
	launch_start_time = -1.0
	var hit: Vector3 = _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	_clear_dice()
	_spawn_dice(hit, held)
	dice_count += 1
	_track_dice_sum()

func _spawn_dice(position: Vector3, hold_time: float) -> void:
	var hold_scale: float = clamp(0.6 + hold_time * 1.2, 0.6, 2.0)
	for i in dice_count:
		var dice: RigidBody3D = DICE_SCENE.instantiate() as RigidBody3D
		add_child(dice)
		dice.global_position = position + Vector3(i * 0.6, 2.0, 0.0)
		dice.global_rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		var impulse: Vector3 = Vector3(
			randf_range(-0.4, 0.4) * hold_scale,
			randf_range(4.0, 5.0) * hold_scale,
			randf_range(1.2, 2.0) * hold_scale
		)
		var torque: Vector3 = Vector3(
			randf_range(-1.1, 1.1) * hold_scale,
			randf_range(-1.1, 1.1) * hold_scale,
			randf_range(-1.1, 1.1) * hold_scale
		)
		dice.apply_central_impulse(impulse)
		dice.apply_torque_impulse(torque)
		dice.angular_velocity = Vector3(
			randf_range(-1.5, 1.5) * hold_scale,
			randf_range(-1.5, 1.5) * hold_scale,
			randf_range(-1.5, 1.5) * hold_scale
		)
		pending_dice.append(dice)
		active_dice.append(dice)

func _ray_to_plane(mouse_pos: Vector2) -> Vector3:
	var viewport := get_viewport()
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	if abs(direction.y) < 0.0001:
		return Vector3.INF
	var t := (TABLE_Y - origin.y) / direction.y
	if t < 0.0:
		return Vector3.INF
	return origin + direction * t

func _spawn_sum_label() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	sum_label = Label.new()
	sum_label.text = "Somma: -"
	sum_label.position = Vector2(20, 20)
	ui.add_child(sum_label)

func _track_dice_sum() -> void:
	if pending_dice.is_empty():
		return
	await _wait_for_dice_settle(pending_dice)
	var values: Array[int] = []
	var names: Array[String] = []
	for dice in pending_dice:
		if not is_instance_valid(dice):
			continue
		var value := _get_top_face_value(dice)
		values.append(value)
		names.append(_get_top_face_name(dice))
	pending_dice.clear()
	var total := 0
	for v in values:
		total += v
	roll_history.append(total)
	roll_color_history.append(", ".join(names))
	sum_label.text = "Risultati: %s | Colori: %s" % [", ".join(roll_history), " | ".join(roll_color_history)]

func _wait_for_dice_settle(dice_list: Array[RigidBody3D]) -> void:
	var elapsed := 0.0
	var timeout := 5.0
	var stable_time := 0.0
	while elapsed < timeout:
		var all_settled := true
		for dice in dice_list:
			if not is_instance_valid(dice):
				continue
			if dice.sleeping:
				continue
			if dice.linear_velocity.length() > 0.05 or dice.angular_velocity.length() > 0.05:
				all_settled = false
				break
		if all_settled:
			stable_time += 0.1
			if stable_time >= 0.3:
				return
		else:
			stable_time = 0.0
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1

func _clear_dice() -> void:
	for dice in active_dice:
		if is_instance_valid(dice):
			dice.queue_free()
	active_dice.clear()
	pending_dice.clear()

func _get_top_face_value(dice: RigidBody3D) -> int:
	if dice.has_method("get_top_value"):
		return dice.get_top_value()
	return 1

func _get_top_face_name(dice: RigidBody3D) -> String:
	if dice.has_method("get_top_name"):
		return dice.get_top_name()
	return "?"


func _spawn_placeholders() -> void:
	# Mazzo avventura.
	var adventure := CARD_SCENE.instantiate()
	adventure.color = Color(0.35, 0.15, 0.15, 1.0)
	adventure.name = "MazzoAvventura"
	add_child(adventure)
	adventure.global_position = Vector3(5.5, 0.02, -1.0)
	adventure.rotate_x(-PI / 2.0)

	# Mazzo tesori.
	var treasure := CARD_SCENE.instantiate()
	treasure.color = Color(0.2, 0.2, 0.4, 1.0)
	treasure.name = "MazzoTesori"
	add_child(treasure)
	treasure.global_position = Vector3(-2.0, 0.02, 0.5)
	treasure.rotate_x(-PI / 2.0)

	# Carta personaggio.
	var character := CARD_SCENE.instantiate()
	character.color = Color(0.2, 0.35, 0.2, 1.0)
	character.name = "CartaPersonaggio"
	add_child(character)
	character.global_position = Vector3(0.0, 0.02, 3.5)
	character.rotate_x(-PI / 2.0)
