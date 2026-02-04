extends Node3D

const DICE_SCENE := preload("res://scenes/Dice.tscn")
const CARD_SCENE := preload("res://scenes/Card.tscn")
const TOKEN_SCENE := preload("res://scenes/Token.tscn")
const TABLE_Y := 0.0
const HAND_UI_SCRIPT := preload("res://scripts/HandUI.gd")
const UI_FONT := preload("res://assets/Font/ARCADECLASSIC.TTF")
const MUSIC_TRACK := preload("res://assets/music/Music.mp3")
const MUSIC_ON_ICON := preload("res://assets/Music/sound_on.png")
const MUSIC_OFF_ICON := preload("res://assets/Music/sound_off.png")
const FIGHT_ICON := preload("res://assets/Token/fight.png")
const TOKEN_VASO := "res://assets/Token/vaso.png"
const TOKEN_CHEST := "res://assets/Token/chest.png"
const TOKEN_TECA := "res://assets/Token/teca.png"
const TOKEN_TOMBSTONE := "res://assets/Token/tombstone.png"
const DECK_UTILS := preload("res://scripts/DeckUtils.gd")

@onready var camera: Camera3D = $Camera
@onready var reward_spawner: Node3D = $RewardSpawner
@onready var main_light: DirectionalLight3D = $DirectionalLight

const LIGHT_COLOR_ORG := Color(1, 0.95, 0.9, 1)
const LIGHT_COLOR_ADV := Color(0.75, 0.55, 0.95, 1)
const LIGHT_COLOR_REC := Color(1, 0.65, 0.3, 1)
const CARD_HIT_HALF_SIZE := Vector2(0.7, 1.0)

var pan_active := false
var launch_start_time: float = -1.0
var pending_dice: Array[RigidBody3D] = []
var sum_label: Label
var y_label: Label
var camera_label: Label
var adventure_value_panel: PanelContainer
var adventure_value_label: Label
var player_value_panel: PanelContainer
var player_value_label: Label
var player_dice_buttons_row: HBoxContainer
var player_dice_buttons_key: String = ""
var compare_button: Button
var outcome_panel: PanelContainer
var outcome_label: Label
var outcome_token: int = 0
var roll_history: Array[int] = []
var roll_color_history: Array[String] = []
var dice_count: int = 1
var blue_dice: int = 1
var green_dice: int = 0
var red_dice: int = 0
var base_dice_count: int = 1
var active_dice: Array[RigidBody3D] = []
var dice_hold_active: bool = false
var dice_hold_start_ms: int = 0
var dice_preview: Array[RigidBody3D] = []
var roll_pending_apply: bool = false
var last_roll_total: int = 0
var last_roll_values: Array[int] = []
var selected_roll_dice: Array[int] = []
var last_roll_success: bool = false
var last_roll_penalty: bool = false
var roll_trigger_reset: bool = false
var post_roll_effects: Array[String] = []
var roll_in_progress: bool = false
var dragged_card: Node3D
var drag_offset: Vector3 = Vector3.ZERO
var dragged_card_origin_y: float = 0.0
var hovered_card: Node3D
var selected_card: Node3D
var player_hand: Array = []
var last_mouse_pos: Vector2 = Vector2.ZERO
var mouse_down_pos: Vector2 = Vector2.ZERO
var pan_start_world: Vector3 = Vector3.INF
var pan_start_cam_pos: Vector3 = Vector3.ZERO
var pending_flip_card: Node3D
var pending_flip_is_adventure: bool = false
const CLICK_DRAG_THRESHOLD := 8.0
const DRAG_HEIGHT := 1.0
var top_sorting_offset: float = 0.0
var equipment_slots: Array[Area3D] = []
var equipment_slots_root: Node3D
var equipment_slots_y_offset: float = 0.2
var equipment_slots_z_offset: float = 1.2
const CARD_CENTER_X_OFFSET := 0.7
const EQUIP_SLOT_WIDTH := 1.4
const EQUIP_SLOT_HEIGHT := 2.0
const EQUIP_SLOT_SPACING := 0.2
const DICE_PREVIEW_OFFSET := Vector3(2.2, 0.0, 0.0)
var hand_ui: Control
var player_gold: int = 30
var player_tombstones: int = 0
var enemies_defeated_total: int = 0
var pending_penalty_discards: int = 0
var pending_discard_reason: String = ""
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
var pending_chain_effects: Array = []
var action_prompt_panel: PanelContainer
var action_prompt_label: Label
var action_prompt_yes: Button
var action_prompt_no: Button
var pending_action_card_data: Dictionary = {}
var pending_action_is_magic: bool = false
var pending_action_source_card: Node3D
var battlefield_warning_panel: PanelContainer
var battlefield_warning_label: Label
var battlefield_warning_ok: Button
var music_player: AudioStreamPlayer
var music_toggle_button: TextureButton
var fight_icon: Texture2D
var light_tween: Tween
var phase_index: int = 0
var player_max_hearts: int = 0
var player_max_hand: int = 0
var player_current_hearts: int = 0
var curse_stats_override: Dictionary = {}
var active_curse_id: String = ""
const PURCHASE_FONT_SIZE := 44
var treasure_deck_pos := Vector3(-3, 0.0179999992251396, 0)
var treasure_reveal_pos := Vector3(-4, 0.0240000002086163, 0)
var treasure_discard_pos := Vector3(-5.05, 0.0240000002086163, 0.315)
var revealed_treasure_count: int = 0
var discarded_treasure_count: int = 0
var is_treasure_stack_hovered: bool = false
const REVEALED_Y_STEP := 0.01
var adventure_deck_pos := Vector3(4, 0.02, 0)
var adventure_reveal_pos := Vector3(2, 0.2, 0)
var battlefield_pos := Vector3(0, 0.02, 0)
var adventure_discard_pos := Vector3(6.1, 0.026, 0.35)
var event_row_pos := Vector3(-5, 0.02, 2.5)
var revealed_adventure_count: int = 0
var mission_side_count: int = 0
var event_row_count: int = 0
var discarded_adventure_count: int = 0
var is_adventure_stack_hovered: bool = false
const ADVENTURE_BACK := "res://assets/cards/ghost_n_goblins/adventure/Back_adventure.png"
const MISSION_SIDE_OFFSET := Vector3(1.6, 0.0, 0.0)
const EVENT_ROW_SPACING := 1.6
const TREASURE_REVEAL_OFFSET := Vector3(-1.0, 0.006, 0.0)
const TREASURE_DISCARD_OFFSET := Vector3(-2.05, 0.006, 0.315)
const ADVENTURE_REVEAL_OFFSET := Vector3(5, 0, 0.0)
const ADVENTURE_DISCARD_OFFSET := Vector3(2.1, 0.006, 0.35)
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
var astaroth_pos := Vector3(-5, 0.0389999970793724, -2.5)
const HEART_TEXTURE := "res://assets/Token/cuore.png"
var character_card: Node3D
var regno_card: Node3D
const BOSS_STACK_OFFSET := Vector3(0.0, 0.0, 0.0)
var regno_track_nodes: Array = []
var regno_track_rewards: Array = []
var regno_track_index: int = 0
var regno_overlay_layer: CanvasLayer
var regno_overlay: Control
var regno_node_boxes: Array[PanelContainer] = []
var regno_blink_time: float = 0.0
var regno_reward_label: Label
var coin_total_label: Label3D
var coin_pile_count: int = 0
const COIN_PILE_SPACING_X := 0.8
const COIN_PILE_SPACING_Z := 0.55
const COIN_PILE_COLUMNS := 4

