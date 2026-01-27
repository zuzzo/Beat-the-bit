extends Node3D

const DICE_SCENE := preload("res://scenes/Dice.tscn")
const CARD_SCENE := preload("res://scenes/Card.tscn")
const TOKEN_SCENE := preload("res://scenes/Token.tscn")
const TABLE_Y := 0.0
const HAND_UI_SCRIPT := preload("res://scripts/HandUI.gd")
const UI_FONT := preload("res://assets/Font/ARCADECLASSIC.TTF")
const MUSIC_TRACK := preload("res://assets/music/Music.mp3")
const DECK_UTILS := preload("res://scripts/DeckUtils.gd")

@onready var camera: Camera3D = $Camera

var pan_active := false
var launch_start_time: float = -1.0
var pending_dice: Array[RigidBody3D] = []
var sum_label: Label
var y_label: Label
var camera_label: Label
var roll_history: Array[int] = []
var roll_color_history: Array[String] = []
var dice_count: int = 1
var active_dice: Array[RigidBody3D] = []
var dragged_card: Node3D
var drag_offset: Vector3 = Vector3.ZERO
var dragged_card_origin_y: float = 0.0
var hovered_card: Node3D
var selected_card: Node3D
var player_hand: Array = []
var last_mouse_pos: Vector2 = Vector2.ZERO
var mouse_down_pos: Vector2 = Vector2.ZERO
var pending_flip_card: Node3D
var pending_flip_is_adventure: bool = false
const CLICK_DRAG_THRESHOLD := 8.0
const DRAG_HEIGHT := 1.0
var top_sorting_offset: float = 0.0
var equipment_slots: Array[Area3D] = []
var equipment_slots_root: Node3D
var equipment_slots_y_offset: float = 0.0
var equipment_slots_z_offset: float = 1.2
const CARD_CENTER_X_OFFSET := 0.7
const EQUIP_SLOT_WIDTH := 1.4
const EQUIP_SLOT_HEIGHT := 2.0
const EQUIP_SLOT_SPACING := 0.2
var hand_ui: Control
var player_gold: int = 30
var purchase_panel: PanelContainer
var purchase_label: Label
var purchase_yes_button: Button
var purchase_no_button: Button
var purchase_card: Node3D
var purchase_content: VBoxContainer
var adventure_prompt_panel: PanelContainer
var adventure_prompt_label: Label
var adventure_prompt_yes: Button
var adventure_prompt_no: Button
var pending_adventure_card: Node3D
var music_player: AudioStreamPlayer
var phase_index: int = 0
var player_max_hearts: int = 0
var player_max_hand: int = 0
var player_current_hearts: int = 0
const PURCHASE_FONT_SIZE := 44
var treasure_deck_pos := Vector3(-3, 0.0179999992251396, 0)
var treasure_reveal_pos := Vector3(-4, 0.0240000002086163, 0)
var treasure_discard_pos := Vector3(-5.05, 0.0240000002086163, 0.315)
var revealed_treasure_count: int = 0
var discarded_treasure_count: int = 0
var is_treasure_stack_hovered: bool = false
const REVEALED_Y_STEP := 0.01
var adventure_deck_pos := Vector3(2, 0.0209999997168779, 0)
var adventure_reveal_pos := Vector3(0, 0.0179999992251396, 0)
var revealed_adventure_count: int = 0
var is_adventure_stack_hovered: bool = false
const ADVENTURE_BACK := "res://assets/cards/ghost_n_goblins/adventure/Back_adventure.png"
const TREASURE_REVEAL_OFFSET := Vector3(-1.0, 0.006, 0.0)
const TREASURE_DISCARD_OFFSET := Vector3(-2.05, 0.006, 0.315)
const ADVENTURE_REVEAL_OFFSET := Vector3(-2.0, -0.003, 0.0)
var adventure_image_index: Dictionary = {}
var adventure_variant_cursor: Dictionary = {}
const BOSS_BACK := "res://assets/cards/ghost_n_goblins/boss/back_Boss.png"
const CHARACTER_FRONT := "res://assets/cards/ghost_n_goblins/singles/sir Arthur A.png"
const CHARACTER_BACK := "res://assets/cards/ghost_n_goblins/singles/back_personaggio.png"
const REGNO_FRONT := "res://assets/cards/ghost_n_goblins/singles/Regno del male.png"
const REGNO_BACK := "res://assets/cards/ghost_n_goblins/singles/back_regno del male.png"
const ASTAROTH_FRONT := "res://assets/cards/ghost_n_goblins/singles/astaroth.png"
var boss_deck_pos := Vector3(-3, 0.0389999970793724, -2.5)
var character_pos := Vector3(0, 0.0240000002086163, 2.5)
var regno_pos := Vector3(-3, 0.0359999984502792, 2.5)
var astaroth_pos := Vector3(-5, 0.0359999984502792, 2.5)
const HEART_TEXTURE := "res://assets/Token/cuore.png"
var character_card: Node3D
var regno_card: Node3D
const BOSS_STACK_OFFSET := Vector3(0.0, 0.0, 0.0)
var regno_track_nodes: Array = []
var regno_track_index: int = 0
var regno_overlay_layer: CanvasLayer
var regno_overlay: Control
var regno_node_boxes: Array[PanelContainer] = []
var regno_blink_time: float = 0.0

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.global_position = Vector3(0.43, 7.0, 1.74)
	_play_music()
	_spawn_placeholders()
	_init_player_hand()
	_spawn_treasure_cards()
	_build_adventure_image_index()
	_spawn_adventure_cards()
	_spawn_boss_cards()
	_spawn_character_card()
	_spawn_regno_del_male()
	_spawn_astaroth()
	_spawn_sum_label()
	_spawn_hand_ui()
	_create_adventure_prompt()
	_setup_regno_overlay()
	print("Deck selezionato:", GameConfig.selected_deck_id)
	print("Carte avventura:", CardDatabase.deck_adventure.size())
	# Example usage with placeholders.
	var example_deck := ["c1", "c2", "c3", "c4", "c5"]
	DECK_UTILS.shuffle_deck(example_deck)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			dice_count = 1
			_clear_dice()
			roll_history.clear()
			roll_color_history.clear()
			sum_label.text = "Risultati: - | Colori: -"
		elif event.keycode == KEY_PAGEUP:
			_adjust_selected_card_y(0.02)
			_adjust_equipment_slots_y(0.02)
		elif event.keycode == KEY_PAGEDOWN:
			_adjust_selected_card_y(-0.02)
			_adjust_equipment_slots_y(-0.02)
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_launch_dice_at(Vector3(0.0, TABLE_Y, 0.0), 0.3)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_mouse_pos = event.position
			mouse_down_pos = event.position
			var card := _get_card_under_mouse(event.position)
			if card != null:
				if phase_index != 0:
					return
				if card.has_meta("equipped_slot"):
					_return_equipped_to_hand(card)
					return
				selected_card = card
				if card.has_method("is_face_up_now") and card.has_method("flip_to_side"):
					if is_treasure_stack_hovered:
						var top_card := _get_top_treasure_card()
						if top_card != null and top_card.has_method("is_face_up_now"):
							if not top_card.is_face_up_now():
								pending_flip_card = top_card
								pending_flip_is_adventure = false
								return
					elif is_adventure_stack_hovered:
						var top_adv := _get_top_adventure_card()
						if top_adv != null and top_adv.has_method("is_face_up_now"):
							if not top_adv.is_face_up_now():
								pending_flip_card = top_adv
								pending_flip_is_adventure = true
								return
				dragged_card = card
				dragged_card_origin_y = card.global_position.y
				if dragged_card.has_method("set_dragging"):
					dragged_card.set_dragging(true)
				var hit := _ray_to_plane(event.position)
				if hit != Vector3.INF:
					drag_offset = dragged_card.global_position - hit
		else:
			if dragged_card != null and dragged_card.has_method("set_dragging"):
				dragged_card.set_dragging(false)
			if dragged_card != null:
				var pos := dragged_card.global_position
				pos.y = dragged_card_origin_y + 0.003
				dragged_card.global_position = pos
				if y_label != null:
					y_label.text = "Y carta: %.3f" % pos.y
				if dragged_card.has_method("set_sorting_offset"):
					_update_all_card_sorting_offsets(dragged_card)
				if dragged_card.has_meta("in_treasure_stack") and dragged_card.get_meta("in_treasure_stack", false):
					_update_treasure_stack_position(dragged_card.global_position)
				elif dragged_card.has_meta("in_adventure_stack") and dragged_card.get_meta("in_adventure_stack", false):
					_update_adventure_stack_position(dragged_card.global_position)
				elif dragged_card.has_meta("in_boss_stack") and dragged_card.get_meta("in_boss_stack", false):
					_update_boss_stack_position(dragged_card.global_position)
			dragged_card = null
			var moved := mouse_down_pos.distance_to(event.position) > CLICK_DRAG_THRESHOLD
			if not moved and pending_flip_card != null and is_instance_valid(pending_flip_card):
				if pending_flip_is_adventure:
					_try_show_adventure_prompt(pending_flip_card)
				else:
					var target_pos := treasure_reveal_pos
					target_pos.y = treasure_reveal_pos.y + (revealed_treasure_count * REVEALED_Y_STEP)
					pending_flip_card.set_meta("in_treasure_stack", false)
					pending_flip_card.set_meta("in_treasure_market", true)
					pending_flip_card.set_meta("market_index", revealed_treasure_count)
					pending_flip_card.call("flip_to_side", target_pos)
					revealed_treasure_count += 1
			pending_flip_card = null
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			last_mouse_pos = event.position
			var card := _get_card_under_mouse(event.position)
			if card != null and phase_index == 0:
				var top_market := _get_top_market_card()
				if top_market != null and card == top_market:
					_try_show_purchase_prompt(card, false)
		pan_active = false
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom(-1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom(1.0)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	last_mouse_pos = event.position
	if pan_active:
		return
	if dragged_card == null:
		_update_hover(event.position)

func _zoom(direction: float) -> void:
	var pos := camera.global_position
	pos.y = clamp(pos.y + direction, 3.0, 80.0)
	camera.global_position = pos

func _release_launch(mouse_pos: Vector2) -> void:
	if launch_start_time < 0.0:
		return
	var held: float = max(0.0, (Time.get_ticks_msec() / 1000.0) - launch_start_time)
	launch_start_time = -1.0
	var hit: Vector3 = _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	_launch_dice_at(hit, held)

func _process(_delta: float) -> void:
	if dragged_card != null:
		var hit := _ray_to_plane(last_mouse_pos)
		if hit != Vector3.INF:
			var target := hit + drag_offset
			target.y = TABLE_Y + DRAG_HEIGHT
			dragged_card.global_position = target
		_sync_equipment_slots_root()
		return
	_sync_equipment_slots_root()
	_update_hover(last_mouse_pos)
	_update_purchase_prompt_position()
	_update_adventure_prompt_position()
	_update_camera_label()
	_update_regno_overlay()

func _launch_dice_at(spawn_pos: Vector3, hold_time: float) -> void:
	_clear_dice()
	_spawn_dice(spawn_pos, hold_time)
	dice_count += 1
	_track_dice_sum()

func _spawn_dice(spawn_pos: Vector3, hold_time: float) -> void:
	var hold_scale: float = clamp(0.6 + hold_time * 1.2, 0.6, 2.0)
	for i in dice_count:
		var dice: RigidBody3D = DICE_SCENE.instantiate() as RigidBody3D
		add_child(dice)
		dice.global_position = spawn_pos + Vector3(i * 0.6, 2.0, 0.0)
		dice.global_rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		var lateral_strength := randf_range(1.2, 2.0) * hold_scale
		var lateral_angle := randf() * TAU
		var impulse: Vector3 = Vector3(
			cos(lateral_angle) * lateral_strength,
			randf_range(4.0, 5.0) * hold_scale,
			sin(lateral_angle) * lateral_strength
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
	var _viewport := get_viewport()
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	if abs(direction.y) < 0.0001:
		return Vector3.INF
	var t := (TABLE_Y - origin.y) / direction.y
	if t < 0.0:
		return Vector3.INF
	return origin + direction * t

func _get_card_under_mouse(mouse_pos: Vector2) -> Node3D:
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 2
	query.collision_mask = 2
	query.hit_from_inside = true
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var node: Node = result.get("collider") as Node
	while node != null:
		if node.has_method("set_highlighted"):
			if node.has_meta("in_treasure_stack") and node.get_meta("in_treasure_stack", false):
				return _get_top_treasure_card()
			if node.has_meta("in_adventure_stack") and node.get_meta("in_adventure_stack", false):
				return _get_top_adventure_card()
			return node
		node = node.get_parent()
	return null

func _get_top_treasure_card() -> Node3D:
	var top_card: Node3D = null
	var top_index := -1
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_stack"):
			continue
		if not child.get_meta("in_treasure_stack", false):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
			top_card = child
	return top_card

func _discard_revealed_treasure_cards() -> void:
	var discarded_any := false
	for child in get_children():
		if not child.has_meta("in_treasure_market"):
			continue
		if not child.get_meta("in_treasure_market", false):
			continue
		child.set_meta("discard_index", discarded_treasure_count)
		child.set_meta("in_treasure_market", false)
		discarded_treasure_count += 1
		discarded_any = true
	if discarded_any:
		revealed_treasure_count = 0
	_reposition_discard_stack()

func _update_treasure_stack_position(new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, treasure_deck_pos.y, new_pos.z)
	treasure_deck_pos = base
	treasure_reveal_pos = treasure_deck_pos + TREASURE_REVEAL_OFFSET
	treasure_discard_pos = treasure_deck_pos + TREASURE_DISCARD_OFFSET
	_reposition_stack("in_treasure_stack", treasure_deck_pos)
	_reposition_market_stack()
	_reposition_discard_stack()

func _update_adventure_stack_position(new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, adventure_deck_pos.y, new_pos.z)
	adventure_deck_pos = base
	adventure_reveal_pos = adventure_deck_pos + ADVENTURE_REVEAL_OFFSET
	_reposition_stack("in_adventure_stack", adventure_deck_pos)

func _update_boss_stack_position(new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, boss_deck_pos.y, new_pos.z)
	boss_deck_pos = base + BOSS_STACK_OFFSET
	_reposition_stack("in_boss_stack", boss_deck_pos)

func _reposition_stack(meta_key: String, base_pos: Vector3) -> void:
	var cards: Array = []
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta(meta_key):
			continue
		if not child.get_meta(meta_key, false):
			continue
		cards.append(child)
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("stack_index", -1))
		var b_idx := int(b.get_meta("stack_index", -1))
		return a_idx < b_idx
	)
	for card in cards:
		var idx: int = int(card.get_meta("stack_index", 0))
		var pos := base_pos + Vector3(0.0, idx * REVEALED_Y_STEP, 0.0)
		card.global_position = pos