func _ui_text(text: String) -> String:
	return text.replace(" ", "  ")

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	camera.rotation_degrees = Vector3(-80.0, 0.0, 0.0)
	camera.global_position = Vector3(0.65, 6.0, 3.8)
	fight_icon = _load_texture("res://assets/Token/fight.png")
	_play_music()
	_update_phase_lighting()
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
	_create_coin_total_label()
	_update_phase_info()
	_create_adventure_prompt()
	_create_battlefield_warning()
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
			blue_dice = base_dice_count
			green_dice = 0
			red_dice = 0
			dice_count = _get_total_dice()
			_clear_dice()
			roll_history.clear()
			roll_color_history.clear()
			sum_label.text = _ui_text("Risultati: - | Colori: -")
		elif event.keycode == KEY_PAGEUP:
			_adjust_selected_card_y(0.02)
			_adjust_equipment_slots_y(0.02)
		elif event.keycode == KEY_PAGEDOWN:
			_adjust_selected_card_y(-0.02)
			_adjust_equipment_slots_y(-0.02)
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_launch_dice_at(Vector3(0.0, TABLE_Y, 0.0), Vector3.ZERO)
		elif event.keycode == KEY_1:
			spawn_reward_tokens(1, HEART_TEXTURE, battlefield_pos)
		elif event.keycode == KEY_2:
			spawn_reward_coins(1, battlefield_pos)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_mouse_pos = event.position
			mouse_down_pos = event.position
			var card := _get_card_under_mouse(event.position)
			if card == null and phase_index == 1:
				card = _get_adventure_stack_card_at(event.position)
			if card == null and phase_index == 1 and _get_battlefield_card() != null:
				_start_dice_hold(event.position)
				return
			if card != null:
				if phase_index == 0 and card.has_meta("in_mission_side") and card.get_meta("in_mission_side", false):
					_try_claim_mission(card)
					return
				if phase_index == 0 and _try_spend_tombstone_on_regno(card):
					return
				if phase_index == 0:
					var top_market_left := _get_top_market_card()
					if top_market_left != null and card == top_market_left:
						_try_show_purchase_prompt(card, false)
						return
				if phase_index == 1 and card.has_meta("equipped_slot"):
					var eq_data: Dictionary = card.get_meta("card_data", {})
					if _is_card_activation_allowed_now(eq_data):
						_show_action_prompt(eq_data, false, card)
					else:
						_show_card_timing_hint(eq_data)
					return
				if phase_index == 0 and card.has_meta("equipped_slot"):
					_return_equipped_to_hand(card)
					return
				selected_card = card
				if card.has_method("is_face_up_now") and card.has_method("flip_to_side"):
					if is_treasure_stack_hovered and phase_index == 0:
						var top_card := _get_top_treasure_card()
						if top_card != null and top_card.has_method("is_face_up_now"):
							if not top_card.is_face_up_now():
								pending_flip_card = top_card
								pending_flip_is_adventure = false
								return
					elif is_adventure_stack_hovered and phase_index == 1:
						var top_adv_left := _get_top_adventure_card()
						if top_adv_left != null and top_adv_left.has_method("is_face_up_now"):
							if not top_adv_left.is_face_up_now():
								pending_flip_card = top_adv_left
								pending_flip_is_adventure = true
								return
				# dragging disabled
		else:
			if dice_hold_active:
				_release_dice_hold(event.position)
				return
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
			if card == null and phase_index == 1:
				card = _get_adventure_stack_card_at(event.position)
			if card != null:
				if phase_index == 0:
					var top_market := _get_top_market_card()
					if top_market != null and card == top_market:
						_try_show_purchase_prompt(card, false)
				elif phase_index == 1:
					if card.has_meta("in_adventure_stack") and card.get_meta("in_adventure_stack", false):
						_try_show_adventure_prompt(card)
		pan_active = false
	elif event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			last_mouse_pos = event.position
			pan_active = true
			pan_start_world = _ray_to_plane(event.position)
			pan_start_cam_pos = camera.global_position
		else:
			pan_active = false
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_zoom(-1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_zoom(1.0)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	last_mouse_pos = event.position
	if pan_active:
		var pan_speed := 0.006 * camera.global_position.y
		camera.global_position.x -= event.relative.x * pan_speed
		camera.global_position.z -= event.relative.y * pan_speed
		return
	if dragged_card == null:
		_update_hover(event.position)

func _update_pan(mouse_pos: Vector2) -> void:
	if camera == null:
		return
	if pan_start_world == Vector3.INF:
		return
	var current_world := _ray_to_plane(mouse_pos)
	if current_world == Vector3.INF:
		return
	var delta := current_world - pan_start_world
	var target := pan_start_cam_pos - Vector3(delta.x, 0.0, delta.z) * 1.2
	camera.global_position = target

func _zoom(direction: float) -> void:
	var pos := camera.global_position
	pos.y = clamp(pos.y + direction, 3.0, 80.0)
	camera.global_position = pos

func _release_launch(mouse_pos: Vector2) -> void:
	if launch_start_time < 0.0:
		return
	var _held: float = max(0.0, (Time.get_ticks_msec() / 1000.0) - launch_start_time)
	launch_start_time = -1.0
	var hit: Vector3 = _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	_launch_dice_at(hit, Vector3.ZERO)

func _process(_delta: float) -> void:
	if dragged_card != null:
		var hit := _ray_to_plane(last_mouse_pos)
		if hit != Vector3.INF:
			var target := hit + drag_offset
			target.y = TABLE_Y + DRAG_HEIGHT
			dragged_card.global_position = target
		_sync_equipment_slots_root()
		return
	if dice_hold_active:
		_update_dice_hold(last_mouse_pos)
		return
	_ensure_idle_dice_preview()
	_sync_equipment_slots_root()
	_update_hover(last_mouse_pos)
	_update_purchase_prompt_position()
	_update_adventure_prompt_position()
	_update_camera_label()
	_update_regno_overlay()
	_update_adventure_value_box()
	_update_coin_total_label()

func _launch_dice_at(spawn_pos: Vector3, launch_dir: Vector3) -> void:
	_clear_dice()
	_hide_outcome()
	post_roll_effects.clear()
	roll_in_progress = true
	dice_count = _get_total_dice()
	_spawn_dice(spawn_pos, launch_dir)
	blue_dice += 1
	dice_count = _get_total_dice()
	_track_dice_sum()

func _start_dice_hold(mouse_pos: Vector2) -> void:
	if dice_hold_active:
		return
	if not _can_start_roll():
		return
	dice_hold_active = true
	dice_hold_start_ms = Time.get_ticks_msec()
	_clear_dice_preview()
	_spawn_dice_preview()
	_update_dice_hold(mouse_pos)

func _release_dice_hold(mouse_pos: Vector2) -> void:
	if not dice_hold_active:
		return
	dice_hold_active = false
	_clear_dice_preview()
	var hit_start: Vector3 = _ray_to_plane(mouse_down_pos)
	var hit_end: Vector3 = _ray_to_plane(mouse_pos)
	if hit_end == Vector3.INF or hit_start == Vector3.INF:
		return
	var launch_dir := hit_end - hit_start
	launch_dir.y = 0.0
	if launch_dir.length() > 0.001:
		launch_dir = launch_dir.normalized()
	_launch_dice_at(hit_end, launch_dir)

func _can_start_roll() -> bool:
	if roll_pending_apply:
		return false
	if roll_in_progress:
		return false
	# allow reroll only if unlocked by success, penalty or reset
	if last_roll_success or last_roll_penalty or roll_trigger_reset:
		return true
	# first roll of the encounter
	if roll_history.is_empty():
		return true
	return false

func _reset_roll_trigger() -> void:
	roll_trigger_reset = true

func _spawn_dice_preview() -> void:
	var count := _get_total_dice()
	var center := adventure_deck_pos + DICE_PREVIEW_OFFSET
	for i in count:
		var dice: RigidBody3D = DICE_SCENE.instantiate() as RigidBody3D
		add_child(dice)
		dice.freeze = true
		dice.global_position = center + Vector3(i * 0.5, 0.3, 0.0)
		dice_preview.append(dice)

func _ensure_idle_dice_preview() -> void:
	if dice_hold_active:
		return
	if roll_pending_apply:
		return
	if not active_dice.is_empty():
		return
	var desired := _get_total_dice()
	if dice_preview.size() == desired:
		return
	_clear_dice_preview()
	_spawn_dice_preview()

func _update_dice_hold(mouse_pos: Vector2) -> void:
	if dice_preview.is_empty():
		return
	var hit := _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	var radius := 0.8
	var t := Time.get_ticks_msec() / 1000.0
	var count := dice_preview.size()
	for i in count:
		var dice := dice_preview[i]
		if not is_instance_valid(dice):
			continue
		var angle: float = t * 2.5 + (TAU * float(i) / max(count, 1))
		var pos: Vector3 = hit + Vector3(cos(angle) * radius, 0.3, sin(angle) * radius)
		dice.global_position = pos
		dice.global_rotation = Vector3(0.0, angle, 0.0)

func _clear_dice_preview() -> void:
	for dice in dice_preview:
		if is_instance_valid(dice):
			dice.queue_free()
	dice_preview.clear()

func _spawn_dice(spawn_pos: Vector3, launch_dir: Vector3) -> void:
	var hold_scale: float = 1.0
	var offset_index: int = 0
	offset_index = _spawn_dice_batch(spawn_pos, hold_scale, launch_dir, blue_dice, "blue", offset_index)
	offset_index = _spawn_dice_batch(spawn_pos, hold_scale, launch_dir, green_dice, "green", offset_index)
	offset_index = _spawn_dice_batch(spawn_pos, hold_scale, launch_dir, red_dice, "red", offset_index)

func _spawn_dice_batch(spawn_pos: Vector3, hold_scale: float, launch_dir: Vector3, count: int, dice_type: String, start_index: int) -> int:
	for i in count:
		var dice: RigidBody3D = DICE_SCENE.instantiate() as RigidBody3D
		add_child(dice)
		var idx := start_index + i
		dice.global_position = spawn_pos + Vector3(idx * 0.6, 2.0, 0.0)
		dice.global_rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		var lateral_strength := randf_range(1.2, 2.0) * hold_scale
		var lateral_angle := randf() * TAU
		var dir_boost := launch_dir * 1.2
		var impulse: Vector3 = Vector3(
			cos(lateral_angle) * lateral_strength,
			randf_range(4.0, 5.0) * hold_scale,
			sin(lateral_angle) * lateral_strength
		) + Vector3(dir_boost.x, 0.0, dir_boost.z)
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
		if dice.has_method("set_dice_type"):
			dice.call("set_dice_type", dice_type)
		pending_dice.append(dice)
		active_dice.append(dice)
	return start_index + count

func _get_total_dice() -> int:
	return max(1, blue_dice + green_dice + red_dice)

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
	adventure_discard_pos = adventure_deck_pos + ADVENTURE_DISCARD_OFFSET
	_reposition_stack("in_adventure_stack", adventure_deck_pos)
	_reposition_adventure_discard_stack()

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

func _reposition_adventure_discard_stack() -> void:
	var cards: Array = []
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("adventure_discard_index"):
			continue
		cards.append(child)
	if cards.is_empty():
		return
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("adventure_discard_index", -1))
		var b_idx := int(b.get_meta("adventure_discard_index", -1))
		return a_idx < b_idx
	)
	for i in cards.size():
		var card: Node3D = cards[i]
		card.global_position = adventure_discard_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)

func _move_adventure_to_discard(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_battlefield", false)
	card.set_meta("adventure_blocking", false)
	card.set_meta("in_mission_side", false)
	card.set_meta("in_event_row", false)
	card.set_meta("in_adventure_discard", true)
	card.set_meta("adventure_discard_index", discarded_adventure_count)
	discarded_adventure_count += 1
	card.global_position = adventure_discard_pos + Vector3(0.0, (discarded_adventure_count - 1) * REVEALED_Y_STEP, 0.0)

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

func _get_battlefield_card() -> Node3D:
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_battlefield"):
			continue
		if not child.get_meta("in_battlefield", false):
			continue
		return child
	return null

func _get_blocking_adventure_card() -> Node3D:
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("adventure_blocking"):
			continue
		if not child.get_meta("adventure_blocking", false):
			continue
		return child
	return null

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
	purchase_label.text = _ui_text("Vuoi aggiungerla alla tua mano per il prezzo di %d monete?" % cost)
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
	if new_phase_index == 0 and _block_turn_pass_if_hand_exceeds_limit(_turn_index):
		return
	phase_index = new_phase_index
	if phase_index != 0:
		_hide_purchase_prompt()
	if phase_index != 1:
		_hide_adventure_prompt()
	if phase_index == 2:
		await _cleanup_battlefield_rewards_for_recovery()
		_on_end_turn_with_battlefield()
		_try_advance_regno_track()
		_reset_dice_for_rest()
	_update_phase_lighting()
	_update_phase_info()

func _block_turn_pass_if_hand_exceeds_limit(turn_index: int) -> bool:
	var excess := player_hand.size() - player_max_hand
	if excess <= 0:
		return false
	pending_penalty_discards = max(pending_penalty_discards, excess)
	_set_hand_discard_mode(true, "hand_limit")
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", "Fine turno: scarta %d carte (limite mano %d)." % [excess, player_max_hand])
	if hand_ui != null and hand_ui.has_method("set_phase_silent"):
		hand_ui.call("set_phase_silent", 2, max(1, turn_index - 1))
	phase_index = 2
	_update_phase_lighting()
	_update_phase_info()
	return true

func _cleanup_battlefield_rewards_for_recovery() -> void:
	await _resolve_reward_tokens_for_recovery()
	# Move coins toward the player HUD area, then remove them.
	var target := _get_player_collect_target()
	for coin in get_tree().get_nodes_in_group("coins"):
		if not (coin is RigidBody3D):
			continue
		var body := coin as RigidBody3D
		if not is_instance_valid(body):
			continue
		body.freeze = true
		body.sleeping = true
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(body, "global_position", target + Vector3(randf_range(-0.06, 0.06), 0.0, randf_range(-0.06, 0.06)), 0.35)
		tween.tween_callback(func() -> void:
			if is_instance_valid(body):
				body.queue_free()
		)
	coin_pile_count = 0

func _resolve_reward_tokens_for_recovery() -> void:
	var tokens: Array = get_tree().get_nodes_in_group("reward_tokens")
	if tokens.is_empty():
		return
	var hud_target := _get_player_collect_target()
	for node in tokens:
		var token := node as RigidBody3D
		if token == null or not is_instance_valid(token):
			continue
		var code := str(token.get_meta("reward_code", ""))
		match code:
			"reward_group_vaso_di_coccio":
				await _consume_token_and_draw_treasure(token, "vaso_di_coccio")
			"reward_group_chest":
				await _consume_token_and_draw_treasure(token, "chest")
			"reward_group_teca":
				await _consume_token_and_draw_treasure(token, "teca")
			"reward_token_tombstone":
				_collect_tombstone_token(token, hud_target)
			_:
				token.queue_free()

func _consume_token_and_draw_treasure(token: RigidBody3D, group_key: String) -> void:
	if token != null and is_instance_valid(token):
		token.queue_free()
	await _draw_treasure_until_group(group_key)

func _draw_treasure_until_group(group_key: String) -> void:
	while true:
		var top := _get_top_treasure_card()
		if top == null:
			break
		var card_data: Dictionary = top.get_meta("card_data", {})
		top.set_meta("in_treasure_stack", false)
		await _flip_treasure_card_for_recovery(top)
		var group := str(card_data.get("group", "")).strip_edges().to_lower()
		if group == group_key:
			player_hand.append(card_data)
			top.queue_free()
			_refresh_hand_ui()
			return
		top.set_meta("discard_index", discarded_treasure_count)
		discarded_treasure_count += 1
		top.global_position = treasure_discard_pos + Vector3(0.0, (discarded_treasure_count - 1) * REVEALED_Y_STEP, 0.0)

func _flip_treasure_card_for_recovery(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var reveal_pos := treasure_reveal_pos + Vector3(0.0, revealed_treasure_count * REVEALED_Y_STEP, 0.0)
	if card.has_method("flip_to_side"):
		card.call("flip_to_side", reveal_pos)
		await get_tree().create_timer(0.35).timeout
	else:
		card.global_position = reveal_pos

func _collect_tombstone_token(token: RigidBody3D, target: Vector3) -> void:
	if token == null or not is_instance_valid(token):
		return
	token.freeze = true
	token.sleeping = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(token, "global_position", target + Vector3(randf_range(-0.06, 0.06), 0.0, randf_range(-0.06, 0.06)), 0.35)
	tween.tween_callback(func() -> void:
		if is_instance_valid(token):
			token.queue_free()
		player_tombstones += 1
		if hand_ui != null and hand_ui.has_method("set_tokens"):
			hand_ui.call("set_tokens", player_tombstones)
	)

func _get_player_collect_target() -> Vector3:
	var view_size := get_viewport().get_visible_rect().size
	var hud_point := Vector2(210.0, view_size.y - 120.0)
	var world := _ray_to_plane(hud_point)
	if world == Vector3.INF:
		return battlefield_pos + Vector3(-2.4, 0.02, 1.9)
	world.y = battlefield_pos.y + 0.02
	return world

func _update_phase_info() -> void:
	if hand_ui == null or not hand_ui.has_method("set_info"):
		return
	var text := ""
	if phase_index == 0:
		text = "Organizzazione:\n- compra tesori (dx sul mercato)\n- equip/unequip dalla mano\n- gira carta tesoro\n- riscatta missione (clic)"
	elif phase_index == 1:
		text = "Avventura:\n- gira carta avventura (clic sul mazzo)\n- lancia dadi (tieni sx, rilascia)\n- usa equip (sx) o magie (dx)\n- applica risultato (pulsante fight)"
	else:
		text = "Recupero:\n- ripristino dadi\n- fine turno"
	hand_ui.call("set_info", _ui_text(text))

func _update_phase_lighting() -> void:
	if main_light == null:
		return
	var target := LIGHT_COLOR_ORG
	if phase_index == 1:
		target = LIGHT_COLOR_ADV
	elif phase_index == 2:
		target = LIGHT_COLOR_REC
	if light_tween != null and light_tween.is_valid():
		light_tween.kill()
	light_tween = create_tween()
	light_tween.tween_property(main_light, "light_color", target, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _get_adventure_stack_card_at(mouse_pos: Vector2) -> Node3D:
	var card := _get_card_under_mouse(mouse_pos)
	if card != null and card.has_meta("in_adventure_stack") and card.get_meta("in_adventure_stack", false):
		return _get_top_adventure_card()
	var top := _get_top_adventure_card()
	if top == null:
		return null
	var hit := _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return null
	var center := top.global_position
	if abs(hit.x - center.x) <= CARD_HIT_HALF_SIZE.x and abs(hit.z - center.z) <= CARD_HIT_HALF_SIZE.y:
		return top
	return null

func _on_end_turn_with_battlefield() -> void:
	var battlefield := _get_blocking_adventure_card()
	if battlefield == null:
		return
	_show_battlefield_warning()
	var hearts := int(battlefield.get_meta("battlefield_hearts", 1))
	battlefield.set_meta("battlefield_hearts", hearts + 1)

func _try_advance_regno_track() -> void:
	# Advance only when leaving adventure with no unresolved blocking enemy.
	if _get_blocking_adventure_card() != null:
		return
	if regno_card == null or not is_instance_valid(regno_card):
		return
	if regno_track_rewards.is_empty():
		return
	var max_index := regno_track_rewards.size() - 1
	if regno_track_index >= max_index:
		return
	regno_track_index += 1
	_update_regno_reward_label()

func _try_spend_tombstone_on_regno(card: Node3D) -> bool:
	if regno_card == null or not is_instance_valid(regno_card):
		return false
	if card != regno_card:
		return false
	if player_tombstones <= 0:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Non hai token Tombstone da spendere."))
		return true
	if regno_track_rewards.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Tracciato Regno non disponibile."))
		return true
	var max_index := regno_track_rewards.size() - 1
	if regno_track_index >= max_index:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Il Regno del Male e gia al massimo."))
		return true
	player_tombstones -= 1
	regno_track_index += 1
	_update_regno_reward_label()
	if hand_ui != null and hand_ui.has_method("set_tokens"):
		hand_ui.call("set_tokens", player_tombstones)
	if hand_ui != null and hand_ui.has_method("set_info"):
		var reward_code := str(regno_track_rewards[regno_track_index])
		hand_ui.call("set_info", _ui_text("Speso 1 Tombstone: Regno avanza a %s." % _format_regno_reward(reward_code)))
	return true

func _reset_dice_for_rest() -> void:
	_clear_dice()
	roll_pending_apply = false
	blue_dice = base_dice_count + green_dice + red_dice
	green_dice = 0
	red_dice = 0
	dice_count = _get_total_dice()
	_clear_dice_preview()
	_spawn_dice_preview()

func _try_show_adventure_prompt(card: Node3D) -> void:
	if phase_index != 1:
		return
	if _get_blocking_adventure_card() != null:
		_show_battlefield_warning()
		return
	if not pending_chain_effects.is_empty():
		pending_adventure_card = card
		_confirm_adventure_prompt()
		return
	pending_adventure_card = card
	if adventure_prompt_label != null:
		adventure_prompt_label.text = _ui_text("Vuoi intraprendere una nuova avventura?")
	adventure_prompt_panel.visible = true
	_resize_adventure_prompt()
	_update_adventure_prompt_position()

func _hide_adventure_prompt() -> void:
	if adventure_prompt_panel != null:
		adventure_prompt_panel.visible = false
	pending_adventure_card = null

func _show_action_prompt(card_data: Dictionary, is_magic: bool, source_card: Node3D = null) -> void:
	if action_prompt_panel == null:
		return
	pending_action_card_data = card_data
	pending_action_is_magic = is_magic
	pending_action_source_card = source_card
	var name := str(card_data.get("name", "Carta"))
	if action_prompt_label != null:
		action_prompt_label.text = _ui_text("Vuoi usare %s?" % name)
	action_prompt_panel.visible = true
	_center_action_prompt()

func _hide_action_prompt() -> void:
	if action_prompt_panel != null:
		action_prompt_panel.visible = false
	pending_action_card_data = {}
	pending_action_is_magic = false
	pending_action_source_card = null

func _center_action_prompt() -> void:
	if action_prompt_panel == null:
		return
	action_prompt_panel.custom_minimum_size = Vector2.ZERO
	action_prompt_panel.reset_size()
	action_prompt_panel.custom_minimum_size = action_prompt_panel.get_combined_minimum_size()
	action_prompt_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size: Vector2 = action_prompt_panel.size
	action_prompt_panel.position = (view_size - size) * 0.5

func _confirm_action_prompt() -> void:
	if pending_action_card_data.is_empty():
		_hide_action_prompt()
		return
	var action_window := _get_current_card_action_window(pending_action_card_data)
	var effects := _get_effects_for_window(pending_action_card_data, action_window)
	if effects.is_empty():
		_hide_action_prompt()
		return
	if not _validate_roll_selection_for_effects(effects):
		return
	_use_card_effects(pending_action_card_data, effects, action_window)
	if not pending_action_is_magic and pending_action_source_card != null and is_instance_valid(pending_action_source_card):
		if effects.has("return_to_hand"):
			_force_return_equipped_to_hand(pending_action_source_card)
	if pending_action_is_magic:
		if not effects.has("return_to_hand"):
			player_hand.erase(pending_action_card_data)
			_refresh_hand_ui()
	_hide_action_prompt()

func _use_card_effects(card_data: Dictionary, effects: Array = [], action_window: String = "") -> void:
	if effects.is_empty():
		effects = card_data.get("effects", [])
	if effects.is_empty():
		return
	_hide_outcome()
	var selected_values := _get_selected_roll_values()
	if selected_values.is_empty():
		selected_values = last_roll_values.duplicate()
	var reroll_indices: Array[int] = []
	for effect in effects:
		var effect_name := str(effect).strip_edges()
		if effect_name.is_empty():
			continue
		if effect_name == "discard_hand_card_1":
			if not _discard_one_hand_card_for_effect(card_data if pending_action_is_magic else {}):
				if hand_ui != null and hand_ui.has_method("set_info"):
					hand_ui.call("set_info", _ui_text("Costo non pagato: scarta 1 carta dalla mano."))
				return
			continue
		if _apply_direct_card_effect(effect_name, card_data, action_window):
			continue
		if effect_name == "lowest_die_applies_to_all" and action_window == "before_roll" and not roll_pending_apply:
			post_roll_effects.append("next_roll_lowest_die_applies_to_all")
			continue
		post_roll_effects.append(effect_name)
		_collect_reroll_indices(effect_name, reroll_indices)
		_apply_post_roll_effect(effect_name, selected_values)
		AbilityRegistry.apply(effect_name, {
			"main": self,
			"card_data": card_data,
			"phase_index": phase_index,
			"roll_total": last_roll_total,
			"roll_values": last_roll_values,
			"selected_roll_values": selected_values
		})
	if reroll_indices.is_empty():
		_recalculate_last_roll_total()
	else:
		_start_visual_reroll(reroll_indices)
	# Keep the comparison step active after using equipment/magic.
	roll_trigger_reset = true
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", false)

func _discard_one_hand_card_for_effect(exclude_card: Dictionary = {}) -> bool:
	if player_hand.is_empty():
		return false
	var remove_idx := -1
	for i in player_hand.size():
		if not exclude_card.is_empty() and player_hand[i] == exclude_card:
			continue
		remove_idx = i
		break
	if remove_idx < 0:
		return false
	player_hand.remove_at(remove_idx)
	_refresh_hand_ui()
	return true

func _apply_direct_card_effect(effect_name: String, _card_data: Dictionary, _action_window: String) -> bool:
	match effect_name:
		"add_red_die":
			red_dice += 1
			dice_count = _get_total_dice()
			if not roll_pending_apply and not roll_in_progress:
				_clear_dice_preview()
				_spawn_dice_preview()
			return true
		"deal_1_damage":
			_apply_direct_damage_to_battlefield(1)
			return true
		"discard_revealed_adventure":
			_discard_revealed_adventure_card()
			return true
		"regno_del_male_portal", "sacrifice_open_portal":
			_try_advance_regno_track()
			_update_regno_reward_label()
			return true
		"reset_hearts_and_dice":
			player_current_hearts = player_max_hearts
			blue_dice = base_dice_count
			green_dice = 0
			red_dice = 0
			dice_count = _get_total_dice()
			_update_hand_ui_stats()
			if not roll_pending_apply and not roll_in_progress:
				_clear_dice_preview()
				_spawn_dice_preview()
			return true
		_:
			return false

func _apply_direct_damage_to_battlefield(amount: int) -> void:
	if amount <= 0:
		return
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		return
	var hearts := int(battlefield.get_meta("battlefield_hearts", 1))
	hearts -= amount
	battlefield.set_meta("battlefield_hearts", hearts)
	if hearts > 0:
		return
	var card_data: Dictionary = battlefield.get_meta("card_data", {})
	var card_type := str(card_data.get("type", "")).strip_edges().to_lower()
	if card_type == "scontro":
		enemies_defeated_total += 1
	_report_battlefield_reward(card_data, last_roll_total, int(card_data.get("difficulty", 0)))
	_spawn_defeat_explosion(battlefield.global_position)
	_move_adventure_to_discard(battlefield)

func _discard_revealed_adventure_card() -> void:
	var battlefield := _get_battlefield_card()
	if battlefield != null:
		_move_adventure_to_discard(battlefield)
		return
	var top := _get_top_adventure_card()
	if top == null:
		return
	top.set_meta("in_adventure_stack", false)
	_move_adventure_to_discard(top)

func _apply_post_roll_effect(effect_name: String, selected_values: Array[int]) -> void:
	if last_roll_values.is_empty():
		return
	match effect_name:
		"after_roll_minus_1_all_dice":
			for i in last_roll_values.size():
				last_roll_values[i] = max(1, int(last_roll_values[i]) - 1)
		"halve_even_dice":
			for i in last_roll_values.size():
				var v := int(last_roll_values[i])
				if v % 2 == 0:
					last_roll_values[i] = max(1, int(v / 2))
		"after_roll_set_one_die_to_1":
			var target := _get_first_selected_die_index()
			if target >= 0:
				last_roll_values[target] = max(1, int(last_roll_values[target]) - 1)
		"lowest_die_applies_to_all":
			if selected_values.is_empty():
				return
			var low := selected_values[0]
			for v in selected_values:
				low = min(low, int(v))
			for i in last_roll_values.size():
				last_roll_values[i] = int(low)
		_:
			pass

func _get_first_selected_die_index() -> int:
	for idx in selected_roll_dice:
		var i := int(idx)
		if i >= 0 and i < last_roll_values.size():
			return i
	if not last_roll_values.is_empty():
		return 0
	return -1

func _recalculate_last_roll_total() -> void:
	var total := 0
	for v in last_roll_values:
		total += int(v)
	last_roll_total = total

func _collect_reroll_indices(effect_name: String, target: Array[int]) -> void:
	match effect_name:
		"reroll_5_or_6":
			for i in last_roll_values.size():
				var v := int(last_roll_values[i])
				if (v == 5 or v == 6) and not target.has(i):
					target.append(i)
		"reroll_same_dice":
			for idx in selected_roll_dice:
				var i := int(idx)
				if i < 0 or i >= last_roll_values.size():
					continue
				if not target.has(i):
					target.append(i)
		_:
			pass

func _start_visual_reroll(indices: Array[int]) -> void:
	if indices.is_empty():
		return
	roll_pending_apply = false
	roll_in_progress = true
	for idx in indices:
		var i := int(idx)
		if i < 0 or i >= active_dice.size():
			continue
		var dice := active_dice[i]
		if dice == null or not is_instance_valid(dice):
			continue
		dice.freeze = false
		dice.sleeping = false
		dice.linear_velocity = Vector3.ZERO
		dice.angular_velocity = Vector3.ZERO
		var impulse := Vector3(
			randf_range(-1.2, 1.2),
			randf_range(2.8, 4.2),
			randf_range(-1.2, 1.2)
		)
		var torque := Vector3(
			randf_range(-1.2, 1.2),
			randf_range(-1.2, 1.2),
			randf_range(-1.2, 1.2)
		)
		dice.apply_central_impulse(impulse)
		dice.apply_torque_impulse(torque)
	_finish_visual_reroll_after_settle()

func _finish_visual_reroll_after_settle() -> void:
	await _wait_for_dice_settle(active_dice)
	_rebuild_roll_values_from_active_dice()
	roll_in_progress = false
	roll_pending_apply = true

func _rebuild_roll_values_from_active_dice() -> void:
	last_roll_values.clear()
	selected_roll_dice.clear()
	var names: Array[String] = []
	var total := 0
	for i in active_dice.size():
		var dice := active_dice[i]
		if dice == null or not is_instance_valid(dice):
			continue
		var value := _get_top_face_value(dice)
		last_roll_values.append(value)
		total += value
		names.append(_get_top_face_name(dice))
		selected_roll_dice.append(last_roll_values.size() - 1)
	last_roll_total = total
	if sum_label != null:
		sum_label.text = "Risultati: %s | Colori: %s | Attuale: %d" % [", ".join(roll_history), " | ".join(roll_color_history), last_roll_total]

func _validate_roll_selection_for_effects(effects: Array) -> bool:
	if not roll_pending_apply:
		return true
	if effects.has("after_roll_set_one_die_to_1") and selected_roll_dice.is_empty():
		_set_selection_error("Seleziona almeno 1 dado per questa abilita.")
		return false
	if effects.has("reroll_same_dice") and selected_roll_dice.is_empty():
		_set_selection_error("Seleziona almeno 1 dado da rilanciare.")
		return false
	if effects.has("lowest_die_applies_to_all") and selected_roll_dice.is_empty():
		_set_selection_error("Seleziona almeno 1 dado per applicare il valore minimo.")
		return false
	return true

func _set_selection_error(message: String) -> void:
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", message)

func _confirm_adventure_prompt() -> void:
	if pending_adventure_card == null or not is_instance_valid(pending_adventure_card):
		_hide_adventure_prompt()
		return
	if _get_blocking_adventure_card() != null:
		_hide_adventure_prompt()
		_show_battlefield_warning()
		return
	var target_pos_adv := _get_battlefield_target_pos()
	pending_adventure_card.set_meta("in_adventure_stack", false)
	var card_data: Dictionary = pending_adventure_card.get_meta("card_data", {})
	var base_hearts := 1
	var card_type := ""
	if not card_data.is_empty():
		base_hearts = int(card_data.get("hearts", 1))
		card_type = str(card_data.get("type", "")).strip_edges().to_lower()
	pending_adventure_card.set_meta("adventure_type", card_type)
	if not pending_chain_effects.is_empty():
		pending_adventure_card.set_meta("chain_effects", pending_chain_effects.duplicate())
		pending_chain_effects.clear()
	if card_type == "scontro" or card_type == "maledizione":
		pending_adventure_card.set_meta("adventure_blocking", true)
		pending_adventure_card.set_meta("in_battlefield", true)
		pending_adventure_card.set_meta("battlefield_hearts", base_hearts)
		_spawn_battlefield_hearts(pending_adventure_card, base_hearts)
		pending_adventure_card.call("flip_to_side", target_pos_adv)
	elif card_type == "concatenamento":
		var effects: Array = []
		if not card_data.is_empty():
			effects = card_data.get("effects", [])
		pending_chain_effects = effects.duplicate()
	elif card_type == "evento":
		_reveal_event_card(pending_adventure_card, card_data)
		_hide_adventure_prompt()
		return
	elif card_type == "missione":
		_reveal_mission_card(pending_adventure_card, card_data)
		_hide_adventure_prompt()
		return
	else:
		pending_adventure_card.set_meta("in_battlefield", true)
		pending_adventure_card.set_meta("battlefield_hearts", base_hearts)
		_spawn_battlefield_hearts(pending_adventure_card, base_hearts)
		pending_adventure_card.call("flip_to_side", target_pos_adv)
	_hide_adventure_prompt()

func _get_battlefield_target_pos() -> Vector3:
	var pos := battlefield_pos
	if character_card != null and is_instance_valid(character_card):
		# Align to the actual on-screen center of the character card.
		var rect := _get_card_screen_rect(character_card)
		var target_screen_x := 0.0
		var adv_half_w := 0.0
		if rect.size.x > 0.0:
			target_screen_x = rect.position.x + rect.size.x * 0.5
			adv_half_w = rect.size.x * 0.5
		else:
			var character_center := character_card.global_position + Vector3(CARD_CENTER_X_OFFSET, 0.0, 0.0)
			target_screen_x = camera.unproject_position(character_center).x
		target_screen_x += adv_half_w
		pos.x = _solve_world_x_for_screen_x(target_screen_x, pos)
	return pos

func _solve_world_x_for_screen_x(target_screen_x: float, sample_pos: Vector3) -> float:
	var left := sample_pos.x - 20.0
	var right := sample_pos.x + 20.0
	for _i in 24:
		var mid := (left + right) * 0.5
		var p := Vector3(mid, sample_pos.y, sample_pos.z)
		var sx := camera.unproject_position(p).x
		if sx < target_screen_x:
			left = mid
		else:
			right = mid
	return (left + right) * 0.5

func _spawn_battlefield_hearts(card: Node3D, hearts: int) -> void:
	if card == null or hearts <= 0:
		return
	for child in card.get_children():
		if child is Node3D and child.has_meta("battlefield_heart_token"):
			child.queue_free()
	var spacing := 0.3
	var total_width := (hearts - 1) * spacing
	var start_x := -total_width * 0.5
	for i in hearts:
		var token := TOKEN_SCENE.instantiate()
		card.add_child(token)
		token.set_meta("battlefield_heart_token", true)
		token.position = Vector3(start_x + i * spacing, 0.03, -0.5)
		token.rotation = Vector3(-PI / 2.0, deg_to_rad(randf_range(-4.0, 4.0)), 0.0)
		token.scale = Vector3(0.65, 0.65, 0.65)
		if token.has_method("set_token_texture"):
			token.call_deferred("set_token_texture", HEART_TEXTURE)

func _get_next_mission_side_pos() -> Vector3:
	var base := Vector3(character_pos.x + MISSION_SIDE_OFFSET.x, adventure_reveal_pos.y, character_pos.z + MISSION_SIDE_OFFSET.z)
	var pos := base + Vector3(0.0, mission_side_count * REVEALED_Y_STEP, 0.0)
	mission_side_count += 1
	return pos

func _get_next_event_pos() -> Vector3:
	var pos := event_row_pos + Vector3(event_row_count * EVENT_ROW_SPACING, 0.0, 0.0)
	event_row_count += 1
	return pos

func _reveal_event_card(card: Node3D, card_data: Dictionary) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_adventure_stack", false)
	card.set_meta("in_event_row", true)
	card.set_meta("adventure_type", "evento")
	var target_pos := _get_next_event_pos()
	card.call("flip_to_side", target_pos)

func _reveal_mission_card(card: Node3D, card_data: Dictionary) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_adventure_stack", false)
	card.set_meta("in_mission_side", true)
	card.set_meta("adventure_type", "missione")
	var target_pos := _get_next_mission_side_pos()
	card.call("flip_to_side", target_pos)

func _try_claim_mission(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	if phase_index != 0:
		return
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		return
	if not _is_mission_completed(card_data):
		_report_mission_status(card_data, false)
		return
	_apply_mission_cost(card_data)
	_report_mission_status(card_data, true)
	card.queue_free()

func _is_mission_completed(card_data: Dictionary) -> bool:
	var req := _get_mission_requirements(card_data)
	var enemies_required := int(req.get("defeat_enemies", 0))
	var coins_required := int(req.get("pay_coins", 0))
	if enemies_required <= 0 and coins_required <= 0:
		return false
	if enemies_required > 0 and enemies_defeated_total < enemies_required:
		return false
	if coins_required > 0 and player_gold < coins_required:
		return false
	return true

func _apply_mission_cost(card_data: Dictionary) -> void:
	var req := _get_mission_requirements(card_data)
	var coins_required := int(req.get("pay_coins", 0))
	if coins_required <= 0:
		return
	player_gold = max(0, player_gold - coins_required)
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)

func _get_mission_requirements(card_data: Dictionary) -> Dictionary:
	var req := {
		"defeat_enemies": 0,
		"pay_coins": 0
	}
	if card_data.has("mission") and card_data.get("mission", {}) is Dictionary:
		var mission: Dictionary = card_data.get("mission", {})
		var mtype := str(mission.get("type", "")).strip_edges().to_lower()
		if mtype == "defeat_enemies":
			req["defeat_enemies"] = int(mission.get("count", 0))
		elif mtype == "pay_coins":
			req["pay_coins"] = int(mission.get("cost", 0))
		elif mtype == "defeat_enemies_and_pay_coins":
			req["defeat_enemies"] = int(mission.get("count", 0))
			req["pay_coins"] = int(mission.get("cost", 0))
	if card_data.has("mission_defeat_enemies"):
		req["defeat_enemies"] = max(req["defeat_enemies"], int(card_data.get("mission_defeat_enemies", 0)))
	if card_data.has("mission_pay_coins"):
		req["pay_coins"] = max(req["pay_coins"], int(card_data.get("mission_pay_coins", 0)))
	return req

func _report_mission_status(card_data: Dictionary, completed: bool) -> void:
	if hand_ui == null or not hand_ui.has_method("set_info"):
		return
	var name := str(card_data.get("name", "Missione"))
	if not completed:
		hand_ui.call("set_info", "%s non completata." % name)
		return
	var rewards: Array = card_data.get("reward_brown", [])
	var silver: Array = card_data.get("reward_silver", [])
	if not silver.is_empty():
		rewards = rewards.duplicate()
		rewards.append_array(silver)
	var text := "%s completata!\nPremio:\n-" % name
	if not rewards.is_empty():
		text = "%s completata!\nPremio:\n- %s" % [name, "\n- ".join(rewards)]
	hand_ui.call("set_info", text)

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

func _create_battlefield_warning() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 11
	add_child(prompt_layer)
	battlefield_warning_panel = PanelContainer.new()
	battlefield_warning_panel.visible = false
	battlefield_warning_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	battlefield_warning_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	battlefield_warning_panel.add_theme_stylebox_override("panel", panel_style)
	prompt_layer.add_child(battlefield_warning_panel)

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
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	battlefield_warning_panel.add_child(content)

	battlefield_warning_label = Label.new()
	battlefield_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	battlefield_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battlefield_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	battlefield_warning_label.custom_minimum_size = Vector2(460, 0)
	battlefield_warning_label.add_theme_font_override("font", UI_FONT)
	battlefield_warning_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	battlefield_warning_label.add_theme_constant_override("font_spacing/space", 8)
	battlefield_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battlefield_warning_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battlefield_warning_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(battlefield_warning_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_row.set("theme_override_constants/separation", 20)
	battlefield_warning_ok = Button.new()
	battlefield_warning_ok.text = _ui_text("Ok")
	battlefield_warning_ok.add_theme_font_override("font", UI_FONT)
	battlefield_warning_ok.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	battlefield_warning_ok.add_theme_constant_override("font_spacing/space", 8)
	battlefield_warning_ok.pressed.connect(_hide_battlefield_warning)
	button_row.add_child(battlefield_warning_ok)
	content.add_child(button_row)

func _show_battlefield_warning() -> void:
	if battlefield_warning_panel == null:
		return
	battlefield_warning_label.text = _ui_text("C'e un nemico nel campo di battaglia.\nSe passi al turno successivo i premi restano sul tavolo e non potrai riscattarli.")
	battlefield_warning_panel.visible = true
	_center_battlefield_warning()

func _hide_battlefield_warning() -> void:
	if battlefield_warning_panel != null:
		battlefield_warning_panel.visible = false

func _center_battlefield_warning() -> void:
	if battlefield_warning_panel == null:
		return
	battlefield_warning_panel.custom_minimum_size = Vector2.ZERO
	battlefield_warning_panel.reset_size()
	battlefield_warning_panel.custom_minimum_size = battlefield_warning_panel.get_combined_minimum_size()
	battlefield_warning_panel.reset_size()
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = battlefield_warning_panel.size
	battlefield_warning_panel.position = (view_size - size) * 0.5


func _adjust_selected_card_y(delta: float) -> void:
	if selected_card == null:
		return
	var pos := selected_card.global_position
	pos.y += delta
	selected_card.global_position = pos
	if y_label != null:
		y_label.text = _ui_text("Y carta: %.3f" % pos.y)

func _spawn_sum_label() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	sum_label = Label.new()
	sum_label.text = _ui_text("Somma: -")
	sum_label.position = Vector2(20, 20)
	ui.add_child(sum_label)
	y_label = Label.new()
	y_label.text = _ui_text("Y carta: -")
	y_label.position = Vector2(20, 50)
	ui.add_child(y_label)
	camera_label = Label.new()
	camera_label.text = _ui_text("Camera: -")
	camera_label.position = Vector2(20, 80)
	ui.add_child(camera_label)
	regno_reward_label = Label.new()
	regno_reward_label.text = _ui_text("Regno: -")
	regno_reward_label.position = Vector2(20, 110)
	ui.add_child(regno_reward_label)
	_create_outcome_banner(ui)
	_create_adventure_value_box(ui)
	_create_music_toggle(ui)
	_create_purchase_prompt()
	_create_action_prompt()

func _create_music_toggle(ui_layer: CanvasLayer) -> void:
	music_toggle_button = TextureButton.new()
	music_toggle_button.texture_normal = MUSIC_ON_ICON
	music_toggle_button.texture_pressed = MUSIC_ON_ICON
	music_toggle_button.texture_hover = MUSIC_ON_ICON
	music_toggle_button.toggle_mode = true
	music_toggle_button.button_pressed = true
	var size := Vector2(218, 197)
	if FIGHT_ICON != null:
		size = FIGHT_ICON.get_size()
	size *= 0.1
	music_toggle_button.ignore_texture_size = true
	music_toggle_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	music_toggle_button.custom_minimum_size = size
	music_toggle_button.size = size
	music_toggle_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	music_toggle_button.offset_right = -10.0
	music_toggle_button.offset_left = music_toggle_button.offset_right - size.x
	music_toggle_button.offset_top = 10.0
	music_toggle_button.offset_bottom = music_toggle_button.offset_top + size.y
	music_toggle_button.pressed.connect(_toggle_music)
	ui_layer.add_child(music_toggle_button)

func _toggle_music() -> void:
	if music_player == null or music_toggle_button == null:
		return
	music_player.playing = music_toggle_button.button_pressed
	if music_player.playing:
		music_toggle_button.texture_normal = MUSIC_ON_ICON
		music_toggle_button.texture_pressed = MUSIC_ON_ICON
		music_toggle_button.texture_hover = MUSIC_ON_ICON
	else:
		music_toggle_button.texture_normal = MUSIC_OFF_ICON
		music_toggle_button.texture_pressed = MUSIC_OFF_ICON
		music_toggle_button.texture_hover = MUSIC_OFF_ICON

func _create_coin_total_label() -> void:
	coin_total_label = Label3D.new()
	coin_total_label.font = UI_FONT
	coin_total_label.font_size = 64
	coin_total_label.modulate = Color(1, 1, 1, 1)
	coin_total_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	coin_total_label.pixel_size = 0.01
	coin_total_label.text = "0"
	add_child(coin_total_label)
	_position_coin_total_label()

func _position_coin_total_label() -> void:
	if coin_total_label == null:
		return
	var spawner := get_node_or_null("RewardSpawner") as Node3D
	if spawner == null:
		return
	var offset := Vector3(-0.9, 0.0, -0.3)
	if spawner.has_method("get"):
		offset = spawner.get("coin_offset")
	coin_total_label.global_position = spawner.global_position + offset + Vector3(0.45, 0.15, 0.0)

func _update_coin_total_label() -> void:
	if coin_total_label == null:
		return
	var count := get_tree().get_nodes_in_group("coins").size()
	if count <= 0:
		coin_total_label.visible = false
		return
	coin_total_label.visible = true
	coin_total_label.text = "%d" % count
	_position_coin_total_label()

func _create_adventure_value_box(ui_layer: CanvasLayer) -> void:
	adventure_value_panel = PanelContainer.new()
	adventure_value_panel.visible = false
	adventure_value_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	adventure_value_panel.z_index = 300
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0)
	panel_style.border_width_top = 0
	panel_style.border_width_bottom = 0
	panel_style.border_width_left = 0
	panel_style.border_width_right = 0
	panel_style.border_color = Color(1, 1, 1, 0)
	adventure_value_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(adventure_value_panel)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set("theme_override_constants/separation", 14)
	adventure_value_panel.add_child(row)

	var value_style := StyleBoxFlat.new()
	value_style.bg_color = Color(0.1, 0.2, 0.4, 0.85)
	value_style.border_width_top = 2
	value_style.border_width_bottom = 2
	value_style.border_width_left = 2
	value_style.border_width_right = 2
	value_style.border_color = Color(1, 1, 1, 0.5)

	var monster_panel := PanelContainer.new()
	monster_panel.add_theme_stylebox_override("panel", value_style)
	row.add_child(monster_panel)
	adventure_value_label = Label.new()
	adventure_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	adventure_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	adventure_value_label.add_theme_font_override("font", UI_FONT)
	adventure_value_label.add_theme_font_size_override("font_size", 38)
	adventure_value_label.add_theme_constant_override("font_spacing/space", 8)
	adventure_value_label.text = _ui_text("Mostro: -")
	adventure_value_label.custom_minimum_size = Vector2(260, 90)
	monster_panel.add_child(adventure_value_label)

	compare_button = Button.new()
	if fight_icon != null:
		compare_button.icon = fight_icon
	compare_button.text = ""
	compare_button.expand_icon = true
	compare_button.tooltip_text = _ui_text("Confronta")
	compare_button.custom_minimum_size = Vector2(64, 64)
	compare_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	compare_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	compare_button.mouse_filter = Control.MOUSE_FILTER_STOP
	compare_button.focus_mode = Control.FOCUS_NONE
	compare_button.disabled = true
	compare_button.pressed.connect(_on_compare_pressed)
	row.add_child(compare_button)

	player_value_panel = PanelContainer.new()
	player_value_panel.add_theme_stylebox_override("panel", value_style)
	player_value_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(player_value_panel)
	var player_box := VBoxContainer.new()
	player_box.alignment = BoxContainer.ALIGNMENT_CENTER
	player_box.set("theme_override_constants/separation", 8)
	player_value_panel.add_child(player_box)
	player_value_label = Label.new()
	player_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_value_label.add_theme_font_override("font", UI_FONT)
	player_value_label.add_theme_font_size_override("font_size", 38)
	player_value_label.add_theme_constant_override("font_spacing/space", 8)
	player_value_label.text = _ui_text("Tuo tiro: -")
	player_value_label.custom_minimum_size = Vector2(260, 54)
	player_box.add_child(player_value_label)
	player_dice_buttons_row = HBoxContainer.new()
	player_dice_buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	player_dice_buttons_row.set("theme_override_constants/separation", 6)
	player_dice_buttons_row.mouse_filter = Control.MOUSE_FILTER_PASS
	player_box.add_child(player_dice_buttons_row)
	_center_adventure_value_box()

func _create_outcome_banner(ui_layer: CanvasLayer) -> void:
	outcome_panel = PanelContainer.new()
	outcome_panel.visible = false
	outcome_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outcome_panel.z_index = 500
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.85)
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_color = Color(1, 1, 1, 0.6)
	outcome_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(outcome_panel)

	outcome_label = Label.new()
	outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	outcome_label.add_theme_font_override("font", UI_FONT)
	outcome_label.add_theme_font_size_override("font_size", 96)
	outcome_label.add_theme_constant_override("font_spacing/space", 10)
	outcome_label.text = ""
	outcome_label.custom_minimum_size = Vector2(900, 180)
	outcome_panel.add_child(outcome_label)
	_center_outcome_banner()

func _center_outcome_banner() -> void:
	if outcome_panel == null:
		return
	outcome_panel.custom_minimum_size = Vector2.ZERO
	outcome_panel.reset_size()
	outcome_panel.custom_minimum_size = outcome_panel.get_combined_minimum_size()
	outcome_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size := outcome_panel.size
	outcome_panel.position = Vector2((view_size.x - size.x) * 0.5, 260.0)

func _center_adventure_value_box() -> void:
	if adventure_value_panel == null:
		return
	adventure_value_panel.custom_minimum_size = Vector2.ZERO
	adventure_value_panel.reset_size()
	adventure_value_panel.custom_minimum_size = adventure_value_panel.get_combined_minimum_size()
	adventure_value_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size := adventure_value_panel.size
	adventure_value_panel.position = Vector2((view_size.x - size.x) * 0.5, 160.0)

func _update_camera_label() -> void:
	if camera_label == null:
		return
	var pos := camera.global_position
	var rot := camera.rotation_degrees
	camera_label.text = _ui_text("Cam x=%.2f y=%.2f z=%.2f | Rot x=%.1f y=%.1f z=%.1f | ZoomY=%.2f | FOV=%.1f" % [
		pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, pos.y, camera.fov
	])

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
	purchase_yes_button.text = _ui_text("Si")
	purchase_yes_button.add_theme_font_override("font", UI_FONT)
	purchase_yes_button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	purchase_yes_button.add_theme_constant_override("font_spacing/space", 8)
	purchase_yes_button.pressed.connect(_confirm_purchase)
	purchase_no_button = Button.new()
	purchase_no_button.text = _ui_text("No")
	purchase_no_button.add_theme_font_override("font", UI_FONT)
	purchase_no_button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	purchase_no_button.add_theme_constant_override("font_spacing/space", 8)
	purchase_no_button.pressed.connect(_hide_purchase_prompt)
	button_row.add_child(purchase_yes_button)
	button_row.add_child(purchase_no_button)
	purchase_content.add_child(button_row)

	purchase_panel.add_child(purchase_content)
	prompt_layer.add_child(purchase_panel)

func _create_action_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 12
	add_child(prompt_layer)
	action_prompt_panel = PanelContainer.new()
	action_prompt_panel.visible = false
	action_prompt_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	action_prompt_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	action_prompt_panel.add_theme_stylebox_override("panel", panel_style)
	prompt_layer.add_child(action_prompt_panel)

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
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	action_prompt_panel.add_child(content)

	action_prompt_label = Label.new()
	action_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	action_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	action_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action_prompt_label.custom_minimum_size = Vector2(460, 0)
	action_prompt_label.add_theme_font_override("font", UI_FONT)
	action_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	action_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	action_prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_prompt_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_prompt_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(action_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_row.set("theme_override_constants/separation", 16)
	action_prompt_yes = Button.new()
	action_prompt_yes.text = _ui_text("Si")
	action_prompt_yes.add_theme_font_override("font", UI_FONT)
	action_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	action_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	action_prompt_yes.pressed.connect(_confirm_action_prompt)
	action_prompt_no = Button.new()
	action_prompt_no.text = _ui_text("No")
	action_prompt_no.add_theme_font_override("font", UI_FONT)
	action_prompt_no.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	action_prompt_no.add_theme_constant_override("font_spacing/space", 8)
	action_prompt_no.pressed.connect(_hide_action_prompt)
	button_row.add_child(action_prompt_yes)
	button_row.add_child(action_prompt_no)
	content.add_child(button_row)

	action_prompt_panel.add_child(content)

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
	adventure_prompt_label.text = _ui_text("Vuoi affrontare una nuova avventura?")
	adventure_prompt_label.add_theme_font_override("font", UI_FONT)
	adventure_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(adventure_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.set("theme_override_constants/separation", 20)
	adventure_prompt_yes = Button.new()
	adventure_prompt_yes.text = _ui_text("Si")
	adventure_prompt_yes.add_theme_font_override("font", UI_FONT)
	adventure_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	adventure_prompt_yes.pressed.connect(_confirm_adventure_prompt)
	adventure_prompt_no = Button.new()
	adventure_prompt_no.text = _ui_text("No")
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
	if hand_root.has_signal("request_use_magic"):
		hand_root.connect("request_use_magic", Callable(self, "_on_hand_request_use_magic"))
	if hand_root.has_signal("request_discard_card"):
		hand_root.connect("request_discard_card", Callable(self, "_on_hand_request_discard_card"))

	var view_size := get_viewport().get_visible_rect().size
	var card_height := view_size.y * 0.2
	if hand_root.has_method("populate"):
		hand_root.call("populate", player_hand, card_height)
	if hand_root.has_method("set_gold"):
		hand_root.call("set_gold", player_gold)
	if hand_root.has_method("set_tokens"):
		hand_root.call("set_tokens", player_tombstones)
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
	roll_in_progress = false
	_consume_next_roll_effects(values)
	var total := 0
	for v in values:
		total += v
	last_roll_values = values.duplicate()
	selected_roll_dice.clear()
	for i in last_roll_values.size():
		selected_roll_dice.append(i)
	last_roll_total = total
	roll_pending_apply = true
	last_roll_success = false
	last_roll_penalty = false
	roll_trigger_reset = false
	roll_history.append(total)
	roll_color_history.append(", ".join(names))
	sum_label.text = _ui_text("Risultati: %s | Colori: %s" % [", ".join(roll_history), " | ".join(roll_color_history)])
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", false)

func _consume_next_roll_effects(values: Array[int]) -> void:
	if values.is_empty() or post_roll_effects.is_empty():
		return
	var consumed: Array[String] = []
	for effect in post_roll_effects:
		var name := str(effect).strip_edges()
		match name:
			"next_roll_minus_2_all_dice":
				for i in values.size():
					values[i] = max(1, int(values[i]) - 2)
				consumed.append(name)
			"next_roll_double_then_remove_half":
				for i in values.size():
					values[i] = max(1, int(values[i]) * 2)
				if values.size() > 1:
					var order: Array[int] = []
					for i in values.size():
						order.append(i)
					order.sort_custom(func(a, b):
						return int(values[int(a)]) < int(values[int(b)])
					)
					var remove_count := int(floor(values.size() * 0.5))
					for i in remove_count:
						var idx := int(order[i])
						values[idx] = 1
				consumed.append(name)
			"next_roll_lowest_die_applies_to_all":
				var low := int(values[0])
				for v in values:
					low = min(low, int(v))
				for i in values.size():
					values[i] = low
				consumed.append(name)
			_:
				pass
	if consumed.is_empty():
		return
	for name in consumed:
		post_roll_effects.erase(name)

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
	roll_pending_apply = false
	last_roll_values.clear()
	selected_roll_dice.clear()
	post_roll_effects.clear()

func _get_top_face_value(dice: RigidBody3D) -> int:
	if dice.has_method("get_top_value"):
		return dice.get_top_value()
	return 1

func _get_top_face_name(dice: RigidBody3D) -> String:
	if dice.has_method("get_top_name"):
		return dice.get_top_name()
	return "?"

func _get_effective_difficulty(card_data: Dictionary) -> Dictionary:
	var base := int(card_data.get("difficulty", 0))
	var modifier := 0
	var effects: Array = card_data.get("chain_effects", [])
	for effect in effects:
		var name := str(effect)
		if name == "next_roll_plus_3":
			modifier -= 3
	for effect in post_roll_effects:
		var effect_name := str(effect)
		if effect_name == "next_roll_plus_3":
			modifier -= 3
	var effective := base + modifier
	return {
		"base": base,
		"modifier": modifier,
		"effective": effective
	}

func _update_adventure_value_box() -> void:
	if adventure_value_panel == null or adventure_value_label == null:
		return
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		adventure_value_panel.visible = false
		return
	var data: Dictionary = battlefield.get_meta("card_data", {})
	if data.is_empty():
		adventure_value_panel.visible = false
		return
	var diff_info := _get_effective_difficulty(data)
	var base := int(diff_info.get("base", 0))
	var modifier := int(diff_info.get("modifier", 0))
	var effective := int(diff_info.get("effective", 0))
	if modifier != 0:
		adventure_value_label.text = _ui_text("Mostro: %d\n(mod %d)" % [effective, modifier])
	else:
		adventure_value_label.text = _ui_text("Mostro: %d" % base)
	if player_value_label != null:
		if roll_pending_apply:
			player_value_label.text = _ui_text("Tuo tiro: %d" % last_roll_total)
		else:
			player_value_label.text = _ui_text("Tuo tiro: -")
	_refresh_roll_dice_buttons()
	if compare_button != null:
		compare_button.disabled = not roll_pending_apply
	adventure_value_panel.visible = true

func _refresh_roll_dice_buttons() -> void:
	if player_dice_buttons_row == null:
		return
	var selected := selected_roll_dice.duplicate()
	selected.sort()
	var key := "%s|%s|%s" % [str(roll_pending_apply), str(last_roll_values), str(selected)]
	if key == player_dice_buttons_key:
		return
	player_dice_buttons_key = key
	for child in player_dice_buttons_row.get_children():
		child.queue_free()
	if not roll_pending_apply:
		return
	for i in last_roll_values.size():
		var idx := i
		var value := last_roll_values[idx]
		var btn := Button.new()
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(36, 30)
		btn.text = str(value)
		btn.add_theme_font_override("font", UI_FONT)
		btn.add_theme_font_size_override("font_size", 24)
		btn.button_pressed = selected_roll_dice.has(idx)
		btn.pressed.connect(func() -> void:
			_on_roll_die_button_pressed(idx)
		)
		player_dice_buttons_row.add_child(btn)

func _on_roll_die_button_pressed(index: int) -> void:
	if selected_roll_dice.has(index):
		selected_roll_dice.erase(index)
	else:
		selected_roll_dice.append(index)

func _get_selected_roll_values() -> Array[int]:
	var out: Array[int] = []
	for idx in selected_roll_dice:
		var i := int(idx)
		if i < 0 or i >= last_roll_values.size():
			continue
		out.append(last_roll_values[i])
	return out

func _on_compare_pressed() -> void:
	if not roll_pending_apply:
		return
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		return
	_apply_battlefield_result(battlefield, last_roll_total)

func _apply_battlefield_result(card: Node3D, total: int) -> void:
	if card == null or not is_instance_valid(card):
		return
	var card_data: Dictionary = card.get_meta("card_data", {})
	var diff_info := _get_effective_difficulty(card_data)
	var difficulty := int(diff_info.get("effective", card_data.get("difficulty", 0)))
	var hearts := int(card.get_meta("battlefield_hearts", 1))
	var card_type := str(card_data.get("type", "")).strip_edges().to_lower()
	if card_type == "maledizione" and _has_equipped_effect("ignore_fatigue_if_all_different") and _are_all_roll_values_different(last_roll_values):
		total = min(total, difficulty)
	if card_type == "maledizione":
		if total <= difficulty:
			_move_adventure_to_discard(card)
			last_roll_success = true
			_show_outcome("SUCCESSO", Color(0.2, 0.9, 0.3))
		else:
			_apply_curse(card_data)
			_move_adventure_to_discard(card)
			last_roll_penalty = true
			_show_outcome("INSUCCESSO", Color(0.95, 0.2, 0.2))
		roll_pending_apply = false
		last_roll_values.clear()
		selected_roll_dice.clear()
		post_roll_effects.clear()
		if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
			hand_ui.call("set_phase_button_enabled", true)
		return
	if total <= difficulty:
		hearts -= 1
		if hearts > 0 and _has_equipped_effect("bonus_damage_multiheart"):
			hearts -= 1
		card.set_meta("battlefield_hearts", hearts)
		if hearts <= 0:
			var defeated_pos := card.global_position
			if card_type == "scontro":
				enemies_defeated_total += 1
			_report_battlefield_reward(card_data, total, difficulty)
			_spawn_defeat_explosion(defeated_pos)
			_move_adventure_to_discard(card)
		last_roll_success = true
		if total == difficulty:
			_show_outcome("SUCCESSO PERFETTO", Color(1.0, 0.9, 0.2))
		else:
			_show_outcome("SUCCESSO", Color(0.2, 0.9, 0.3))
	else:
		_apply_failure_penalty(card_data, total)
		last_roll_penalty = true
		_show_outcome("INSUCCESSO", Color(0.95, 0.2, 0.2))
	roll_pending_apply = false
	last_roll_values.clear()
	selected_roll_dice.clear()
	post_roll_effects.clear()
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", true)
	if adventure_value_panel != null:
		adventure_value_panel.visible = false

func _apply_player_heart_loss(amount: int) -> void:
	if amount <= 0:
		return
	var remaining := amount
	if _consume_equipped_prevent_heart_loss() and remaining > 0:
		remaining -= 1
	if _consume_hand_reactive_heart_guard() and remaining > 0:
		remaining -= 1
	if _has_equipped_effect("on_heart_loss_destroy_fatigue"):
		_discard_one_fatigue_from_battlefield()
	player_current_hearts = max(0, player_current_hearts - max(0, remaining))
	_update_hand_ui_stats()

func _consume_equipped_prevent_heart_loss() -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		if not _card_has_timed_effect(data, "sacrifice_prevent_heart_loss", "on_heart_loss"):
			continue
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
		var extra := int(equipped.get_meta("extra_slots", 0))
		if extra > 0:
			_remove_equipment_slots(extra)
		equipped.queue_free()
		return true
	return false

func _consume_hand_reactive_heart_guard() -> bool:
	for i in player_hand.size():
		var card := player_hand[i]
		if not (card is Dictionary):
			continue
		var data := card as Dictionary
		if str(data.get("type", "")).strip_edges().to_lower() != "istantaneo":
			continue
		if not _card_has_timed_effect(data, "reflect_damage_poison", "on_heart_loss"):
			continue
		player_hand.remove_at(i)
		_refresh_hand_ui()
		return true
	return false

func _discard_one_fatigue_from_battlefield() -> void:
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		return
	var card_data: Dictionary = battlefield.get_meta("card_data", {})
	if str(card_data.get("type", "")).strip_edges().to_lower() != "maledizione":
		return
	_move_adventure_to_discard(battlefield)

func _has_equipped_effect(effect_name: String) -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		var effects: Array = data.get("effects", [])
		if effects.has(effect_name):
			return true
	return false

func _card_has_timed_effect(card_data: Dictionary, effect_name: String, when: String = "") -> bool:
	var timed_effects: Array = card_data.get("timed_effects", [])
	for entry in timed_effects:
		if not (entry is Dictionary):
			continue
		var data := entry as Dictionary
		var name := str(data.get("effect", "")).strip_edges()
		if name != effect_name:
			continue
		if when.is_empty():
			return true
		var effect_when := str(data.get("when", "")).strip_edges().to_lower()
		if effect_when == when.strip_edges().to_lower():
			return true
	return false

func _are_all_roll_values_different(values: Array[int]) -> bool:
	if values.size() <= 1:
		return true
	var seen: Dictionary = {}
	for v in values:
		var value := int(v)
		if seen.has(value):
			return false
		seen[value] = true
	return true

func _apply_failure_penalty(card_data: Dictionary, total: int) -> void:
	var penalties: Array = card_data.get("penalty_violet", [])
	if penalties.is_empty():
		return
	var applied: Array[String] = []
	for penalty in penalties:
		var code := str(penalty).strip_edges()
		if code.is_empty():
			continue
		if code.begins_with("lose_heart_"):
			var amount := int(code.get_slice("_", 2))
			_apply_player_heart_loss(max(1, amount))
			applied.append("-%d cuore" % max(1, amount))
			continue
		if code.begins_with("lose_coins_"):
			var coins := int(code.get_slice("_", 2))
			_apply_coin_penalty(max(0, coins))
			applied.append("-%d monete" % max(0, coins))
			continue
		if code == "add_green_die":
			green_dice += 1
			dice_count = _get_total_dice()
			applied.append("+1 dado verde")
			continue
		if code == "discard_hand_card_1":
			if _discard_one_card_for_penalty():
				applied.append("scarta 1 carta")
			continue
		if code == "flip_equipment":
			if _discard_one_equipped_card():
				applied.append("rimuovi 1 equip")
			continue
		if code.begins_with("fail_even_lose_3_coins_or_odd_lose_heart"):
			if int(total) % 2 == 0:
				_apply_coin_penalty(3)
				applied.append("-3 monete")
			else:
				_apply_player_heart_loss(1)
				applied.append("-1 cuore")
			continue
		if code.begins_with("fail_even_discard_or_odd_lose_heart"):
			if int(total) % 2 == 0:
				if _discard_one_card_for_penalty():
					applied.append("scarta 1 carta")
			else:
				_apply_player_heart_loss(1)
				applied.append("-1 cuore")
			continue
		if code.begins_with("fail_even_flip_or_odd_lose_heart"):
			if int(total) % 2 == 0:
				if _discard_one_equipped_card():
					applied.append("rimuovi 1 equip")
			else:
				_apply_player_heart_loss(1)
				applied.append("-1 cuore")
			continue
		if code.begins_with("fail_even_poison_or_odd_lose_heart"):
			# Poison is not modeled yet; fallback to heart loss to keep gameplay consistent.
			_apply_player_heart_loss(1)
			applied.append("-1 cuore")
			continue
	if pending_penalty_discards > 0:
		return
	if hand_ui != null and hand_ui.has_method("set_info") and not applied.is_empty():
		hand_ui.call("set_info", "Penalita applicata:\n- %s" % "\n- ".join(applied))

func _apply_coin_penalty(amount: int) -> void:
	if amount <= 0:
		return
	player_gold = max(0, player_gold - amount)
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)

func _discard_one_hand_card() -> bool:
	if player_hand.is_empty():
		return false
	player_hand.remove_at(player_hand.size() - 1)
	_refresh_hand_ui()
	return true

func _discard_one_card_for_penalty() -> bool:
	# If there are multiple cards, let the player choose.
	if player_hand.size() > 1:
		pending_penalty_discards += 1
		_set_hand_discard_mode(true, "penalty")
		return true
	# Prefer hand discard; if hand is empty fallback to one equipped card.
	if _discard_one_hand_card():
		return true
	return _discard_one_equipped_card()

func _set_hand_discard_mode(active: bool, reason: String = "") -> void:
	if hand_ui == null or not hand_ui.has_method("set_discard_mode"):
		return
	pending_discard_reason = reason if active else ""
	hand_ui.call("set_discard_mode", active)
	if hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not active)
	if active and hand_ui.has_method("set_info"):
		if pending_discard_reason == "hand_limit":
			hand_ui.call("set_info", "Fine turno: scegli carte dalla mano da scartare.")
		else:
			hand_ui.call("set_info", "Penalita: scegli 1 carta dalla mano da scartare.")

func _on_hand_request_discard_card(card: Dictionary) -> void:
	if pending_penalty_discards <= 0:
		return
	var idx := player_hand.find(card)
	if idx < 0:
		return
	player_hand.remove_at(idx)
	pending_penalty_discards = max(0, pending_penalty_discards - 1)
	_refresh_hand_ui()
	if pending_penalty_discards <= 0:
		var finished_reason := pending_discard_reason
		_set_hand_discard_mode(false)
		if hand_ui != null and hand_ui.has_method("set_info"):
			if finished_reason == "hand_limit":
				hand_ui.call("set_info", "Limite mano rispettato.")
			else:
				hand_ui.call("set_info", "Penalita applicata:\n- scarta 1 carta")

func _discard_one_equipped_card() -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
		if equipped == null:
			return true
		var card_data: Dictionary = equipped.get_meta("card_data", {})
		if card_data.is_empty():
			card_data = {"image": ""}
		var extra := int(equipped.get_meta("extra_slots", 0))
		if extra > 0:
			_remove_equipment_slots(extra)
		player_hand.append(card_data)
		equipped.queue_free()
		_refresh_hand_ui()
		return true
	return false

func _spawn_defeat_explosion(world_pos: Vector3) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(0.9, 0.9)
	var flash := MeshInstance3D.new()
	flash.mesh = quad
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.6, 0.2, 0.9)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.1)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	flash.material_override = mat
	flash.global_position = world_pos + Vector3(0.0, 0.12, 0.0)
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3(1.6, 1.6, 1.6), 0.25)
	tween.parallel().tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.25)
	await tween.finished
	if is_instance_valid(flash):
		flash.queue_free()