func _reposition_market_stack() -> void:
	var cards: Array = []
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_market"):
			continue
		if not child.get_meta("in_treasure_market", false):
			continue
		cards.append(child)
	if cards.is_empty():
		return
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("market_index", -1))
		var b_idx := int(b.get_meta("market_index", -1))
		if a_idx == -1 or b_idx == -1:
			return (a as Node3D).global_position.y < (b as Node3D).global_position.y
		return a_idx < b_idx
	)
	for i in cards.size():
		var card: Node3D = cards[i]
		if int(card.get_meta("market_index", -1)) < 0:
			card.set_meta("market_index", i)
		var pos := treasure_reveal_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)
		card.global_position = pos

func _reposition_discard_stack() -> void:
	var cards: Array = []
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("discard_index"):
			continue
		cards.append(child)
	if cards.is_empty():
		return
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("discard_index", -1))
		var b_idx := int(b.get_meta("discard_index", -1))
		return a_idx < b_idx
	)
	for i in cards.size():
		var card: Node3D = cards[i]
		var pos := treasure_discard_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)
		card.global_position = pos

func _get_top_adventure_card() -> Node3D:
	var top_card: Node3D = null
	var top_index := -1
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_adventure_stack"):
			continue
		if not child.get_meta("in_adventure_stack", false):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
			top_card = child
	return top_card