func _apply_curse(card_data: Dictionary) -> void:
	curse_stats_override = card_data.get("stats", {})
	active_curse_id = str(card_data.get("id", ""))
	_init_character_stats()
	_spawn_equipment_slots(character_card)

func _report_battlefield_reward(card_data: Dictionary, total: int, difficulty: int) -> void:
	var rewards: Array = card_data.get("reward_brown", [])
	if total == difficulty:
		var silver: Array = card_data.get("reward_silver", [])
		rewards = rewards.duplicate()
		rewards.append_array(silver)
	var text := "Premio:\n-"
	if not rewards.is_empty():
		text = "Premio:\n- %s" % "\n- ".join(rewards)
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", text)
	_spawn_battlefield_rewards(rewards, _get_next_coin_pile_center())

func _spawn_battlefield_rewards(rewards: Array, coin_pile_center: Vector3) -> void:
	if rewards.is_empty():
		return
	for reward in rewards:
		var code := str(reward)
		if code.begins_with("reward_coin_"):
			var count := int(code.get_slice("_", 2))
			if count > 0:
				spawn_reward_coins_stack(count, coin_pile_center)
			continue
		match code:
			"reward_group_vaso_di_coccio":
				_spawn_reward_tokens_with_code(1, TOKEN_VASO, code, battlefield_pos)
			"reward_group_chest":
				_spawn_reward_tokens_with_code(1, TOKEN_CHEST, code, battlefield_pos)
			"reward_group_teca":
				_spawn_reward_tokens_with_code(1, TOKEN_TECA, code, battlefield_pos)
			"reward_token_tombstone":
				_spawn_reward_tokens_with_code(1, TOKEN_TOMBSTONE, code, battlefield_pos)