func _get_top_market_card() -> Node3D:
	var top_card: Node3D = null
	var top_y := -INF
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_market"):
			continue
		if not child.get_meta("in_treasure_market", false):
			continue
		var y := (child as Node3D).global_position.y
		if y > top_y:
			top_y = y
			top_card = child
	return top_card

func _try_show_purchase_prompt(card: Node3D, require_gold: bool = true) -> bool:
	if not card.has_meta("in_treasure_market"):
		return false
	if not card.get_meta("in_treasure_market", false):
		return false
	if not card.has_meta("card_data"):
		return false
	if purchase_panel == null:
		return false
	var card_data: Dictionary = card.get_meta("card_data", {})
	var cost := int(card_data.get("cost", 0))
	if cost <= 0:
		return false
	if require_gold and player_gold < cost:
		return false
	purchase_card = card
	purchase_label.text = "Vuoi  aggiungerla  alla  tua  mano  per  il  prezzo  di  %d  monete?" % cost
	purchase_panel.visible = true
	_resize_purchase_prompt()
	_update_purchase_prompt_position()
	return true

func _hide_purchase_prompt() -> void:
	if purchase_panel != null:
		purchase_panel.visible = false
	purchase_card = null

func _update_purchase_prompt_position() -> void:
	if purchase_panel == null or not purchase_panel.visible:
		return
	if purchase_card == null or not is_instance_valid(purchase_card):
		_hide_purchase_prompt()
		return
	var screen_pos := camera.unproject_position(purchase_card.global_position)
	var size := purchase_panel.size
	purchase_panel.position = screen_pos + Vector2(-size.x * 0.5, -size.y - 16.0)

func _resize_purchase_prompt() -> void:
	if purchase_panel == null:
		return
	purchase_panel.custom_minimum_size = Vector2.ZERO
	purchase_panel.reset_size()
	if purchase_content != null:
		purchase_panel.custom_minimum_size = purchase_content.get_combined_minimum_size()
	else:
		purchase_panel.custom_minimum_size = purchase_panel.get_combined_minimum_size()
	purchase_panel.reset_size()

func _confirm_purchase() -> void:
	if phase_index != 0:
		_hide_purchase_prompt()
		return
	if purchase_card == null or not is_instance_valid(purchase_card):
		_hide_purchase_prompt()
		return
	var card_data: Dictionary = purchase_card.get_meta("card_data", {})
	var cost := int(card_data.get("cost", 0))
	if cost <= 0 or player_gold < cost:
		_hide_purchase_prompt()
		return
	player_gold -= cost
	player_hand.append(card_data)
	if revealed_treasure_count > 0:
		revealed_treasure_count -= 1
	purchase_card.queue_free()
	_refresh_hand_ui()
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)
	_hide_purchase_prompt()

func _on_phase_changed(new_phase_index: int, _turn_index: int) -> void:
	phase_index = new_phase_index
	if phase_index != 0:
		_hide_purchase_prompt()
	if phase_index != 1:
		_hide_adventure_prompt()

func _try_show_adventure_prompt(card: Node3D) -> void:
	if phase_index != 1:
		return
	pending_adventure_card = card
	adventure_prompt_panel.visible = true
	_resize_adventure_prompt()
	_update_adventure_prompt_position()

func _hide_adventure_prompt() -> void:
	if adventure_prompt_panel != null:
		adventure_prompt_panel.visible = false
	pending_adventure_card = null

func _confirm_adventure_prompt() -> void:
	if pending_adventure_card == null or not is_instance_valid(pending_adventure_card):
		_hide_adventure_prompt()
		return
	var target_pos_adv := adventure_reveal_pos
	target_pos_adv.y = adventure_reveal_pos.y + (revealed_adventure_count * REVEALED_Y_STEP)
	pending_adventure_card.set_meta("in_adventure_stack", false)
	pending_adventure_card.call("flip_to_side", target_pos_adv)
	revealed_adventure_count += 1
	_hide_adventure_prompt()

func _resize_adventure_prompt() -> void:
	if adventure_prompt_panel == null:
		return
	adventure_prompt_panel.custom_minimum_size = Vector2.ZERO
	adventure_prompt_panel.reset_size()
	adventure_prompt_panel.custom_minimum_size = adventure_prompt_panel.get_combined_minimum_size()
	adventure_prompt_panel.reset_size()

func _update_adventure_prompt_position() -> void:
	if adventure_prompt_panel == null or not adventure_prompt_panel.visible:
		return
	if pending_adventure_card == null or not is_instance_valid(pending_adventure_card):
		_hide_adventure_prompt()
		return
	var screen_pos := camera.unproject_position(pending_adventure_card.global_position)
	var size := adventure_prompt_panel.size
	adventure_prompt_panel.position = screen_pos + Vector2(-size.x * 0.5, -size.y - 16.0)


func _adjust_selected_card_y(delta: float) -> void:
	if selected_card == null:
		return
	var pos := selected_card.global_position
	pos.y += delta
	selected_card.global_position = pos
	if y_label != null:
		y_label.text = "Y carta: %.3f" % pos.y

func _spawn_sum_label() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	sum_label = Label.new()
	sum_label.text = "Somma: -"
	sum_label.position = Vector2(20, 20)
	ui.add_child(sum_label)
	y_label = Label.new()
	y_label.text = "Y carta: -"
	y_label.position = Vector2(20, 50)
	ui.add_child(y_label)
	camera_label = Label.new()
	camera_label.text = "Camera: -"
	camera_label.position = Vector2(20, 80)
	ui.add_child(camera_label)
	_create_purchase_prompt()

func _update_camera_label() -> void:
	if camera_label == null:
		return
	var pos := camera.global_position
	camera_label.text = "Camera: x=%.2f y=%.2f z=%.2f" % [pos.x, pos.y, pos.z]