func _get_next_coin_pile_center() -> Vector3:
	var idx := coin_pile_count
	coin_pile_count += 1
	var row := int(idx / COIN_PILE_COLUMNS)
	var col := int(idx % COIN_PILE_COLUMNS)
	return battlefield_pos + Vector3(float(col) * COIN_PILE_SPACING_X, 0.0, float(row) * COIN_PILE_SPACING_Z)

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

func _show_outcome(text: String, color: Color) -> void:
	if outcome_panel == null or outcome_label == null:
		return
	outcome_token += 1
	var token := outcome_token
	outcome_label.text = _ui_text(text)
	outcome_label.add_theme_color_override("font_color", color)
	outcome_panel.visible = true
	_center_outcome_banner()
	await get_tree().create_timer(1.8).timeout
	if outcome_token == token and outcome_panel != null:
		outcome_panel.visible = false

func _hide_outcome() -> void:
	outcome_token += 1
	if outcome_panel != null:
		outcome_panel.visible = false

func spawn_reward_coins(count: int, center: Vector3 = battlefield_pos) -> void:
	if reward_spawner == null:
		return
	if reward_spawner.has_method("spawn_coins"):
		reward_spawner.call("spawn_coins", count, center)

func spawn_reward_coins_stack(count: int, center: Vector3 = battlefield_pos) -> void:
	if reward_spawner == null:
		return
	if reward_spawner.has_method("spawn_coin_stack"):
		reward_spawner.call("spawn_coin_stack", count, center)
		return
	spawn_reward_coins(count, center)

func spawn_reward_tokens(count: int, texture_path: String, center: Vector3 = battlefield_pos) -> Array:
	if reward_spawner == null:
		return []
	if reward_spawner.has_method("spawn_tokens"):
		return reward_spawner.call("spawn_tokens", count, texture_path, center)
	return []

func _spawn_reward_tokens_with_code(count: int, texture_path: String, reward_code: String, center: Vector3) -> void:
	var spawned := spawn_reward_tokens(count, texture_path, center)
	for node in spawned:
		if not (node is Node3D):
			continue
		var token := node as Node3D
		token.set_meta("reward_code", reward_code)

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
		card.set_meta("card_data", adventures[i])
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
	if not curse_stats_override.is_empty():
		stats = curse_stats_override
	player_max_hand = int(stats.get("max_hand", 0))
	player_max_hearts = int(stats.get("max_hearts", 0))
	player_current_hearts = int(stats.get("start_hearts", 0))
	var min_dice := int(stats.get("min_dice", stats.get("start_dice", 1)))
	base_dice_count = max(1, min_dice)
	blue_dice = base_dice_count
	green_dice = 0
	red_dice = 0
	dice_count = _get_total_dice()
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
	if not curse_stats_override.is_empty():
		return int(curse_stats_override.get("max_slots", 0))
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
	var extra := _apply_equipment_extra_slots(card_data)
	card.set_meta("extra_slots", extra)