func _create_purchase_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 10
	add_child(prompt_layer)
	purchase_panel = PanelContainer.new()
	purchase_panel.visible = false
	purchase_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	purchase_panel.z_index = 200
	purchase_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	purchase_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	purchase_panel.add_theme_stylebox_override("panel", panel_style)

	purchase_content = VBoxContainer.new()
	purchase_content.anchor_left = 0.0
	purchase_content.anchor_right = 1.0
	purchase_content.anchor_top = 0.0
	purchase_content.anchor_bottom = 1.0
	purchase_content.offset_left = 16.0
	purchase_content.offset_right = -16.0
	purchase_content.offset_top = 12.0
	purchase_content.offset_bottom = -12.0
	purchase_content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	purchase_content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	purchase_content.set("theme_override_constants/separation", 10)
	purchase_content.mouse_filter = Control.MOUSE_FILTER_PASS

	purchase_label = Label.new()
	purchase_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	purchase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	purchase_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	purchase_label.custom_minimum_size = Vector2(420, 0)
	purchase_label.add_theme_font_override("font", UI_FONT)
	purchase_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	purchase_label.add_theme_constant_override("font_spacing/space", 8)
	purchase_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	purchase_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	purchase_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	purchase_content.add_child(purchase_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_row.set("theme_override_constants/separation", 20)
	purchase_yes_button = Button.new()
	purchase_yes_button.text = "Si"
	purchase_yes_button.add_theme_font_override("font", UI_FONT)
	purchase_yes_button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	purchase_yes_button.add_theme_constant_override("font_spacing/space", 8)
	purchase_yes_button.pressed.connect(_confirm_purchase)
	purchase_no_button = Button.new()
	purchase_no_button.text = "No"
	purchase_no_button.add_theme_font_override("font", UI_FONT)
	purchase_no_button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	purchase_no_button.add_theme_constant_override("font_spacing/space", 8)
	purchase_no_button.pressed.connect(_hide_purchase_prompt)
	button_row.add_child(purchase_yes_button)
	button_row.add_child(purchase_no_button)
	purchase_content.add_child(button_row)

	purchase_panel.add_child(purchase_content)
	prompt_layer.add_child(purchase_panel)

func _create_adventure_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 11
	add_child(prompt_layer)
	adventure_prompt_panel = PanelContainer.new()
	adventure_prompt_panel.visible = false
	adventure_prompt_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	adventure_prompt_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	adventure_prompt_panel.add_theme_stylebox_override("panel", panel_style)

	var content := VBoxContainer.new()
	content.anchor_left = 0.0
	content.anchor_right = 1.0
	content.anchor_top = 0.0
	content.anchor_bottom = 1.0
	content.offset_left = 16.0
	content.offset_right = -16.0
	content.offset_top = 12.0
	content.offset_bottom = -12.0
	content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.set("theme_override_constants/separation", 10)

	adventure_prompt_label = Label.new()
	adventure_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	adventure_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	adventure_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	adventure_prompt_label.custom_minimum_size = Vector2(420, 0)
	adventure_prompt_label.text = "Vuoi affrontare una nuova avventura?"
	adventure_prompt_label.add_theme_font_override("font", UI_FONT)
	adventure_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(adventure_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.set("theme_override_constants/separation", 20)
	adventure_prompt_yes = Button.new()
	adventure_prompt_yes.text = "Si"
	adventure_prompt_yes.add_theme_font_override("font", UI_FONT)
	adventure_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	adventure_prompt_yes.pressed.connect(_confirm_adventure_prompt)
	adventure_prompt_no = Button.new()
	adventure_prompt_no.text = "No"
	adventure_prompt_no.add_theme_font_override("font", UI_FONT)
	adventure_prompt_no.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_prompt_no.add_theme_constant_override("font_spacing/space", 8)
	adventure_prompt_no.pressed.connect(_hide_adventure_prompt)
	button_row.add_child(adventure_prompt_yes)
	button_row.add_child(adventure_prompt_no)
	content.add_child(button_row)

	adventure_prompt_panel.add_child(content)
	prompt_layer.add_child(adventure_prompt_panel)

func _spawn_hand_ui() -> void:
	var hand_layer := CanvasLayer.new()
	add_child(hand_layer)

	var hand_root := Control.new()
	hand_root.anchor_left = 0.0
	hand_root.anchor_right = 1.0
	hand_root.anchor_top = 0.8
	hand_root.anchor_bottom = 1.0
	hand_root.offset_left = 0.0
	hand_root.offset_right = 0.0
	hand_root.offset_top = 0.0
	hand_root.offset_bottom = 0.0
	hand_root.set_script(HAND_UI_SCRIPT)
	hand_layer.add_child(hand_root)
	hand_ui = hand_root
	if hand_root.has_signal("request_place_equipment"):
		hand_root.connect("request_place_equipment", Callable(self, "_on_hand_request_place_equipment"))
	if hand_root.has_signal("phase_changed"):
		hand_root.connect("phase_changed", Callable(self, "_on_phase_changed"))

	var view_size := get_viewport().get_visible_rect().size
	var card_height := view_size.y * 0.2
	if hand_root.has_method("populate"):
		hand_root.call("populate", player_hand, card_height)
	if hand_root.has_method("set_gold"):
		hand_root.call("set_gold", player_gold)
	_update_hand_ui_stats()


func _init_player_hand() -> void:
	player_hand.clear()
	var context := {
		"deck_treasures": CardDatabase.deck_treasures,
		"hand": player_hand
	}
	AbilityRegistry.apply("draw_treasure_vaso_di_coccio", context)
	player_hand = context["hand"]

func _update_hover(mouse_pos: Vector2) -> void:
	var card := _get_card_under_mouse(mouse_pos)
	is_treasure_stack_hovered = false
	is_adventure_stack_hovered = false
	if card != null and card.has_meta("in_treasure_stack") and card.get_meta("in_treasure_stack", false):
		is_treasure_stack_hovered = true
		var top_card := _get_top_treasure_card()
		if top_card != null:
			card = top_card
	elif card != null and card.has_meta("in_adventure_stack") and card.get_meta("in_adventure_stack", false):
		is_adventure_stack_hovered = true
		var top_adv := _get_top_adventure_card()
		if top_adv != null:
			card = top_adv
	if card == hovered_card:
		return
	if hovered_card != null and hovered_card.has_method("set_highlighted"):
		hovered_card.set_highlighted(false)
	hovered_card = card
	if hovered_card != null and hovered_card.has_method("set_highlighted"):
		hovered_card.set_highlighted(true)


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

func _update_all_card_sorting_offsets(released_card: Node3D) -> void:
	# Raccogli tutte le carte (esclusa quella rilasciata)
	var all_cards: Array[Node3D] = []
	for child in get_children():
		if child is Node3D and child != released_card:
			if child.has_method("set_sorting_offset"):
				all_cards.append(child)
	
	# Assegna offset incrementali alle carte esistenti, partendo da 1
	var offset := 1.0
	for card in all_cards:
		card.call("set_sorting_offset", offset)
		offset += 1.0
	
	# La carta rilasciata ottiene l'offset più alto
	top_sorting_offset = offset + 10.0  # Margine extra per sicurezza
	released_card.call("set_sorting_offset", top_sorting_offset)


func _spawn_placeholders() -> void:
	pass

func _spawn_treasure_cards() -> void:
	var treasures: Array = []
	for entry in CardDatabase.deck_treasures:
		if str(entry.get("set", "")) != "GnG":
			continue
		treasures.append(entry)
	DECK_UTILS.shuffle_deck(treasures)

	var stack_step := REVEALED_Y_STEP
	for i in treasures.size():
		var card := CARD_SCENE.instantiate()
		card.color = Color(0.2, 0.2, 0.4, 1.0)
		add_child(card)
		card.global_position = treasure_deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_treasure_stack", true)
		card.set_meta("card_data", treasures[i])
		card.set_meta("in_treasure_market", false)
		card.set_meta("stack_index", i)
		var image_path := str(treasures[i].get("image", ""))
		if not image_path.is_empty() and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", "res://assets/cards/ghost_n_goblins/treasure/back_treasure.png")
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

func _spawn_tokens() -> void:
	pass

func _spawn_character_hearts(card: Node3D) -> void:
	var hearts := _get_character_hearts()
	if hearts <= 0:
		return
	var start_x := -0.45
	var spacing := 0.3
	for i in hearts:
		var token := TOKEN_SCENE.instantiate()
		card.add_child(token)
		token.position = Vector3(start_x + i * spacing, 0.02, 0.0)
		token.rotation = Vector3(-PI / 2.0, deg_to_rad(randf_range(-4.0, 4.0)), 0.0)
		token.scale = Vector3(0.78, 0.78, 0.78)
		if token.has_method("set_token_texture"):
			token.call_deferred("set_token_texture", HEART_TEXTURE)

func _get_character_hearts() -> int:
	for entry in CardDatabase.cards_characters:
		if str(entry.get("id", "")) == "character_sir_arthur_a":
			var stats: Dictionary = entry.get("stats", {})
			return int(stats.get("start_hearts", 0))
	return 0

func _get_character_stats() -> Dictionary:
	for entry in CardDatabase.cards_characters:
		if str(entry.get("id", "")) == "character_sir_arthur_a":
			return entry.get("stats", {})
	return {}

func _spawn_adventure_cards() -> void:
	var adventures: Array = []
	for entry in CardDatabase.deck_adventure:
		if str(entry.get("set", "")) != "GnG":
			continue
		adventures.append(entry)
	DECK_UTILS.shuffle_deck(adventures)

	var stack_step := REVEALED_Y_STEP
	for i in adventures.size():
		var card := CARD_SCENE.instantiate()
		card.color = Color(0.35, 0.15, 0.15, 1.0)
		add_child(card)
		card.global_position = adventure_deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_adventure_stack", true)
		card.set_meta("stack_index", i)
		var image_path := _get_adventure_image_path(adventures[i])
		if card.has_method("set_texture_flip_x"):
			card.call_deferred("set_texture_flip_x", false)
		if image_path != "" and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", ADVENTURE_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

func _spawn_boss_cards() -> void:
	var bosses: Array = []
	for entry in CardDatabase.deck_boss:
		if str(entry.get("set", "")) != "GnG":
			continue
		bosses.append(entry)
	DECK_UTILS.shuffle_deck(bosses)

	var stack_step := REVEALED_Y_STEP
	var deck_pos := boss_deck_pos
	for i in bosses.size():
		var card := CARD_SCENE.instantiate()
		card.color = Color(0.3, 0.2, 0.2, 1.0)
		add_child(card)
		card.global_position = deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_boss_stack", true)
		card.set_meta("stack_index", i)
		var image_path := str(bosses[i].get("image", ""))
		if image_path.is_empty():
			image_path = _find_boss_image(bosses[i])
		if image_path != "" and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", BOSS_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

func _find_boss_image(card: Dictionary) -> String:
	var card_name := _normalize_name(str(card.get("name", "")))
	var dir := DirAccess.open("res://assets/cards/ghost_n_goblins/boss")
	if dir == null:
		return ""
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			var base := _normalize_name(file_name.get_basename())
			if base == card_name:
				dir.list_dir_end()
				return "%s/%s" % ["res://assets/cards/ghost_n_goblins/boss", file_name]
		file_name = dir.get_next()
	dir.list_dir_end()
	return ""

func _spawn_character_card() -> void:
	var card := CARD_SCENE.instantiate()
	add_child(card)
	card.global_position = character_pos
	card.rotate_x(-PI / 2.0)
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", CHARACTER_FRONT)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", CHARACTER_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	character_card = card
	_init_character_stats()
	_spawn_character_hearts(card)
	_spawn_equipment_slots(card)

func _init_character_stats() -> void:
	var stats := _get_character_stats()
	player_max_hand = int(stats.get("max_hand", 0))
	player_max_hearts = int(stats.get("max_hearts", 0))
	player_current_hearts = int(stats.get("start_hearts", 0))
	_update_hand_ui_stats()

func _spawn_equipment_slots(card: Node3D) -> void:
	equipment_slots.clear()
	var max_slots := _get_character_max_slots()
	if max_slots <= 0:
		return
	var slots_root := card.get_node_or_null("EquipmentSlots") as Node3D
	if slots_root != null:
		slots_root.queue_free()
		slots_root = null
	slots_root = Node3D.new()
	slots_root.name = "EquipmentSlots"
	slots_root.top_level = true
	card.add_child(slots_root)
	equipment_slots_root = slots_root
	for i in max_slots:
		var slot := Area3D.new()
		slot.collision_layer = 4
		slot.collision_mask = 0
		slot.set_meta("equipment_slot", true)
		slot.set_meta("slot_index", i)
		slots_root.add_child(slot)

		var mesh := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(EQUIP_SLOT_WIDTH, EQUIP_SLOT_HEIGHT)
		mesh.mesh = quad
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.1, 0.1, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.9
		mesh.material_override = mat
		mesh.position = Vector3(0.0, 0.0, 0.0)
		mesh.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
		slot.add_child(mesh)

		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(EQUIP_SLOT_WIDTH, 0.05, EQUIP_SLOT_HEIGHT)
		shape.shape = box
		shape.position = Vector3(0.0, 0.0, 0.0)
		slot.add_child(shape)

		equipment_slots.append(slot)
	_reposition_equipment_slots()
	_sync_equipment_slots_root()

func _adjust_equipment_slots_y(delta: float) -> void:
	equipment_slots_y_offset += delta
	_sync_equipment_slots_root()

func _sync_equipment_slots_root() -> void:
	if equipment_slots_root == null or character_card == null:
		return
	var base_pos := character_card.global_position
	equipment_slots_root.global_position = Vector3(
		base_pos.x + CARD_CENTER_X_OFFSET,
		TABLE_Y + equipment_slots_y_offset,
		base_pos.z + equipment_slots_z_offset
	)

func _reposition_equipment_slots() -> void:
	var count := equipment_slots.size()
	if count <= 0:
		return
	var total_width := (count * EQUIP_SLOT_WIDTH) + ((count - 1) * EQUIP_SLOT_SPACING)
	var start_x := -(total_width * 0.5) + (EQUIP_SLOT_WIDTH * 0.5)
	var base_z := equipment_slots_z_offset
	for i in count:
		var slot := equipment_slots[i]
		if slot == null:
			continue
		slot.position = Vector3(start_x + i * (EQUIP_SLOT_WIDTH + EQUIP_SLOT_SPACING), 0.0, base_z)

func _get_character_max_slots() -> int:
	for entry in CardDatabase.cards_characters:
		if str(entry.get("id", "")) == "character_sir_arthur_a":
			var stats: Dictionary = entry.get("stats", {})
			return int(stats.get("max_slots", 0))
	return 0

func _on_hand_request_place_equipment(card: Dictionary, screen_pos: Vector2) -> void:
	if phase_index != 0:
		return
	var card_type := str(card.get("type", "")).strip_edges().to_lower()
	if card_type != "equipaggiamento":
		return
	var slot := _get_equipment_slot_under_mouse(screen_pos)
	if slot == null:
		slot = _get_first_free_equipment_slot()
	if slot == null:
		return
	if slot.has_meta("occupied") and slot.get_meta("occupied", false):
		return
	_place_equipment_in_slot(slot, card)
	player_hand.erase(card)
	_refresh_hand_ui()

func _get_equipment_slot_under_mouse(mouse_pos: Vector2) -> Area3D:
	var origin := camera.project_ray_origin(mouse_pos)
	var direction := camera.project_ray_normal(mouse_pos)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 4
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var node: Node = result.get("collider") as Node
	while node != null:
		if node.has_meta("equipment_slot"):
			return node as Area3D
		node = node.get_parent()
	return null

func _get_first_free_equipment_slot() -> Area3D:
	var slots_sorted := equipment_slots.duplicate()
	slots_sorted.sort_custom(func(a, b):
		if a == null or b == null:
			return false
		var a_idx := int(a.get_meta("slot_index", 0))
		var b_idx := int(b.get_meta("slot_index", 0))
		return a_idx < b_idx
	)
	for slot in slots_sorted:
		if slot == null:
			continue
		if slot.has_meta("occupied") and slot.get_meta("occupied", false):
			continue
		return slot
	return null

func _place_equipment_in_slot(slot: Area3D, card_data: Dictionary) -> void:
	var card := CARD_SCENE.instantiate()
	slot.add_child(card)
	card.position = Vector3(-CARD_CENTER_X_OFFSET, 0.01, 0.0)
	card.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	card.set_meta("card_data", card_data)
	if card.has_method("set_card_texture"):
		var image_path := str(card_data.get("image", ""))
		if image_path != "":
			card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	slot.set_meta("occupied", true)
	slot.set_meta("equipped_card", card)
	card.set_meta("equipped_slot", slot)
	_apply_equipment_extra_slots(card_data)

func _apply_equipment_extra_slots(card_data: Dictionary) -> void:
	var effects: Array = card_data.get("effects", [])
	var extra := 0
	for effect in effects:
		var name := str(effect)
		if name == "armor_extra_slot_1":
			extra += 1
		elif name == "armor_extra_slot_2":
			extra += 2
	if extra <= 0:
		return
	_add_equipment_slots(extra)

func _add_equipment_slots(extra: int) -> void:
	if equipment_slots_root == null:
		return
	for i in extra:
		var slot := Area3D.new()
		slot.collision_layer = 4
		slot.collision_mask = 0
		slot.set_meta("equipment_slot", true)
		slot.set_meta("slot_index", equipment_slots.size())
		equipment_slots_root.add_child(slot)

		var mesh := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(EQUIP_SLOT_WIDTH, EQUIP_SLOT_HEIGHT)
		mesh.mesh = quad
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.1, 0.1, 0.5)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.9
		mesh.material_override = mat
		mesh.position = Vector3(0.0, 0.0, 0.0)
		mesh.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
		slot.add_child(mesh)

		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(EQUIP_SLOT_WIDTH, 0.05, EQUIP_SLOT_HEIGHT)
		shape.shape = box
		shape.position = Vector3(0.0, 0.0, 0.0)
		slot.add_child(shape)

		equipment_slots.append(slot)
	_reposition_equipment_slots()
	_sync_equipment_slots_root()

func _refresh_hand_ui() -> void:
	for child in get_children():
		if child is CanvasLayer:
			for ui in child.get_children():
				if ui.has_method("populate"):
					var view_size := get_viewport().get_visible_rect().size
					var card_height := view_size.y * 0.2
					ui.call("populate", player_hand, card_height)
	_update_hand_ui_stats()

func _update_hand_ui_stats() -> void:
	if hand_ui == null:
		return
	if hand_ui.has_method("set_hearts"):
		hand_ui.call("set_hearts", player_current_hearts, player_max_hearts)
	if hand_ui.has_method("set_cards"):
		hand_ui.call("set_cards", player_hand.size(), player_max_hand)

func _return_equipped_to_hand(card: Node3D) -> void:
	if phase_index != 0:
		return
	if not card.has_meta("equipped_slot"):
		return
	var slot := card.get_meta("equipped_slot") as Area3D
	if slot != null:
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		card_data = {
			"image": ""
		}
	player_hand.append(card_data)
	card.queue_free()
	_refresh_hand_ui()

func _spawn_regno_del_male() -> void:
	var card := CARD_SCENE.instantiate()
	add_child(card)
	card.global_position = regno_pos
	card.rotate_x(-PI / 2.0)
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", REGNO_FRONT)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", REGNO_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	regno_card = card

func _setup_regno_overlay() -> void:
	regno_track_nodes = _get_regno_track_nodes()
	if regno_track_nodes.is_empty():
		return
	if regno_overlay_layer != null and is_instance_valid(regno_overlay_layer):
		regno_overlay_layer.queue_free()
	regno_overlay_layer = CanvasLayer.new()
	add_child(regno_overlay_layer)
	regno_overlay = Control.new()
	regno_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	regno_overlay_layer.add_child(regno_overlay)
	regno_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	regno_overlay.offset_left = 0
	regno_overlay.offset_top = 0
	regno_overlay.offset_right = 0
	regno_overlay.offset_bottom = 0
	_build_regno_boxes()

func _build_regno_boxes() -> void:
	for node in regno_node_boxes:
		if node != null and node.is_inside_tree():
			node.queue_free()
	regno_node_boxes.clear()
	for i in regno_track_nodes.size():
		var box := PanelContainer.new()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.border_color = Color(1.0, 0.9, 0.2, 0.0)
		style.set_border_width_all(3)
		box.add_theme_stylebox_override("panel", style)
		regno_overlay.add_child(box)
		regno_node_boxes.append(box)

func _update_regno_overlay() -> void:
	if regno_overlay == null or regno_track_nodes.is_empty():
		return
	if regno_card == null or not is_instance_valid(regno_card):
		return
	var rect := _get_card_screen_rect(regno_card)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	regno_blink_time = Time.get_ticks_msec() / 1000.0
	for i in regno_track_nodes.size():
		if i >= regno_node_boxes.size():
			continue
		var data: Dictionary = regno_track_nodes[i]
		var x := float(data.get("x", 0.0))
		var y := float(data.get("y", 0.0))
		var w := float(data.get("w", 0.0))
		var h := float(data.get("h", 0.0))
		var box: PanelContainer = regno_node_boxes[i]
		box.position = rect.position + Vector2(x * rect.size.x, y * rect.size.y)
		var size: Vector2 = Vector2(w * rect.size.x, h * rect.size.y)
		var side: float = max(size.x, size.y)
		box.size = Vector2(side, side)
		var style: StyleBoxFlat = box.get_theme_stylebox("panel") as StyleBoxFlat
		if style != null:
			if i == regno_track_index:
				var alpha: float = 0.25 + 0.55 * abs(sin(regno_blink_time * 3.0))
				style.border_color = Color(1.0, 0.9, 0.2, alpha)
			else:
				style.border_color = Color(1.0, 0.9, 0.2, 0.0)
			box.add_theme_stylebox_override("panel", style)

func _get_card_screen_rect(card: Node3D) -> Rect2:
	var mesh := card.get_node_or_null("Pivot/Mesh") as MeshInstance3D
	if mesh == null:
		return Rect2()
	var quad := mesh.mesh as QuadMesh
	var size := Vector2(1.4, 2.0)
	if quad != null:
		size = quad.size
	var half := size * 0.5
	var local_corners := [
		Vector3(-half.x, -half.y, 0.0),
		Vector3(half.x, -half.y, 0.0),
		Vector3(half.x, half.y, 0.0),
		Vector3(-half.x, half.y, 0.0)
	]
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	for p in local_corners:
		var world: Vector3 = mesh.global_transform * p
		var screen: Vector2 = camera.unproject_position(world)
		min_x = min(min_x, screen.x)
		min_y = min(min_y, screen.y)
		max_x = max(max_x, screen.x)
		max_y = max(max_y, screen.y)
	if min_x == INF:
		return Rect2()
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

func _get_regno_track_nodes() -> Array:
	for entry in CardDatabase.deck_adventure:
		if str(entry.get("id", "")) == "shared_regno_del_male":
			var nodes: Array = entry.get("track_nodes", [])
			if nodes is Array:
				return nodes
	return []

func _spawn_astaroth() -> void:
	var card := CARD_SCENE.instantiate()
	add_child(card)
	card.global_position = astaroth_pos
	card.rotate_x(-PI / 2.0)
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", ASTAROTH_FRONT)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", BOSS_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)