func _apply_equipment_extra_slots(card_data: Dictionary) -> int:
	var effects: Array = card_data.get("effects", [])
	var extra := 0
	for effect in effects:
		var name := str(effect)
		if name == "armor_extra_slot_1":
			extra += 1
		elif name == "armor_extra_slot_2":
			extra += 2
	if extra <= 0:
		return 0
	_add_equipment_slots(extra)
	return extra

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

func _remove_equipment_slots(count: int) -> void:
	var removed := 0
	while removed < count and equipment_slots.size() > 0:
		var slot := equipment_slots[equipment_slots.size() - 1]
		if slot == null:
			equipment_slots.pop_back()
			continue
		if slot.has_meta("occupied") and slot.get_meta("occupied", false):
			break
		equipment_slots.pop_back()
		slot.queue_free()
		removed += 1
	if removed > 0:
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
	_force_return_equipped_to_hand(card)

func _force_return_equipped_to_hand(card: Node3D) -> void:
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
	var extra := int(card.get_meta("extra_slots", 0))
	if extra > 0:
		_remove_equipment_slots(extra)
	player_hand.append(card_data)
	card.queue_free()
	_refresh_hand_ui()

func _on_hand_request_use_magic(card: Dictionary) -> void:
	if phase_index != 1:
		return
	var card_type := str(card.get("type", "")).strip_edges().to_lower()
	if card_type != "istantaneo":
		return
	if not _is_card_activation_allowed_now(card):
		_show_card_timing_hint(card)
		return
	_show_action_prompt(card, true, null)

func _is_card_activation_allowed_now(card_data: Dictionary) -> bool:
	if phase_index != 1:
		return false
	if roll_in_progress:
		return false
	var action_window := _get_current_card_action_window(card_data)
	if action_window.is_empty():
		return false
	var effects := _get_effects_for_window(card_data, action_window)
	return not effects.is_empty()

func _get_current_card_action_window(card_data: Dictionary) -> String:
	var windows := _get_card_activation_windows(card_data)
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		if windows.has("before_adventure") and _get_top_adventure_card() != null:
			return "before_adventure"
		if windows.has("any_time"):
			return "any_time"
		if windows.has("on_play"):
			return "on_play"
		return ""
	if roll_pending_apply:
		if windows.has("after_roll"):
			return "after_roll"
		if windows.has("after_damage"):
			return "after_damage"
		if windows.has("any_time"):
			return "any_time"
		return ""
	if windows.has("before_roll") or windows.has("next_roll"):
		return "before_roll"
	if windows.has("any_time"):
		return "any_time"
	if windows.has("on_play"):
		return "on_play"
	return ""

func _get_effects_for_window(card_data: Dictionary, action_window: String) -> Array:
	var out: Array = []
	var timed_effects: Array = card_data.get("timed_effects", [])
	if timed_effects.is_empty():
		return card_data.get("effects", []).duplicate()
	for entry in timed_effects:
		if not (entry is Dictionary):
			continue
		var data := entry as Dictionary
		var effect_name := str(data.get("effect", "")).strip_edges()
		var when := str(data.get("when", "")).strip_edges().to_lower()
		if effect_name.is_empty():
			continue
		var matches := (when == action_window)
		if action_window == "before_roll" and when == "next_roll":
			matches = true
		if not matches:
			continue
		if not out.has(effect_name):
			out.append(effect_name)
	return out

func _get_card_activation_windows(card_data: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var timed_effects: Array = card_data.get("timed_effects", [])
	for entry in timed_effects:
		if not (entry is Dictionary):
			continue
		var when := str((entry as Dictionary).get("when", "")).strip_edges().to_lower()
		if when.is_empty():
			continue
		if not out.has(when):
			out.append(when)
	# Fallback for older cards without timed metadata.
	if out.is_empty():
		out.append("after_roll")
	return out

func _show_card_timing_hint(card_data: Dictionary) -> void:
	if hand_ui == null or not hand_ui.has_method("set_info"):
		return
	var name := str(card_data.get("name", "Carta"))
	var windows := _get_card_activation_windows(card_data)
	var readable := " / ".join(windows)
	hand_ui.call("set_info", _ui_text("%s: attivabile in %s." % [name, readable]))

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
	regno_track_rewards = _get_regno_track_rewards()
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
	_update_regno_reward_label()

func _update_regno_reward_label() -> void:
	if regno_reward_label == null:
		return
	if regno_track_rewards.is_empty() or regno_track_index < 0 or regno_track_index >= regno_track_rewards.size():
		regno_reward_label.text = _ui_text("Regno: -")
		return
	var code := str(regno_track_rewards[regno_track_index])
	regno_reward_label.text = _ui_text("Regno: %s" % _format_regno_reward(code))

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
	for entry in CardDatabase.cards_shared:
		if str(entry.get("id", "")) == "shared_regno_del_male":
			var nodes: Array = entry.get("track_nodes", [])
			if nodes is Array:
				return nodes
	for entry in CardDatabase.deck_adventure:
		if str(entry.get("id", "")) == "shared_regno_del_male":
			var nodes: Array = entry.get("track_nodes", [])
			if nodes is Array:
				return nodes
	return []

func _get_regno_track_rewards() -> Array:
	for entry in CardDatabase.cards_shared:
		if str(entry.get("id", "")) == "shared_regno_del_male":
			var rewards: Array = entry.get("track_rewards", [])
			if rewards is Array:
				return rewards
	for entry in CardDatabase.deck_adventure:
		if str(entry.get("id", "")) == "shared_regno_del_male":
			var rewards: Array = entry.get("track_rewards", [])
			if rewards is Array:
				return rewards
	return []

func _format_regno_reward(code: String) -> String:
	match code:
		"start":
			return "Partenza"
		"reward_group_vaso_di_coccio":
			return "Vaso di coccio"
		"reward_group_chest":
			return "Chest"
		"reward_group_teca":
			return "Teca"
		"gain_heart":
			return "Cuore"
		"boss":
			return "Boss"
		"boss_finale":
			return "Boss finale"
		_:
			return code

func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

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
	music_player.volume_db = -28.0
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