func _build_adventure_image_index() -> void:
	adventure_image_index.clear()
	var dir := DirAccess.open("res://assets/cards/ghost_n_goblins/adventure")
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			if file_name.to_lower().contains("back"):
				file_name = dir.get_next()
				continue
			var base := _normalize_name(file_name.get_basename())
			var key := _strip_variant_suffix(base)
			if not adventure_image_index.has(key):
				adventure_image_index[key] = []
			adventure_image_index[key].append("%s/%s" % ["res://assets/cards/ghost_n_goblins/adventure", file_name])
		file_name = dir.get_next()
	dir.list_dir_end()

func _get_adventure_image_path(card: Dictionary) -> String:
	var card_name := _normalize_name(str(card.get("name", "")))
	var key := _strip_variant_suffix(card_name)
	if not adventure_image_index.has(key):
		return ""
	if not adventure_variant_cursor.has(key):
		adventure_variant_cursor[key] = 0
	var list: Array = adventure_image_index[key]
	if list.is_empty():
		return ""
	var idx := int(adventure_variant_cursor[key]) % list.size()
	adventure_variant_cursor[key] = idx + 1
	return str(list[idx])

func _normalize_name(card_name: String) -> String:
	var s := card_name.to_lower()
	s = s.replace("_", " ")
	s = s.replace("à", "a").replace("è", "e").replace("é", "e").replace("ì", "i").replace("ò", "o").replace("ù", "u")
	var out := ""
	for i in s.length():
		var ch := s[i]
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == " ":
			out += ch
	return out.strip_edges()

func _play_music() -> void:
	if MUSIC_TRACK == null:
		return
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC_TRACK
	music_player.autoplay = true
	music_player.volume_db = -20.0
	music_player.bus = "Master"
	add_child(music_player)

func _strip_variant_suffix(card_name: String) -> String:
	var parts := card_name.split(" ")
	if parts.size() > 1:
		var last := parts[parts.size() - 1]
		if last.is_valid_int():
			parts.remove_at(parts.size() - 1)
			return " ".join(parts)
	return card_name
