extends Node3D

const DICE_SCENE := preload("res://scenes/Dice.tscn")
const CARD_SCENE := preload("res://scenes/Card.tscn")
const TOKEN_SCENE := preload("res://scenes/Token.tscn")
const TABLE_Y := 0.0
const HAND_UI_SCRIPT := preload("res://scripts/HandUI.gd")
const UI_FONT := preload("res://assets/Font/ARCADECLASSIC.TTF")
const POSITION_BOX_SCENE := preload("res://scenes/PositionBox.tscn")
const MUSIC_TRACK := preload("res://assets/Music/Music.mp3")
const BATTLE_MUSIC_TRACK := preload("res://assets/Music/Battaglia a Turni.mp3")
const MUSIC_ON_ICON := preload("res://assets/Music/sound_on.png")
const MUSIC_OFF_ICON := preload("res://assets/Music/sound_off.png")
const FIGHT_ICON := preload("res://assets/Token/fight.png")
const TOKEN_VASO := "res://assets/Token/vaso.png"
const TOKEN_CHEST := "res://assets/Token/chest.png"
const TOKEN_TECA := "res://assets/Token/teca.png"
const TOKEN_TOMBSTONE := "res://assets/Token/tombstone.png"
const EXPLOSION_SHEET := "res://assets/Animation/explosion.png"
const DECK_UTILS := preload("res://scripts/DeckUtils.gd")
const CARD_TIMING := preload("res://scripts/core/CardTiming.gd")
const DICE_FLOW := preload("res://scripts/core/DiceFlow.gd")
const ACTION_PROMPT := preload("res://scripts/core/ActionPrompt.gd")
const ADVENTURE_PROMPT := preload("res://scripts/core/AdventurePrompt.gd")
const BATTLEFIELD_WARNING := preload("res://scripts/core/BattlefieldWarning.gd")
const PURCHASE_PROMPT := preload("res://scripts/core/PurchasePrompt.gd")
const CORE_UI := preload("res://scripts/core/CoreUI.gd")
const BOARD_CORE := preload("res://scripts/core/BoardCore.gd")
const SPAWN_CORE := preload("res://scripts/core/SpawnCore.gd")
const GNG_SPAWN := preload("res://scripts/decks/ghost_n_goblins/Spawn.gd")
const GNG_RULES := preload("res://scripts/decks/ghost_n_goblins/DeckRules.gd")
const EFFECTS_REGISTRY := preload("res://scripts/effects/EffectsRegistry.gd")

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
var coord_label: Label
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
var dice_drop_panel: PanelContainer
var dice_drop_label: Label
var dice_drop_ok: Button
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
var equipment_slots_y_offset: float = 0.02
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
var pending_discard_paid: bool = false
var pending_effect_card_data: Dictionary = {}
var pending_effect_effects: Array = []
var pending_effect_window: String = ""
var purchase_panel: PanelContainer
var purchase_label: Label
var purchase_yes_button: Button
var purchase_no_button: Button
var purchase_card: Node3D
var purchase_content: VBoxContainer
var sell_prompt_panel: PanelContainer
var sell_prompt_label: Label
var sell_prompt_yes: Button
var sell_prompt_no: Button
var pending_sell_card: Dictionary = {}
var pending_sell_price: int = 0
var adventure_prompt_panel: PanelContainer
var adventure_prompt_label: Label
var adventure_prompt_yes: Button
var adventure_prompt_no: Button
var pending_adventure_card: Node3D
var action_prompt_panel: PanelContainer
var action_prompt_label: Label
var action_prompt_yes: Button
var action_prompt_no: Button
var action_prompt_block_until_ms: int = 0
var pending_action_card_data: Dictionary = {}
var pending_action_is_magic: bool = false
var pending_action_source_card: Node3D
var pending_chain_bonus: int = 0
var pending_chain_choice_cards: Array[Node3D] = []
var pending_chain_choice_active: bool = false
var pending_chain_reveal_lock: bool = false
var position_marker: Node3D
var dragging_marker: bool = false
var marker_drag_offset: Vector3 = Vector3.ZERO
var retreated_this_turn: bool = false
var battlefield_warning_panel: PanelContainer
var battlefield_warning_label: Label
var battlefield_warning_ok: Button
var music_player: AudioStreamPlayer
var battle_music_player: AudioStreamPlayer
var music_toggle_button: TextureButton
var music_fade_tween: Tween
var music_enabled: bool = true
var music_delay_timer: Timer
var fight_icon: Texture2D
var light_tween: Tween
var phase_index: int = 0
var player_max_hearts: int = 0
var player_max_hand: int = 0
var player_current_hearts: int = 0
var curse_stats_override: Dictionary = {}
var active_curse_id: String = ""
var curse_texture_override: String = ""
var pending_curse_unequip_count: int = 0
var active_character_id: String = "character_sir_arthur_a"
const PURCHASE_FONT_SIZE := 44
var treasure_deck_pos := Vector3(-3, 0.0179999992251396, 0)
var treasure_reveal_pos := Vector3(-4, 0.0240000002086163, 0)
var treasure_discard_pos := Vector3(-5.05, 0.0240000002086163, 0.315)
var revealed_treasure_count: int = 0
var discarded_treasure_count: int = 0
var is_treasure_stack_hovered: bool = false
const REVEALED_Y_STEP := 0.01
const TREASURE_REVEALED_Y_STEP := 0.02
const TREASURE_CARD_THICKNESS_Y := 0.04
const TREASURE_DISCARD_Y_STEP := TREASURE_CARD_THICKNESS_Y
const TREASURE_DISCARD_INSERT_Y_BIAS := 0.006
var adventure_deck_pos := Vector3(4, 0.02, 0)
var adventure_reveal_pos := Vector3(2, 0.2, 0)
var battlefield_pos := Vector3(0, 0.02, 0)
var adventure_discard_pos := Vector3(6.1, 0.026, 0.35)
var event_row_pos := Vector3(-4.601, 0.04, 2.330)
var revealed_adventure_count: int = 0
var mission_side_count: int = 0
var event_row_count: int = 0
var chain_row_count: int = 0
var discarded_adventure_count: int = 0
var is_adventure_stack_hovered: bool = false
const ADVENTURE_BACK := "res://assets/cards/ghost_n_goblins/adventure/Back_adventure.png"
const MISSION_SIDE_OFFSET := Vector3(1.6, 0.0, 0.0)
const EVENT_ROW_SPACING := 1.6
const CHAIN_ROW_SPACING := 0.9
const CHAIN_ROW_OFFSET := Vector3(-1.6, 0.0, 0.0)
const TREASURE_REVEAL_OFFSET := Vector3(-1.0, 0.006, 0.0)
const TREASURE_DISCARD_OFFSET := Vector3(-2.05, 0.006, 0.315)
const ADVENTURE_REVEAL_OFFSET := Vector3(5, 0, 0.0)
const ADVENTURE_DISCARD_OFFSET := Vector3(2.1, 0.006, 0.35)
var adventure_image_index: Dictionary = {}
var adventure_variant_cursor: Dictionary = {}
const BOSS_X_EXTRA := 0.8
const BOSS_BACK := "res://assets/cards/ghost_n_goblins/boss/back_Boss.png"
const CHARACTER_FRONT := "res://assets/cards/ghost_n_goblins/singles/sir Arthur A.png"
const CHARACTER_FRONT_B := "res://assets/cards/ghost_n_goblins/singles/Sir Arthur B.png"
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
var regno_final_boss_spawned: bool = false
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
	_spawn_coord_label()
	_spawn_position_marker()
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
	if action_prompt_panel != null and action_prompt_panel.visible and event is InputEventMouseButton and event.pressed:
		if action_prompt_yes != null and action_prompt_yes.get_global_rect().has_point(event.position):
			_confirm_action_prompt()
			return
		if action_prompt_no != null and action_prompt_no.get_global_rect().has_point(event.position):
			_hide_action_prompt()
			return
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			blue_dice = base_dice_count
			green_dice = 0
			red_dice = 0
			dice_count = DICE_FLOW.get_total_dice(self)
			DICE_FLOW.clear_dice(self)
			roll_history.clear()
			roll_color_history.clear()
			if sum_label != null:
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
			DICE_FLOW.launch_dice_at(self, Vector3(0.0, TABLE_Y, 0.0), Vector3.ZERO)
		elif event.keycode == KEY_1:
			spawn_reward_tokens(1, HEART_TEXTURE)
		elif event.keycode == KEY_2:
			spawn_reward_coins(1)
		elif event.keycode == KEY_UP:
			_adjust_camera_pitch(-2.0)
		elif event.keycode == KEY_DOWN:
			_adjust_camera_pitch(2.0)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if Time.get_ticks_msec() < action_prompt_block_until_ms:
		return
	if action_prompt_panel != null and action_prompt_panel.visible and event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_mouse_pos = event.position
			mouse_down_pos = event.position
			var card := _get_card_under_mouse(event.position)
			if card == null and phase_index == 1:
				card = _get_battlefield_boss_at(event.position)
			if pending_curse_unequip_count > 0:
				if card != null and card.has_meta("equipped_slot"):
					_force_return_equipped_to_hand(card)
					pending_curse_unequip_count = max(0, pending_curse_unequip_count - 1)
					if pending_curse_unequip_count == 0:
						_apply_equipment_slot_limit_after_curse()
					_update_curse_unequip_prompt()
				return
			if card != null and card.has_meta("position_marker"):
				selected_card = card
				dragging_marker = true
				var hit := _ray_to_plane(event.position)
				if hit != Vector3.INF:
					marker_drag_offset = card.global_position - hit
				else:
					marker_drag_offset = Vector3.ZERO
				if card.has_method("set_dragging"):
					card.call("set_dragging", true)
				return
			if pending_chain_choice_active:
				if card != null and pending_chain_choice_cards.has(card):
					selected_card = card
				return
			if card == null and phase_index == 1:
				card = _get_adventure_stack_card_at(event.position)
			if card == null and phase_index == 0:
				card = _get_boss_stack_card_at(event.position)
			if card == null and phase_index == 1 and _get_battlefield_card() != null:
				DICE_FLOW.start_dice_hold(self, event.position)
				return
			if card != null:
				if phase_index == 1 and card.has_meta("in_battlefield") and card.get_meta("in_battlefield", false):
					var data: Dictionary
					if card.has_meta("card_data") and card.get_meta("card_data") is Dictionary:
						data = card.get_meta("card_data") as Dictionary
					else:
						data = {}
					var ctype: String = ""
					if not data.is_empty():
						ctype = str(data.get("type", "")).strip_edges().to_lower()
					if ctype == "boss":
						_set_card_hit_enabled(card, true)
						var current_turn: int = -1
						if hand_ui != null and hand_ui.has_method("get_turn_index"):
							current_turn = int(hand_ui.call("get_turn_index"))
						var played_turn: int = int(card.get_meta("played_from_hand_turn", -999))
						if played_turn < 0 or current_turn < 0 or played_turn != current_turn:
							_set_card_hit_enabled(card, false)
							return
						card.set_meta("in_battlefield", false)
						card.set_meta("adventure_blocking", false)
						card.set_meta("battlefield_hearts", 0)
						_set_card_hit_enabled(card, false)
						player_hand.append(data)
						card.queue_free()
						_refresh_hand_ui()
						return
				if phase_index == 0 and card.has_meta("in_mission_side") and card.get_meta("in_mission_side", false):
					_try_claim_mission(card)
					return
				if phase_index == 0 and card.has_meta("in_boss_stack") and card.get_meta("in_boss_stack", false):
					_claim_boss_to_hand_from_stack()
					return
				if phase_index == 0 and _try_spend_tombstone_on_regno(card):
					return
				if phase_index == 0:
					var top_market_left := _get_top_market_card()
					if top_market_left != null and card == top_market_left:
						_try_show_purchase_prompt(card, false)
						return
					var top_discard_left := _get_top_treasure_discard_card()
					if top_discard_left != null and card == top_discard_left:
						_try_show_purchase_prompt(card, true)
						return
				if phase_index == 1 and card.has_meta("equipped_slot"):
					var eq_data: Dictionary = card.get_meta("card_data", {})
					if CARD_TIMING.is_card_activation_allowed_now(self, eq_data):
						_show_action_prompt(eq_data, false, card)
					else:
						CARD_TIMING.show_card_timing_hint(self, eq_data)
					return
				if phase_index == 0 and card.has_meta("equipped_slot"):
					_return_equipped_to_hand(card)
					return
				selected_card = card
				if card.has_method("is_face_up_now") and card.has_method("flip_to_side"):
					if phase_index == 0 and card.has_meta("in_treasure_stack") and card.get_meta("in_treasure_stack", false):
						var top_card := _get_top_treasure_card()
						if top_card != null and top_card.has_method("is_face_up_now"):
							if not top_card.is_face_up_now():
								pending_flip_card = top_card
								pending_flip_is_adventure = false
								return
					elif phase_index == 1 and card.has_meta("in_adventure_stack") and card.get_meta("in_adventure_stack", false):
						var top_adv_left := _get_top_adventure_card()
						if top_adv_left != null and top_adv_left.has_method("is_face_up_now"):
							if not top_adv_left.is_face_up_now():
								pending_flip_card = top_adv_left
								pending_flip_is_adventure = true
								return
				# dragging disabled
		else:
			if dice_hold_active:
				DICE_FLOW.release_dice_hold(self, event.position)
				return
			if dragging_marker:
				dragging_marker = false
				if position_marker != null and is_instance_valid(position_marker) and position_marker.has_method("set_dragging"):
					position_marker.call("set_dragging", false)
				return
			dragged_card = null
			var moved := mouse_down_pos.distance_to(event.position) > CLICK_DRAG_THRESHOLD
			if pending_chain_choice_active and not moved:
				var card := _get_card_under_mouse(event.position)
				if card != null and pending_chain_choice_cards.has(card):
					_resolve_chain_choice(card)
				return
			if not moved and pending_flip_card != null and is_instance_valid(pending_flip_card):
				if pending_flip_is_adventure:
					_try_show_adventure_prompt(pending_flip_card)
				else:
					var target_pos := treasure_reveal_pos
					target_pos.y = treasure_reveal_pos.y + (revealed_treasure_count * TREASURE_REVEALED_Y_STEP)
					pending_flip_card.set_meta("in_treasure_stack", false)
					pending_flip_card.set_meta("in_treasure_market", true)
					pending_flip_card.set_meta("market_index", revealed_treasure_count)
					_lift_treasure_card_to_stack_top(pending_flip_card)
					pending_flip_card.set_meta("flip_rotate_on_lifted_axis", true)
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
					var top_discard := _get_top_treasure_discard_card()
					if top_discard != null and card == top_discard:
						_try_show_purchase_prompt(card, true)
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

func _adjust_camera_pitch(delta: float) -> void:
	if camera == null:
		return
	var rot := camera.rotation_degrees
	rot.x = clamp(rot.x + delta, -89.0, -20.0)
	camera.rotation_degrees = rot

func _release_launch(mouse_pos: Vector2) -> void:
	if launch_start_time < 0.0:
		return
	var _held: float = max(0.0, (Time.get_ticks_msec() / 1000.0) - launch_start_time)
	launch_start_time = -1.0
	var hit: Vector3 = _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	DICE_FLOW.launch_dice_at(self, hit, Vector3.ZERO)

func _process(_delta: float) -> void:
	if phase_index == 0:
		_ensure_treasure_stack_from_discard_if_empty()
	if dragging_marker and position_marker != null and is_instance_valid(position_marker):
		var hit := _ray_to_plane(last_mouse_pos)
		if hit != Vector3.INF:
			position_marker.global_position = hit + marker_drag_offset
		_update_coord_label()
		return
	if dragged_card != null:
		var hit := _ray_to_plane(last_mouse_pos)
		if hit != Vector3.INF:
			var target := hit + drag_offset
			target.y = TABLE_Y + DRAG_HEIGHT
			dragged_card.global_position = target
		_sync_equipment_slots_root()
		return
	if dice_hold_active:
		DICE_FLOW.update_dice_hold(self, last_mouse_pos)
		return
	DICE_FLOW.ensure_idle_dice_preview(self)
	_sync_equipment_slots_root()
	_update_hover(last_mouse_pos)
	_update_purchase_prompt_position()
	_update_adventure_prompt_position()
	_update_coord_label()
	_update_regno_overlay()
	_update_adventure_value_box()
	_update_coin_total_label()

func _launch_dice_at(spawn_pos: Vector3, launch_dir: Vector3) -> void:
	DICE_FLOW.launch_dice_at(self, spawn_pos, launch_dir)

func _start_dice_hold(mouse_pos: Vector2) -> void:
	DICE_FLOW.start_dice_hold(self, mouse_pos)

func _release_dice_hold(mouse_pos: Vector2) -> void:
	DICE_FLOW.release_dice_hold(self, mouse_pos)

func _can_start_roll() -> bool:
	return DICE_FLOW.can_start_roll(self)

func _reset_roll_trigger() -> void:
	DICE_FLOW.reset_roll_trigger(self)

func _spawn_dice_preview() -> void:
	DICE_FLOW.spawn_dice_preview(self)

func _ensure_idle_dice_preview() -> void:
	DICE_FLOW.ensure_idle_dice_preview(self)

func _update_dice_hold(mouse_pos: Vector2) -> void:
	DICE_FLOW.update_dice_hold(self, mouse_pos)

func _clear_dice_preview() -> void:
	DICE_FLOW.clear_dice_preview(self)

func _spawn_dice(spawn_pos: Vector3, launch_dir: Vector3) -> void:
	DICE_FLOW.spawn_dice(self, spawn_pos, launch_dir)

func _spawn_dice_batch(spawn_pos: Vector3, hold_scale: float, launch_dir: Vector3, count: int, dice_type: String, start_index: int) -> int:
	return DICE_FLOW.spawn_dice_batch(self, spawn_pos, hold_scale, launch_dir, count, dice_type, start_index)

func _get_total_dice() -> int:
	return DICE_FLOW.get_total_dice(self)

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
			if node.has_meta("in_treasure_discard") and node.get_meta("in_treasure_discard", false):
				return _get_top_treasure_discard_card()
			if node.has_meta("in_adventure_stack") and node.get_meta("in_adventure_stack", false):
				return _get_top_adventure_card()
			return node
		node = node.get_parent()
	return null

func _get_battlefield_boss_at(mouse_pos: Vector2) -> Node3D:
	var boss := _get_battlefield_card()
	if boss == null or not is_instance_valid(boss):
		return null
	var data: Dictionary = {}
	if boss.has_meta("card_data") and boss.get_meta("card_data") is Dictionary:
		data = boss.get_meta("card_data") as Dictionary
	if data.is_empty():
		return null
	var ctype := str(data.get("type", "")).strip_edges().to_lower()
	if ctype != "boss":
		return null
	var hit := _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return null
	var center := boss.global_position
	if abs(hit.x - center.x) <= CARD_HIT_HALF_SIZE.x and abs(hit.z - center.z) <= CARD_HIT_HALF_SIZE.y:
		return boss
	return null

func _set_card_hit_enabled(card: Node3D, enabled: bool) -> void:
	if card == null:
		return
	var area := card.get_node_or_null("Pivot/HitArea")
	if area == null or not (area is Area3D):
		return
	var hit_area := area as Area3D
	hit_area.collision_layer = 2 if enabled else 0
	hit_area.collision_mask = 0

func _set_card_pivot_right_edge(card: Node3D) -> void:
	if card == null:
		return
	var pivot := card.get_node_or_null("Pivot")
	if pivot == null or not (pivot is Node3D):
		return
	var pivot_node := pivot as Node3D
	var width := 1.4
	pivot_node.position.x = width
	for child in pivot_node.get_children():
		if child is Node3D:
			var node := child as Node3D
			node.position.x -= width

func _get_top_treasure_card() -> Node3D:
	return BOARD_CORE.get_top_treasure_card(self)

func _get_top_treasure_discard_card() -> Node3D:
	return BOARD_CORE.get_top_treasure_discard_card(self)

func _discard_revealed_treasure_cards() -> void:
	BOARD_CORE.discard_revealed_treasure_cards(self)

func _update_treasure_stack_position(new_pos: Vector3) -> void:
	BOARD_CORE.update_treasure_stack_position(self, new_pos)

func _update_adventure_stack_position(new_pos: Vector3) -> void:
	BOARD_CORE.update_adventure_stack_position(self, new_pos)

func _update_boss_stack_position(new_pos: Vector3) -> void:
	BOARD_CORE.update_boss_stack_position(self, new_pos)

func _reposition_stack(meta_key: String, base_pos: Vector3) -> void:
	BOARD_CORE.reposition_stack(self, meta_key, base_pos)

func _reposition_market_stack() -> void:
	BOARD_CORE.reposition_market_stack(self)

func _reposition_discard_stack() -> void:
	BOARD_CORE.reposition_discard_stack(self)

func _reposition_adventure_discard_stack() -> void:
	BOARD_CORE.reposition_adventure_discard_stack(self)

func _move_adventure_to_discard(card: Node3D) -> void:
	BOARD_CORE.move_adventure_to_discard(self, card)

func _get_top_adventure_card() -> Node3D:
	return BOARD_CORE.get_top_adventure_card(self)

func _get_top_boss_card() -> Node3D:
	return BOARD_CORE.get_top_boss_card(self)

func _get_top_market_card() -> Node3D:
	return BOARD_CORE.get_top_market_card(self)

func _get_battlefield_card() -> Node3D:
	return BOARD_CORE.get_battlefield_card(self)

func _get_blocking_adventure_card() -> Node3D:
	return BOARD_CORE.get_blocking_adventure_card(self)

func _try_show_purchase_prompt(card: Node3D, require_gold: bool = true) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if phase_index != 0:
		return false
	var in_market := bool(card.get_meta("in_treasure_market", false))
	var in_discard := bool(card.get_meta("in_treasure_discard", false))
	if not in_market and not in_discard:
		return false
	if in_discard:
		var top_discard := _get_top_treasure_discard_card()
		if top_discard == null or top_discard != card:
			return false
	if not card.has_meta("card_data"):
		return false
	return PURCHASE_PROMPT.show(self, card, require_gold)

func _hide_purchase_prompt() -> void:
	PURCHASE_PROMPT.hide(self)

func _update_purchase_prompt_position() -> void:
	PURCHASE_PROMPT.update_position(self)

func _resize_purchase_prompt() -> void:
	PURCHASE_PROMPT.resize(self)

func _confirm_purchase() -> void:
	PURCHASE_PROMPT.confirm(self)

func _on_phase_changed(new_phase_index: int, _turn_index: int) -> void:
	if new_phase_index == 0 and _block_turn_pass_if_hand_exceeds_limit(_turn_index):
		return
	phase_index = new_phase_index
	if phase_index == 0:
		retreated_this_turn = false
		_ensure_treasure_stack_from_discard_if_empty()
	if phase_index == 1:
		_ensure_portale_infernale_on_top_for_gold_key()
	if phase_index != 0:
		_hide_purchase_prompt()
	if phase_index != 1:
		_hide_adventure_prompt()
	if phase_index == 2:
		await _cleanup_battlefield_rewards_for_recovery()
		_on_end_turn_with_battlefield()
		if not retreated_this_turn:
			_try_advance_regno_track()
		_reset_dice_for_rest()
	_update_phase_music()
	_update_phase_lighting()
	_update_phase_info()

func _ensure_portale_infernale_on_top_for_gold_key() -> void:
	if not _has_equipped_card_id("treasure_chiave_oro"):
		return
	if _is_portale_infernale_in_play():
		return
	_move_portale_infernale_to_top_of_adventure_stack()

func _has_equipped_card_id(card_id: String) -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not bool(slot.get_meta("occupied", false)):
			continue
		var equipped: Node3D = slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {}) as Dictionary
		if str(data.get("id", "")) == card_id:
			return true
	return false

func _is_portale_infernale_in_play() -> bool:
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("card_data"):
			continue
		var data: Dictionary = child.get_meta("card_data", {}) as Dictionary
		if str(data.get("id", "")) != "event_portale_infernale":
			continue
		if bool(child.get_meta("in_battlefield", false)):
			return true
		if bool(child.get_meta("in_event_row", false)):
			return true
		if bool(child.get_meta("in_mission_side", false)):
			return true
	return false

func _move_portale_infernale_to_top_of_adventure_stack() -> void:
	var portal_card: Node3D = null
	var top_index: int = -1
	for child in get_children():
		if not (child is Node3D):
			continue
		if not bool(child.get_meta("in_adventure_stack", false)):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
		if not child.has_meta("card_data"):
			continue
		var data: Dictionary = child.get_meta("card_data", {}) as Dictionary
		if str(data.get("id", "")) == "event_portale_infernale":
			portal_card = child as Node3D
	if portal_card == null:
		return
	if int(portal_card.get_meta("stack_index", -1)) >= top_index:
		return
	portal_card.set_meta("stack_index", top_index + 1)
	BOARD_CORE.reposition_stack(self, "in_adventure_stack", adventure_deck_pos)

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
			if _ensure_treasure_stack_from_discard_if_empty():
				top = _get_top_treasure_card()
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
		var discard_index := _reserve_next_treasure_discard_index()
		top.set_meta("discard_index", discard_index)
		top.set_meta("in_treasure_discard", true)
		var discard_pos := _get_treasure_discard_pos_for_index(discard_index, TREASURE_DISCARD_INSERT_Y_BIAS)
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(top, "global_position", discard_pos, 0.18)
		await tween.finished
		_reposition_discard_stack()

func _flip_treasure_card_for_recovery(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var reveal_pos := treasure_reveal_pos + Vector3(0.0, revealed_treasure_count * TREASURE_REVEALED_Y_STEP, 0.0)
	if card.has_method("flip_to_side"):
		_lift_treasure_card_to_stack_top(card)
		card.set_meta("flip_rotate_on_lifted_axis", true)
		card.call("flip_to_side", reveal_pos)
		await get_tree().create_timer(0.35).timeout
	else:
		card.global_position = reveal_pos

func _lift_treasure_card_to_stack_top(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var deck_top_y: float = treasure_deck_pos.y
	var discard_top_y: float = treasure_discard_pos.y
	var top_deck := _get_top_treasure_card()
	if top_deck != null and is_instance_valid(top_deck):
		deck_top_y = top_deck.global_position.y
	var top_discard := _get_top_treasure_discard_card()
	if top_discard != null and is_instance_valid(top_discard):
		discard_top_y = top_discard.global_position.y
	var lift_y: float = max(deck_top_y, discard_top_y) + TREASURE_CARD_THICKNESS_Y
	# Set the lift height immediately before flip to avoid any tween interruption.
	var pos := card.global_position
	pos.y = lift_y
	card.global_position = pos

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

func _reveal_boss_from_regno() -> void:
	if _get_blocking_adventure_card() != null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("C'e gia un nemico in campo."))
		return
	var boss := _get_top_boss_card()
	if boss == null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessun boss disponibile."))
		return
	boss.set_meta("in_boss_stack", false)
	boss.set_meta("in_battlefield", true)
	boss.set_meta("adventure_blocking", true)
	_set_card_hit_enabled(boss, false)
	var data: Dictionary = boss.get_meta("card_data", {})
	var hearts: int = int(data.get("hearts", 1))
	if hearts < 1:
		hearts = 1
	boss.set_meta("battlefield_hearts", hearts)
	_spawn_battlefield_hearts(boss, hearts)
	if boss.has_method("set_face_up"):
		boss.call("set_face_up", true)
	if boss.has_method("flip_to_side"):
		var target := _get_battlefield_target_pos()
		target.x -= (CARD_CENTER_X_OFFSET + BOSS_X_EXTRA)
		print("BOSS_POS:", target)
		_debug_card_positions(boss, "BOSS")
		boss.call("flip_to_side", target)

func _claim_boss_to_hand_from_regno() -> void:
	var boss := _get_top_boss_card()
	if boss == null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessun boss disponibile."))
		return
	var data: Dictionary = boss.get_meta("card_data", {})
	if data.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Boss non valido."))
		boss.queue_free()
		return
	boss.set_meta("in_boss_stack", false)
	boss.queue_free()
	player_hand.append(data)
	_refresh_hand_ui()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Boss aggiunto alla mano."))

func _claim_boss_to_hand_from_stack() -> void:
	var boss := _get_top_boss_card()
	if boss == null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessun boss disponibile."))
		return
	var data: Dictionary = boss.get_meta("card_data", {})
	if data.is_empty():
		boss.queue_free()
		return
	boss.set_meta("in_boss_stack", false)
	var image_path := str(data.get("image", ""))
	if image_path.is_empty():
		image_path = _find_boss_image(data)
	var reveal_card: Node3D = CARD_SCENE.instantiate()
	add_child(reveal_card)
	reveal_card.global_position = boss.global_position
	reveal_card.rotate_x(-PI / 2.0)
	_set_card_pivot_right_edge(reveal_card)
	reveal_card.set_meta("flip_dir", 1.0)
	reveal_card.set_meta("flip_force_face_up", true)
	if image_path != "" and reveal_card.has_method("set_card_texture"):
		reveal_card.call("set_card_texture", image_path)
	if reveal_card.has_method("set_back_texture"):
		reveal_card.call("set_back_texture", BOSS_BACK)
	if reveal_card.has_method("set_face_up"):
		reveal_card.call("set_face_up", false)
	if reveal_card.has_method("set_sorting_offset"):
		reveal_card.call("set_sorting_offset", 999.0)
	var reveal_pos := boss_deck_pos + Vector3(1.6, 0.02, 0.0)
	if reveal_card.has_method("flip_to_side"):
		reveal_card.call("flip_to_side", reveal_pos)
		await get_tree().create_timer(1.25).timeout
	else:
		reveal_card.global_position = reveal_pos
		await get_tree().create_timer(0.2).timeout
	if is_instance_valid(reveal_card):
		reveal_card.queue_free()
	player_hand.append(data)
	boss.queue_free()
	_refresh_hand_ui()

func _reveal_final_boss_from_regno() -> void:
	if regno_final_boss_spawned:
		return
	if _get_blocking_adventure_card() != null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("C'e gia un nemico in campo."))
		return
	if CardDatabase.deck_boss_finale.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Boss finale non disponibile."))
		return
	var entry: Dictionary = CardDatabase.deck_boss_finale[0]
	var card := CARD_SCENE.instantiate()
	add_child(card)
	card.global_position = _get_battlefield_target_pos()
	card.global_position.x -= (CARD_CENTER_X_OFFSET + BOSS_X_EXTRA)
	card.rotate_x(-PI / 2.0)
	card.set_meta("in_battlefield", true)
	card.set_meta("adventure_blocking", true)
	_set_card_hit_enabled(card, false)
	card.set_meta("card_data", entry)
	var hearts: int = int(entry.get("hearts", 1))
	if hearts < 1:
		hearts = 1
	card.set_meta("battlefield_hearts", hearts)
	_spawn_battlefield_hearts(card, hearts)
	var image_path := str(entry.get("image", ""))
	if image_path != "" and card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", BOSS_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	regno_final_boss_spawned = true

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
	_spawn_battlefield_hearts(battlefield, hearts + 1)

func _try_advance_regno_track() -> void:
	GNG_RULES.try_advance_regno_track(self)

func _try_spend_tombstone_on_regno(card: Node3D) -> bool:
	return GNG_RULES.try_spend_tombstone_on_regno(self, card)

func _reset_dice_for_rest() -> void:
	DICE_FLOW.clear_dice(self)
	roll_pending_apply = false
	blue_dice = base_dice_count + green_dice + red_dice
	green_dice = 0
	red_dice = 0
	dice_count = DICE_FLOW.get_total_dice(self)
	DICE_FLOW.clear_dice_preview(self)
	DICE_FLOW.spawn_dice_preview(self)

func _try_show_adventure_prompt(card: Node3D) -> void:
	if phase_index != 1:
		return
	if _get_blocking_adventure_card() != null:
		_show_battlefield_warning()
		return
	ADVENTURE_PROMPT.show(self, card)

func _hide_adventure_prompt() -> void:
	ADVENTURE_PROMPT.hide(self)

func _decline_adventure_prompt() -> void:
	retreated_this_turn = true
	_hide_adventure_prompt()

func _show_action_prompt(card_data: Dictionary, is_magic: bool, source_card: Node3D = null) -> void:
	if Time.get_ticks_msec() < action_prompt_block_until_ms:
		return
	ACTION_PROMPT.show(self, card_data, is_magic, source_card)

func _hide_action_prompt() -> void:
	action_prompt_block_until_ms = Time.get_ticks_msec() + 400
	ACTION_PROMPT.hide(self)

func _center_action_prompt() -> void:
	ACTION_PROMPT.center(self)

func _confirm_action_prompt() -> void:
	action_prompt_block_until_ms = Time.get_ticks_msec() + 400
	ACTION_PROMPT.confirm(self)

func _use_card_effects(card_data: Dictionary, effects: Array = [], action_window: String = "") -> void:
	if effects.is_empty():
		effects = card_data.get("effects", [])
	if effects.is_empty():
		return
	_hide_outcome()
	var local_effects := effects.duplicate()
	if local_effects.has("return_to_hand") and not pending_action_is_magic and pending_action_source_card != null and is_instance_valid(pending_action_source_card):
		_force_return_equipped_to_hand(pending_action_source_card)
		local_effects.erase("return_to_hand")
	var selected_values := DICE_FLOW.get_selected_roll_values(self)
	if selected_values.is_empty():
		selected_values = last_roll_values.duplicate()
	var reroll_indices: Array[int] = []
	for effect in local_effects:
		var effect_name := str(effect).strip_edges()
		if effect_name.is_empty():
			continue
		if effect_name == "discard_hand_card_1":
			if pending_discard_paid:
				pending_discard_paid = false
				continue
			if player_hand.size() == 1:
				_discard_one_hand_card_for_effect({})
				continue
			if player_hand.size() > 1:
				pending_effect_card_data = card_data
				pending_effect_effects = local_effects.duplicate()
				pending_effect_window = action_window
				pending_penalty_discards = max(pending_penalty_discards, 1)
				_set_hand_discard_mode(true, "effect")
				if hand_ui != null and hand_ui.has_method("set_info"):
					hand_ui.call("set_info", _ui_text("Scegli 1 carta da scartare per attivare l'effetto."))
				return
			if not _discard_one_hand_card_for_effect({}):
				if hand_ui != null and hand_ui.has_method("set_info"):
					hand_ui.call("set_info", _ui_text("Costo non pagato: scarta 1 carta dalla mano."))
				return
			continue
		if EFFECTS_REGISTRY.apply_direct_card_effect(self, effect_name, card_data, action_window):
			continue
		if effect_name == "lowest_die_applies_to_all" and action_window == "before_roll" and not roll_pending_apply:
			GNG_RULES.set_next_roll_lowest(self)
			continue
		if effect_name == "next_roll_double_then_remove_half" and action_window == "before_roll" and not roll_pending_apply:
			GNG_RULES.set_next_roll_clone(self)
			continue
		post_roll_effects.append(effect_name)
		EFFECTS_REGISTRY.collect_reroll_indices(self, effect_name, reroll_indices)
		EFFECTS_REGISTRY.apply_post_roll_effect(self, effect_name, selected_values)
		AbilityRegistry.apply(effect_name, {
			"main": self,
			"card_data": card_data,
			"phase_index": phase_index,
			"roll_total": last_roll_total,
			"roll_values": last_roll_values,
			"selected_roll_values": selected_values
		})
	if reroll_indices.is_empty():
		DICE_FLOW.recalculate_last_roll_total(self)
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
	var removed_card: Dictionary = {}
	for i in player_hand.size():
		if not exclude_card.is_empty() and player_hand[i] == exclude_card:
			continue
		remove_idx = i
		if player_hand[i] is Dictionary:
			removed_card = player_hand[i] as Dictionary
		break
	if remove_idx < 0:
		return false
	player_hand.remove_at(remove_idx)
	_add_hand_card_to_treasure_discard(removed_card)
	_refresh_hand_ui()
	return true

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

func _recalculate_last_roll_total() -> void:
	DICE_FLOW.recalculate_last_roll_total(self)

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
	await DICE_FLOW.wait_for_dice_settle(self, active_dice)
	DICE_FLOW.rebuild_roll_values_from_active_dice(self)
	roll_in_progress = false
	roll_pending_apply = true

func _rebuild_roll_values_from_active_dice() -> void:
	DICE_FLOW.rebuild_roll_values_from_active_dice(self)

func _validate_roll_selection_for_effects(effects: Array) -> bool:
	if not roll_pending_apply:
		return true
	if effects.has("after_roll_set_one_die_to_1"):
		if selected_roll_dice.is_empty():
			_set_selection_error("Seleziona 1 dado da impostare a 1.")
			return false
		if selected_roll_dice.size() > 1:
			_set_selection_error("Seleziona solo 1 dado per questa abilita.")
			return false
		return true
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
		base_hearts = max(1, int(card_data.get("hearts", 1)))
		card_type = str(card_data.get("type", "")).strip_edges().to_lower()
	pending_adventure_card.set_meta("adventure_type", card_type)
	if card_type == "scontro" or card_type == "maledizione":
		pending_adventure_card.set_meta("adventure_blocking", true)
		pending_adventure_card.set_meta("in_battlefield", true)
		pending_adventure_card.set_meta("battlefield_hearts", base_hearts)
		_spawn_battlefield_hearts(pending_adventure_card, base_hearts)
		print("ADV_POS:", target_pos_adv)
		_debug_card_positions(pending_adventure_card, "ADV")
		pending_adventure_card.call("flip_to_side", target_pos_adv)
	elif card_type == "concatenamento":
		pending_chain_reveal_lock = true
		var effects: Array = []
		if not card_data.is_empty():
			effects = card_data.get("effects", [])
		var chain_pos := _get_next_chain_pos(target_pos_adv)
		pending_adventure_card.set_meta("in_battlefield", true)
		pending_adventure_card.set_meta("adventure_blocking", false)
		pending_adventure_card.call("flip_to_side", chain_pos)
		_apply_chain_card_effects(pending_adventure_card, effects)
		_schedule_next_chain_reveal()
		_hide_adventure_prompt()
		return
	elif card_type == "evento":
		pending_chain_reveal_lock = false
		_reveal_event_card(pending_adventure_card, card_data)
		_hide_adventure_prompt()
		return
	elif card_type == "missione":
		pending_chain_reveal_lock = false
		_reveal_mission_card(pending_adventure_card, card_data)
		_hide_adventure_prompt()
		return
	else:
		pending_chain_reveal_lock = false
		pending_adventure_card.set_meta("in_battlefield", true)
		pending_adventure_card.set_meta("battlefield_hearts", base_hearts)
		_spawn_battlefield_hearts(pending_adventure_card, base_hearts)
		pending_adventure_card.call("flip_to_side", target_pos_adv)
	_hide_adventure_prompt()

func _schedule_adventure_discard(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	await get_tree().create_timer(0.7).timeout
	if is_instance_valid(card):
		_move_adventure_to_discard(card)

func _get_next_chain_pos(base_pos: Vector3) -> Vector3:
	return GNG_RULES.get_next_chain_pos(self, base_pos)

func _schedule_next_chain_reveal() -> void:
	await GNG_RULES.schedule_next_chain_reveal(self)

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
	var spacing := 0.42
	var total_width := float(hearts - 1) * spacing
	var start_x := -total_width * 0.5
	# Keep battlefield heart tokens in card-local space so they follow flip/move consistently.
	var base_x := CARD_CENTER_X_OFFSET
	var base_y := 0.92
	var base_z := 0.04
	for i in hearts:
		var token := TOKEN_SCENE.instantiate()
		card.add_child(token)
		token.top_level = false
		token.set_meta("battlefield_heart_token", true)
		token.position = Vector3(base_x + start_x + float(i) * spacing, base_y, base_z)
		token.rotation = Vector3.ZERO
		token.rotate_x(-PI / 2.0)
		token.rotate_y(deg_to_rad(randf_range(-4.0, 4.0)))
		token.scale = Vector3(0.72, 0.72, 0.72)
		if token.has_method("set_token_texture"):
			token.call_deferred("set_token_texture", HEART_TEXTURE)

func _get_treasure_discard_pos_for_index(index: int, y_bias: float = 0.0) -> Vector3:
	return treasure_discard_pos + Vector3(0.0, (float(index) * TREASURE_DISCARD_Y_STEP) + y_bias, 0.0)

func _get_next_treasure_discard_index() -> int:
	return _reserve_next_treasure_discard_index()

func _reserve_next_treasure_discard_index() -> int:
	var idx := discarded_treasure_count
	discarded_treasure_count += 1
	return idx

func _ensure_treasure_stack_from_discard_if_empty() -> bool:
	if _get_top_treasure_card() != null:
		return false
	var recycled: Array[Node3D] = []
	for child in get_children():
		if not (child is Node3D):
			continue
		var card := child as Node3D
		if not card.has_meta("in_treasure_discard"):
			continue
		if not bool(card.get_meta("in_treasure_discard", false)):
			continue
		recycled.append(card)
	if recycled.is_empty():
		return false
	DECK_UTILS.shuffle_deck(recycled)
	for i in recycled.size():
		var card := recycled[i]
		card.set_meta("in_treasure_discard", false)
		card.set_meta("discard_index", -1)
		card.set_meta("in_treasure_market", false)
		card.set_meta("in_treasure_stack", true)
		card.set_meta("stack_index", i)
		card.global_position = treasure_deck_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)
		card.rotation = Vector3(-PI / 2.0, deg_to_rad(randf_range(-1.0, 1.0)), deg_to_rad(randf_range(-0.6, 0.6)))
		if card.has_method("set_face_up"):
			card.call("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call("set_sorting_offset", float(i))
	discarded_treasure_count = 0
	return true

func _debug_card_positions(card: Node3D, label: String) -> void:
	if card == null or not is_instance_valid(card):
		return
	var mesh := card.get_node_or_null("Pivot/Mesh") as MeshInstance3D
	var mesh_pos := Vector3.ZERO
	if mesh != null:
		mesh_pos = mesh.global_position
	print("%s card=%s mesh=%s" % [label, str(card.global_position), str(mesh_pos)])

func _get_next_mission_side_pos() -> Vector3:
	return GNG_RULES.get_next_mission_side_pos(self)

func _get_next_event_pos() -> Vector3:
	return GNG_RULES.get_next_event_pos(self)

func _reveal_event_card(card: Node3D, card_data: Dictionary) -> void:
	GNG_RULES.reveal_event_card(self, card, card_data)

func _reveal_mission_card(card: Node3D, card_data: Dictionary) -> void:
	GNG_RULES.reveal_mission_card(self, card, card_data)

func _try_claim_mission(card: Node3D) -> void:
	GNG_RULES.try_claim_mission(self, card)

func _is_mission_completed(card_data: Dictionary) -> bool:
	return GNG_RULES.is_mission_completed(self, card_data)

func _apply_mission_cost(card_data: Dictionary) -> void:
	GNG_RULES.apply_mission_cost(self, card_data)

func _get_mission_requirements(card_data: Dictionary) -> Dictionary:
	return GNG_RULES.get_mission_requirements(self, card_data)

func _report_mission_status(card_data: Dictionary, completed: bool) -> void:
	GNG_RULES.report_mission_status(self, card_data, completed)

func _resize_adventure_prompt() -> void:
	ADVENTURE_PROMPT.resize(self)

func _update_adventure_prompt_position() -> void:
	ADVENTURE_PROMPT.update_position(self)

func _create_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.create(self)

func _show_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.show(self)

func _hide_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.hide(self)

func _center_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.center(self)


func _adjust_selected_card_y(delta: float) -> void:
	if selected_card == null:
		return
	var pos := selected_card.global_position
	pos.y += delta
	selected_card.global_position = pos

func _spawn_coord_label() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 20
	add_child(ui)
	coord_label = Label.new()
	coord_label.text = _ui_text("Coord: -")
	coord_label.position = Vector2(20, 20)
	coord_label.add_theme_font_override("font", UI_FONT)
	coord_label.add_theme_font_size_override("font_size", 18)
	ui.add_child(coord_label)
	GNG_RULES.create_regno_reward_label(self, ui)
	_create_outcome_banner(ui)
	_create_adventure_value_box(ui)
	_create_music_toggle(ui)
	_create_purchase_prompt()
	_create_action_prompt()
	_create_sell_prompt()
	_create_dice_drop_prompt()

func _spawn_position_marker() -> void:
	if POSITION_BOX_SCENE == null:
		return
	position_marker = POSITION_BOX_SCENE.instantiate()
	if position_marker == null:
		return
	position_marker.set_meta("position_marker", true)
	add_child(position_marker)
	position_marker.global_position = Vector3(4.661, 0.04, 2.491)
	if position_marker.has_method("set_label"):
		position_marker.call_deferred("set_label", "Marker")
	_update_coord_label()

func _get_reward_drop_center() -> Vector3:
	if position_marker != null and is_instance_valid(position_marker):
		return position_marker.global_position
	return battlefield_pos

func _update_coord_label() -> void:
	if coord_label == null:
		return
	if position_marker == null or not is_instance_valid(position_marker):
		coord_label.text = _ui_text("Coord: -")
		return
	var pos := position_marker.global_position
	coord_label.text = _ui_text("Coord: x=%.3f y=%.3f z=%.3f" % [pos.x, pos.y, pos.z])

func _create_music_toggle(ui_layer: CanvasLayer) -> void:
	CORE_UI.create_music_toggle(self, ui_layer)

func _toggle_music() -> void:
	if music_toggle_button == null:
		return
	music_enabled = music_toggle_button.button_pressed
	if music_enabled:
		music_toggle_button.texture_normal = MUSIC_ON_ICON
		music_toggle_button.texture_pressed = MUSIC_ON_ICON
		music_toggle_button.texture_hover = MUSIC_ON_ICON
		_update_phase_music()
	else:
		music_toggle_button.texture_normal = MUSIC_OFF_ICON
		music_toggle_button.texture_pressed = MUSIC_OFF_ICON
		music_toggle_button.texture_hover = MUSIC_OFF_ICON
		if music_fade_tween != null and music_fade_tween.is_valid():
			music_fade_tween.kill()
		if music_player != null:
			music_player.stop()
		if battle_music_player != null:
			battle_music_player.stop()

func _create_coin_total_label() -> void:
	CORE_UI.create_coin_total_label(self)

func _position_coin_total_label() -> void:
	CORE_UI.position_coin_total_label(self)

func _update_coin_total_label() -> void:
	CORE_UI.update_coin_total_label(self)

func _create_adventure_value_box(ui_layer: CanvasLayer) -> void:
	CORE_UI.create_adventure_value_box(self, ui_layer)

func _create_outcome_banner(ui_layer: CanvasLayer) -> void:
	CORE_UI.create_outcome_banner(self, ui_layer)

func _center_outcome_banner() -> void:
	CORE_UI.center_outcome_banner(self)

func _center_adventure_value_box() -> void:
	CORE_UI.center_adventure_value_box(self)

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

func _create_sell_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 10
	add_child(prompt_layer)
	sell_prompt_panel = PanelContainer.new()
	sell_prompt_panel.visible = false
	sell_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	sell_prompt_panel.z_index = 210
	sell_prompt_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sell_prompt_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	sell_prompt_panel.add_theme_stylebox_override("panel", panel_style)

	var content := VBoxContainer.new()
	content.anchor_left = 0.0
	content.anchor_right = 1.0
	content.anchor_top = 0.0
	content.anchor_bottom = 1.0
	content.offset_left = 16.0
	content.offset_right = -16.0
	content.offset_top = 12.0
	content.offset_bottom = -12.0
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.set("theme_override_constants/separation", 8)

	sell_prompt_label = Label.new()
	sell_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	sell_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sell_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sell_prompt_label.custom_minimum_size = Vector2(460, 0)
	sell_prompt_label.add_theme_font_override("font", UI_FONT)
	sell_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	sell_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	sell_prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sell_prompt_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_prompt_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(sell_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.set("theme_override_constants/separation", 24)

	sell_prompt_yes = Button.new()
	sell_prompt_yes.text = _ui_text("Si")
	sell_prompt_yes.add_theme_font_override("font", UI_FONT)
	sell_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	sell_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	sell_prompt_yes.pressed.connect(_confirm_sell_prompt)
	button_row.add_child(sell_prompt_yes)

	sell_prompt_no = Button.new()
	sell_prompt_no.text = _ui_text("No")
	sell_prompt_no.add_theme_font_override("font", UI_FONT)
	sell_prompt_no.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	sell_prompt_no.add_theme_constant_override("font_spacing/space", 8)
	sell_prompt_no.pressed.connect(_hide_sell_prompt)
	button_row.add_child(sell_prompt_no)

	content.add_child(button_row)
	sell_prompt_panel.add_child(content)
	prompt_layer.add_child(sell_prompt_panel)

func _show_sell_prompt(card_data: Dictionary) -> void:
	if phase_index != 0:
		return
	if sell_prompt_panel == null or sell_prompt_label == null:
		return
	var name: String = str(card_data.get("name", "Carta"))
	var cost: int = int(card_data.get("cost", 0))
	var price: int = max(0, cost - 2)
	pending_sell_card = card_data
	pending_sell_price = price
	sell_prompt_label.text = _ui_text("Vuoi vendere %s\nper %d monete?" % [name, price])
	sell_prompt_panel.visible = true
	_center_sell_prompt()

func _center_sell_prompt() -> void:
	if sell_prompt_panel == null:
		return
	sell_prompt_panel.custom_minimum_size = Vector2.ZERO
	sell_prompt_panel.reset_size()
	sell_prompt_panel.custom_minimum_size = sell_prompt_panel.get_combined_minimum_size()
	sell_prompt_panel.reset_size()
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = sell_prompt_panel.size
	sell_prompt_panel.position = (view_size - size) * 0.5

func _hide_sell_prompt() -> void:
	if sell_prompt_panel != null:
		sell_prompt_panel.visible = false
	pending_sell_card = {}
	pending_sell_price = 0

func _confirm_sell_prompt() -> void:
	if pending_sell_card.is_empty():
		_hide_sell_prompt()
		return
	var card_id := str(pending_sell_card.get("id", ""))
	var idx := player_hand.find(pending_sell_card)
	if idx < 0 and card_id != "":
		for i in player_hand.size():
			var data: Variant = player_hand[i]
			if data is Dictionary and str((data as Dictionary).get("id", "")) == card_id:
				idx = i
				break
	if idx >= 0:
		player_hand.remove_at(idx)
		_add_treasure_card_data_to_discard(pending_sell_card)
	player_gold += max(0, pending_sell_price)
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)
	_refresh_hand_ui()
	_hide_sell_prompt()

func _add_treasure_card_data_to_discard(card_data: Dictionary) -> void:
	if card_data.is_empty():
		return
	var card: Node3D = CARD_SCENE.instantiate()
	add_child(card)
	card.set_meta("card_data", card_data.duplicate(true))
	card.set_meta("in_treasure_discard", true)
	card.set_meta("in_treasure_market", false)
	card.set_meta("in_treasure_stack", false)
	card.rotate_x(-PI / 2.0)
	var discard_index := _reserve_next_treasure_discard_index()
	card.set_meta("discard_index", discard_index)
	if card.has_method("set_card_texture"):
		var image_path := str(card_data.get("image", ""))
		if not image_path.is_empty():
			card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", "res://assets/cards/ghost_n_goblins/treasure/back_treasure.png")
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	var discard_pos := _get_treasure_discard_pos_for_index(discard_index, 0.0)
	card.global_position = discard_pos
	_reposition_discard_stack()

func _add_hand_card_to_treasure_discard(card_data: Dictionary) -> void:
	if not _is_treasure_card_data(card_data):
		return
	_add_treasure_card_data_to_discard(card_data)

func _is_treasure_card_data(card_data: Dictionary) -> bool:
	if card_data.is_empty():
		return false
	var card_type := str(card_data.get("type", "")).strip_edges().to_lower()
	if card_type == "equipaggiamento" or card_type == "istantaneo":
		return true
	if card_data.has("cost"):
		return true
	return false

func _create_action_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 12
	add_child(prompt_layer)
	action_prompt_panel = PanelContainer.new()
	action_prompt_panel.visible = false
	action_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
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

	# content already added above

func _create_dice_drop_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 12
	add_child(prompt_layer)
	dice_drop_panel = PanelContainer.new()
	dice_drop_panel.visible = false
	dice_drop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	dice_drop_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	dice_drop_panel.add_theme_stylebox_override("panel", panel_style)

	var content := VBoxContainer.new()
	content.anchor_left = 0.0
	content.anchor_right = 1.0
	content.anchor_top = 0.0
	content.anchor_bottom = 1.0
	content.offset_left = 16.0
	content.offset_right = -16.0
	content.offset_top = 12.0
	content.offset_bottom = -12.0
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.set("theme_override_constants/separation", 8)

	dice_drop_label = Label.new()
	dice_drop_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	dice_drop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_drop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dice_drop_label.custom_minimum_size = Vector2(460, 0)
	dice_drop_label.add_theme_font_override("font", UI_FONT)
	dice_drop_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	dice_drop_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(dice_drop_label)

	dice_drop_ok = Button.new()
	dice_drop_ok.text = _ui_text("Ok")
	dice_drop_ok.add_theme_font_override("font", UI_FONT)
	dice_drop_ok.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	dice_drop_ok.add_theme_constant_override("font_spacing/space", 8)
	dice_drop_ok.pressed.connect(_confirm_drop_half_selection)
	content.add_child(dice_drop_ok)

	dice_drop_panel.add_child(content)
	prompt_layer.add_child(dice_drop_panel)

func _show_drop_half_prompt(count: int) -> void:
	if dice_drop_panel == null or dice_drop_label == null:
		return
	dice_drop_label.text = _ui_text("Seleziona %d dadi che vuoi tenere." % count)
	dice_drop_panel.visible = true
	_center_drop_half_prompt()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Scegli %d dadi e premi Ok." % count))

func _get_pending_drop_half_count() -> int:
	return GNG_RULES.get_pending_drop_half_count(self)

func _set_pending_drop_half_count(value: int) -> void:
	GNG_RULES.set_pending_drop_half_count(self, value)

func _deck_prepare_roll() -> void:
	GNG_RULES.prepare_roll_for_clone(self)

func _deck_apply_roll_overrides(values: Array[int]) -> void:
	GNG_RULES.apply_next_roll_overrides(self, values)

func _deck_after_roll_setup() -> void:
	GNG_RULES.start_drop_half_if_pending(self, last_roll_values.size())
	GNG_RULES.finalize_roll_for_clone(self)

func _center_drop_half_prompt() -> void:
	if dice_drop_panel == null:
		return
	dice_drop_panel.custom_minimum_size = Vector2.ZERO
	dice_drop_panel.reset_size()
	dice_drop_panel.custom_minimum_size = dice_drop_panel.get_combined_minimum_size()
	dice_drop_panel.reset_size()
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = dice_drop_panel.size
	dice_drop_panel.position = (view_size - size) * 0.5

func _hide_drop_half_prompt() -> void:
	if dice_drop_panel != null:
		dice_drop_panel.visible = false

func _confirm_drop_half_selection() -> void:
	var pending_count := _get_pending_drop_half_count()
	if pending_count <= 0:
		_hide_drop_half_prompt()
		return
	if selected_roll_dice.size() != pending_count:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Seleziona %d dadi." % pending_count))
		return
	var drop_indices: Array[int] = []
	for idx in selected_roll_dice:
		var i := int(idx)
		if i >= 0 and i < last_roll_values.size() and i < active_dice.size():
			var die: RigidBody3D = active_dice[i]
			if die != null and die.has_method("get_dice_type"):
				var dtype := str(die.call("get_dice_type"))
				if dtype == "green":
					continue
			drop_indices.append(i)
	if drop_indices.size() != pending_count:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Puoi eliminare solo dadi blu."))
		return
	drop_indices.sort()
	for i in range(drop_indices.size() - 1, -1, -1):
		var drop_idx := int(drop_indices[i])
		if drop_idx >= 0 and drop_idx < active_dice.size():
			var die: RigidBody3D = active_dice[drop_idx]
			if die != null and is_instance_valid(die):
				die.queue_free()
			active_dice.remove_at(drop_idx)
		if drop_idx >= 0 and drop_idx < last_roll_values.size():
			last_roll_values.remove_at(drop_idx)
	_set_pending_drop_half_count(0)
	selected_roll_dice.clear()
	DICE_FLOW.recalculate_last_roll_total(self)
	DICE_FLOW.refresh_roll_dice_buttons(self)
	_hide_drop_half_prompt()

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
	adventure_prompt_no.pressed.connect(_decline_adventure_prompt)
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
	if hand_root.has_signal("request_sell_card"):
		hand_root.connect("request_sell_card", Callable(self, "_on_hand_request_sell_card"))
	if hand_root.has_signal("request_play_boss"):
		hand_root.connect("request_play_boss", Callable(self, "_on_hand_request_play_boss"))

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
	_update_discard_stack_highlight()
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

func _update_discard_stack_highlight() -> void:
	var top_discard := _get_top_treasure_discard_card()
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_method("set_highlighted"):
			continue
		if child.has_meta("discard_index"):
			if child != top_discard:
				child.set_highlighted(false)


func _track_dice_sum() -> void:
	await DICE_FLOW.track_dice_sum(self)

func _consume_next_roll_effects(values: Array[int]) -> void:
	EFFECTS_REGISTRY.consume_next_roll_effects(self, values)
	GNG_RULES.consume_next_roll_effects(self, values)

func _wait_for_dice_settle(dice_list: Array[RigidBody3D]) -> void:
	await DICE_FLOW.wait_for_dice_settle(self, dice_list)

func _clear_dice() -> void:
	DICE_FLOW.clear_dice(self)

func _get_top_face_value(dice: RigidBody3D) -> int:
	return DICE_FLOW.get_top_face_value(self, dice)

func _get_top_face_name(dice: RigidBody3D) -> String:
	return DICE_FLOW.get_top_face_name(self, dice)

func _get_effective_difficulty(card_data: Dictionary) -> Dictionary:
	var base := int(card_data.get("difficulty", 0))
	var modifier := 0
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

func _apply_chain_card_effects(card: Node3D, effects: Array) -> void:
	if card == null or effects.is_empty():
		return
	for effect in effects:
		var name := str(effect).strip_edges()
		if name.is_empty():
			continue
		match name:
			"next_roll_plus_3":
				pending_chain_bonus += 3
				_update_adventure_value_box()
				_hide_outcome()
			"reveal_2_keep_1":
				_reveal_two_adventures_for_choice()
			_:
				pass

func _get_roll_total_with_chain_bonus() -> int:
	var total := last_roll_total
	if pending_chain_bonus != 0:
		total += pending_chain_bonus
	return total

func _consume_chain_bonus() -> void:
	if pending_chain_bonus == 0:
		return
	pending_chain_bonus = 0
	_update_adventure_value_box()

func _reveal_two_adventures_for_choice() -> void:
	if pending_chain_choice_active:
		return
	var cards := _get_top_adventure_cards(2)
	if cards.is_empty():
		return
	var base := _get_battlefield_target_pos()
	var offset := CHAIN_ROW_SPACING * 0.55
	for i in cards.size():
		var card: Node3D = cards[i]
		if card == null or not is_instance_valid(card):
			continue
		card.set_meta("in_adventure_stack", false)
		card.set_meta("in_battlefield", true)
		card.set_meta("adventure_blocking", false)
		var pos := base + Vector3((i * 2 - 1) * offset, 0.0, 0.0)
		card.call("flip_to_side", pos)
	pending_chain_choice_cards = cards
	pending_chain_choice_active = true
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Scala: scegli quale avventura affrontare. L'altra torna in fondo al mazzo."))

func _get_top_adventure_cards(count: int) -> Array[Node3D]:
	var cards: Array[Node3D] = []
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_adventure_stack"):
			continue
		if not child.get_meta("in_adventure_stack", false):
			continue
		cards.append(child)
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("stack_index", -1))
		var b_idx := int(b.get_meta("stack_index", -1))
		return a_idx > b_idx
	)
	if cards.size() > count:
		cards.resize(count)
	return cards

func _resolve_chain_choice(chosen: Node3D) -> void:
	if chosen == null or not is_instance_valid(chosen):
		return
	var other: Node3D = null
	for card in pending_chain_choice_cards:
		if card == chosen:
			continue
		other = card
		break
	pending_chain_choice_cards.clear()
	pending_chain_choice_active = false
	if other != null and is_instance_valid(other):
		_put_adventure_card_on_bottom(other)
	_try_show_adventure_prompt(chosen)

func _put_adventure_card_on_bottom(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var min_index := 0
	var found := false
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_adventure_stack"):
			continue
		if not child.get_meta("in_adventure_stack", false):
			continue
		var idx := int(child.get_meta("stack_index", 0))
		if not found or idx < min_index:
			min_index = idx
			found = true
	if not found:
		min_index = 0
	card.set_meta("in_battlefield", false)
	card.set_meta("adventure_blocking", false)
	card.set_meta("in_adventure_stack", true)
	card.set_meta("stack_index", min_index - 1)
	if card.has_method("set_face_up"):
		card.call("set_face_up", false)
	BOARD_CORE.reposition_stack(self, "in_adventure_stack", adventure_deck_pos)

func _update_adventure_value_box() -> void:
	if adventure_value_panel == null or adventure_value_label == null:
		return
	if phase_index != 1:
		adventure_value_panel.visible = false
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
			var total := _get_roll_total_with_chain_bonus()
			if pending_chain_bonus != 0:
				player_value_label.text = _ui_text("Tuo tiro: %d (+%d)" % [total, pending_chain_bonus])
			else:
				player_value_label.text = _ui_text("Tuo tiro: %d" % total)
		else:
			player_value_label.text = _ui_text("Tuo tiro: -")
	DICE_FLOW.refresh_roll_dice_buttons(self)
	if compare_button != null:
		compare_button.disabled = (not roll_pending_apply) or _get_pending_drop_half_count() > 0
	adventure_value_panel.visible = true

func _refresh_roll_dice_buttons() -> void:
	DICE_FLOW.refresh_roll_dice_buttons(self)

func _on_roll_die_button_pressed(index: int) -> void:
	DICE_FLOW.on_roll_die_button_pressed(self, index)

func _get_selected_roll_values() -> Array[int]:
	return DICE_FLOW.get_selected_roll_values(self)

func _on_compare_pressed() -> void:
	if not roll_pending_apply:
		return
	var battlefield := _get_battlefield_card()
	if battlefield == null:
		return
	var total := _get_roll_total_with_chain_bonus()
	_apply_battlefield_result(battlefield, total)
	_consume_chain_bonus()

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
		if hearts > 0:
			_spawn_battlefield_hearts(card, hearts)
		if hearts <= 0:
			var defeated_pos := card.global_position
			if card_type == "scontro":
				enemies_defeated_total += 1
			_report_battlefield_reward(card_data, total, difficulty)
			_move_adventure_to_discard(card)
			_spawn_defeat_explosion(defeated_pos)
			_cleanup_chain_cards_after_victory()
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

func _cleanup_chain_cards_after_victory() -> void:
	if chain_row_count <= 0 and pending_chain_bonus == 0 and pending_chain_choice_cards.is_empty():
		return
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_battlefield"):
			continue
		if not child.get_meta("in_battlefield", false):
			continue
		var data: Dictionary = child.get_meta("card_data", {})
		var ctype := str(data.get("type", "")).strip_edges().to_lower()
		if ctype == "concatenamento":
			_move_adventure_to_discard(child)
	pending_chain_bonus = 0
	pending_chain_choice_cards.clear()
	pending_chain_choice_active = false
	chain_row_count = 0

func _apply_player_heart_loss(amount: int) -> void:
	if amount <= 0:
		return
	var remaining := amount
	if _consume_equipped_prevent_heart_loss() and remaining > 0:
		remaining -= 1
	if _consume_hand_reactive_heart_guard() and remaining > 0:
		remaining -= 1
	if _has_equipped_effect("reflect_damage_poison"):
		EFFECTS_REGISTRY.apply_direct_damage_to_battlefield(self, 1)
	if _has_equipped_effect("on_heart_loss_destroy_fatigue"):
		_discard_one_fatigue_from_battlefield()
	player_current_hearts = max(0, player_current_hearts - max(0, remaining))
	_update_character_form_for_hearts()
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()

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
		var card: Variant = player_hand[i]
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
	if blue_dice <= base_dice_count:
		return
	blue_dice = max(base_dice_count, blue_dice - 1)
	dice_count = DICE_FLOW.get_total_dice(self)
	if not roll_pending_apply and not roll_in_progress:
		DICE_FLOW.clear_dice_preview(self)
		DICE_FLOW.spawn_dice_preview(self)

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
			dice_count = DICE_FLOW.get_total_dice(self)
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
	var removed_card: Dictionary = {}
	if player_hand[player_hand.size() - 1] is Dictionary:
		removed_card = player_hand[player_hand.size() - 1] as Dictionary
	player_hand.remove_at(player_hand.size() - 1)
	_add_hand_card_to_treasure_discard(removed_card)
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
		elif pending_discard_reason == "effect":
			hand_ui.call("set_info", "Scegli 1 carta da scartare per attivare l'effetto.")
		else:
			hand_ui.call("set_info", "Penalita: scegli 1 carta dalla mano da scartare.")

func _on_hand_request_discard_card(card: Dictionary) -> void:
	if pending_penalty_discards <= 0:
		return
	var idx := player_hand.find(card)
	if idx < 0:
		return
	player_hand.remove_at(idx)
	_add_hand_card_to_treasure_discard(card)
	pending_penalty_discards = max(0, pending_penalty_discards - 1)
	_refresh_hand_ui()
	if pending_penalty_discards <= 0:
		var finished_reason := pending_discard_reason
		_set_hand_discard_mode(false)
		if finished_reason == "effect" and not pending_effect_effects.is_empty():
			pending_discard_paid = true
			var effects := pending_effect_effects.duplicate()
			var card_data := pending_effect_card_data.duplicate()
			var window := pending_effect_window
			pending_effect_card_data = {}
			pending_effect_effects.clear()
			pending_effect_window = ""
			_use_card_effects(card_data, effects, window)
			return
		if hand_ui != null and hand_ui.has_method("set_info"):
			if finished_reason == "hand_limit":
				hand_ui.call("set_info", "Limite mano rispettato.")
			else:
				hand_ui.call("set_info", "Penalita applicata:\n- scarta 1 carta")

func _on_hand_request_sell_card(card: Dictionary) -> void:
	if phase_index != 0:
		return
	var resolved := _resolve_card_data(card)
	_show_sell_prompt(resolved)

func _on_hand_request_play_boss(card: Dictionary) -> void:
	if phase_index != 0:
		return
	if _get_blocking_adventure_card() != null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("C'e gia un nemico in campo."))
		return
	var resolved := _resolve_card_data(card)
	var card_type := str(resolved.get("type", "")).strip_edges().to_lower()
	if card_type != "boss":
		return
	var card_node: Node3D = CARD_SCENE.instantiate()
	add_child(card_node)
	card_node.global_position = _get_battlefield_target_pos()
	card_node.global_position.x -= (CARD_CENTER_X_OFFSET + BOSS_X_EXTRA)
	print("BOSS_POS:", card_node.global_position)
	card_node.rotate_x(-PI / 2.0)
	card_node.set_meta("card_data", resolved)
	card_node.set_meta("in_battlefield", true)
	card_node.set_meta("adventure_blocking", true)
	_set_card_hit_enabled(card_node, false)
	var played_turn: int = -1
	if hand_ui != null and hand_ui.has_method("get_turn_index"):
		played_turn = int(hand_ui.call("get_turn_index"))
	card_node.set_meta("played_from_hand_turn", played_turn)
	var hearts := int(resolved.get("hearts", 2))
	if hearts <= 0:
		hearts = 2
	card_node.set_meta("battlefield_hearts", hearts)
	_spawn_battlefield_hearts(card_node, hearts)
	_debug_card_positions(card_node, "BOSS_HAND")
	var image_path := str(resolved.get("image", ""))
	if image_path == "":
		image_path = _find_boss_image(resolved)
	if image_path != "" and card_node.has_method("set_card_texture"):
		card_node.call_deferred("set_card_texture", image_path)
	if card_node.has_method("set_back_texture"):
		card_node.call_deferred("set_back_texture", BOSS_BACK)
	if card_node.has_method("set_face_up"):
		card_node.call_deferred("set_face_up", true)
	_remove_hand_card(card, resolved)
	_refresh_hand_ui()

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
	var tex := ResourceLoader.load(EXPLOSION_SHEET) as Texture2D
	if tex != null:
		var sprite := AnimatedSprite3D.new()
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.pixel_size = 0.01
		var frames := SpriteFrames.new()
		var frame_count := 5
		var frame_w := int(floor(tex.get_width() / float(frame_count)))
		var frame_h := tex.get_height()
		for i in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * frame_w, 0, frame_w, frame_h)
			frames.add_frame("default", atlas)
		frames.set_animation_speed("default", 12.0)
		frames.set_animation_loop("default", false)
		sprite.sprite_frames = frames
		add_child(sprite)
		sprite.global_position = world_pos + Vector3(0.0, 0.12, 0.0)
		sprite.play("default")
		sprite.animation_finished.connect(func() -> void:
			if is_instance_valid(sprite):
				sprite.queue_free()
		)
		return
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
	add_child(flash)
	flash.global_position = world_pos + Vector3(0.0, 0.12, 0.0)
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3(1.6, 1.6, 1.6), 0.25)
	tween.parallel().tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.25)
	await tween.finished
	if is_instance_valid(flash):
		flash.queue_free()

func _apply_curse(card_data: Dictionary) -> void:
	curse_stats_override = card_data.get("stats", {}) as Dictionary
	active_curse_id = str(card_data.get("id", ""))
	curse_texture_override = _get_curse_texture_path(card_data)
	_apply_character_texture_override()
	_init_character_stats(true)
	player_current_hearts = clamp(player_current_hearts, 0, player_max_hearts)
	_apply_equipment_slot_limit_after_curse()
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()

func _get_curse_texture_path(card_data: Dictionary) -> String:
	var image_path: String = str(card_data.get("image", ""))
	if not image_path.is_empty():
		return image_path
	var from_adventure_index: String = _get_adventure_image_path(card_data)
	if not from_adventure_index.is_empty():
		return from_adventure_index
	return ""

func _apply_character_texture_override() -> void:
	if character_card == null or not is_instance_valid(character_card):
		return
	var texture_path: String = CHARACTER_FRONT
	if not curse_texture_override.is_empty():
		texture_path = curse_texture_override
	elif active_character_id == "character_sir_arthur_b":
		texture_path = CHARACTER_FRONT_B
	if character_card.has_method("set_card_texture"):
		character_card.call_deferred("set_card_texture", texture_path)
	if character_card.has_method("set_face_up"):
		character_card.call_deferred("set_face_up", true)

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
				_spawn_reward_tokens_with_code(1, TOKEN_VASO, code)
			"reward_group_chest":
				_spawn_reward_tokens_with_code(1, TOKEN_CHEST, code)
			"reward_group_teca":
				_spawn_reward_tokens_with_code(1, TOKEN_TECA, code)
			"reward_token_tombstone":
				_spawn_reward_tokens_with_code(1, TOKEN_TOMBSTONE, code)

func _get_next_coin_pile_center() -> Vector3:
	var idx := coin_pile_count
	coin_pile_count += 1
	var row := int(idx / COIN_PILE_COLUMNS)
	var col := int(idx % COIN_PILE_COLUMNS)
	return _get_reward_drop_center() + Vector3(float(col) * COIN_PILE_SPACING_X, 0.0, float(row) * COIN_PILE_SPACING_Z)

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
	SPAWN_CORE.spawn_placeholders(self)

func _spawn_treasure_cards() -> void:
	GNG_SPAWN.spawn_treasure_cards(self)

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

func spawn_reward_coins(count: int, center: Vector3 = Vector3.INF) -> void:
	if center == Vector3.INF:
		center = _get_reward_drop_center()
	SPAWN_CORE.spawn_reward_coins(self, count, center)

func spawn_reward_coins_stack(count: int, center: Vector3 = Vector3.INF) -> void:
	if center == Vector3.INF:
		center = _get_reward_drop_center()
	SPAWN_CORE.spawn_reward_coins_stack(self, count, center)

func spawn_reward_tokens(count: int, texture_path: String, center: Vector3 = Vector3.INF) -> Array:
	if center == Vector3.INF:
		center = _get_reward_drop_center()
	return SPAWN_CORE.spawn_reward_tokens(self, count, texture_path, center)

func _spawn_reward_tokens_with_code(count: int, texture_path: String, reward_code: String, center: Vector3 = Vector3.INF) -> void:
	var spawned := spawn_reward_tokens(count, texture_path, center)
	for node in spawned:
		if not (node is Node3D):
			continue
		var token := node as Node3D
		token.set_meta("reward_code", reward_code)

func _spawn_character_hearts(card: Node3D) -> void:
	_refresh_character_hearts_tokens()

func _refresh_character_hearts_tokens() -> void:
	if character_card == null or not is_instance_valid(character_card):
		return
	for child in character_card.get_children():
		if child is Node3D and child.has_meta("character_heart_token"):
			child.queue_free()
	var hearts: int = max(player_current_hearts, 0)
	if hearts <= 0:
		return
	var spacing: float = 0.3
	var total_width: float = float(hearts - 1) * spacing
	var start_x: float = -total_width * 0.5 + 0.65
	for i in hearts:
		var token := TOKEN_SCENE.instantiate()
		character_card.add_child(token)
		token.set_meta("character_heart_token", true)
		token.position = Vector3(start_x + i * spacing, -1.1, 0.0)
		token.rotation = Vector3(-PI / 2.0, deg_to_rad(randf_range(-4.0, 4.0)), 0.0)
		token.scale = Vector3(0.78, 0.78, 0.78)
		if token.has_method("set_token_texture"):
			token.call_deferred("set_token_texture", HEART_TEXTURE)

func _get_character_hearts() -> int:
	var entry: Dictionary = _get_character_entry(active_character_id)
	if not entry.is_empty():
		var stats: Dictionary = entry.get("stats", {})
		return int(stats.get("start_hearts", 0))
	return 0

func _get_character_stats() -> Dictionary:
	var entry: Dictionary = _get_character_entry(active_character_id)
	if not entry.is_empty():
		return entry.get("stats", {})
	return {}

func _get_character_entry(character_id: String) -> Dictionary:
	for entry in CardDatabase.cards_characters:
		if str(entry.get("id", "")) == character_id:
			return entry
	return {}

func _update_character_form_for_hearts() -> void:
	if not curse_stats_override.is_empty():
		return
	var target_id: String = "character_sir_arthur_a"
	if player_current_hearts <= 1:
		target_id = "character_sir_arthur_b"
	if target_id == active_character_id:
		return
	active_character_id = target_id
	_apply_character_texture_override()
	_init_character_stats(true)

func _spawn_adventure_cards() -> void:
	GNG_SPAWN.spawn_adventure_cards(self)

func _spawn_boss_cards() -> void:
	GNG_SPAWN.spawn_boss_cards(self)

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
	GNG_SPAWN.spawn_character_card(self)

func _init_character_stats(preserve_current: bool = false) -> void:
	var stats: Dictionary = _get_character_stats()
	if not curse_stats_override.is_empty():
		stats = curse_stats_override
	player_max_hand = int(stats.get("max_hand", 0))
	player_max_hearts = int(stats.get("max_hearts", 0))
	if preserve_current:
		player_current_hearts = clamp(player_current_hearts, 0, player_max_hearts)
	else:
		player_current_hearts = int(stats.get("start_hearts", 0))
	var min_dice := int(stats.get("min_dice", stats.get("start_dice", 1)))
	base_dice_count = max(1, min_dice)
	if not preserve_current:
		blue_dice = base_dice_count
		green_dice = 0
		red_dice = 0
	dice_count = DICE_FLOW.get_total_dice(self)
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()

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
	var entry: Dictionary = _get_character_entry(active_character_id)
	if not entry.is_empty():
		var stats: Dictionary = entry.get("stats", {})
		return int(stats.get("max_slots", 0))
	return 0

func _get_equipped_cards_sorted() -> Array[Node3D]:
	var out: Array[Node3D] = []
	var slots_sorted: Array = equipment_slots.duplicate()
	slots_sorted.sort_custom(func(a, b):
		if a == null or b == null:
			return false
		return int(a.get_meta("slot_index", 0)) < int(b.get_meta("slot_index", 0))
	)
	for slot_any in slots_sorted:
		var slot: Area3D = slot_any as Area3D
		if slot == null:
			continue
		var occupied: bool = bool(slot.get_meta("occupied", false))
		if not occupied:
			continue
		var equipped: Node3D = slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		out.append(equipped)
	return out

func _compact_equipment_slots() -> void:
	var equipped_cards: Array[Node3D] = _get_equipped_cards_sorted()
	for slot in equipment_slots:
		if slot == null:
			continue
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
	var target_idx: int = 0
	for card in equipped_cards:
		if target_idx >= equipment_slots.size():
			break
		var target_slot: Area3D = equipment_slots[target_idx]
		target_idx += 1
		if target_slot == null:
			continue
		if card.get_parent() != target_slot:
			card.reparent(target_slot)
		card.position = Vector3(-CARD_CENTER_X_OFFSET, 0.01, 0.0)
		card.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
		card.set_meta("equipped_slot", target_slot)
		target_slot.set_meta("occupied", true)
		target_slot.set_meta("equipped_card", card)

func _apply_equipment_slot_limit_after_curse() -> void:
	if equipment_slots_root == null or character_card == null:
		return
	var target_slots: int = max(0, _get_character_max_slots())
	if equipment_slots.size() < target_slots:
		_add_equipment_slots(target_slots - equipment_slots.size())
		return
	_compact_equipment_slots()
	var equipped_cards: Array[Node3D] = _get_equipped_cards_sorted()
	var equipped_count: int = equipped_cards.size()
	var must_unequip: int = max(0, equipped_count - target_slots)
	if must_unequip > 0:
		pending_curse_unequip_count = must_unequip
		_update_curse_unequip_prompt()
		return
	var extra_slots: int = equipment_slots.size() - target_slots
	if extra_slots > 0:
		_remove_equipment_slots(extra_slots)
	pending_curse_unequip_count = 0
	_update_curse_unequip_prompt()

func _update_curse_unequip_prompt() -> void:
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", pending_curse_unequip_count <= 0)
	if pending_curse_unequip_count <= 0:
		return
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Maledizione: riprendi %d equipaggiamenti in mano." % pending_curse_unequip_count))

func _on_hand_request_place_equipment(card: Dictionary, screen_pos: Vector2) -> void:
	if phase_index != 0:
		return
	var resolved := _resolve_card_data(card)
	var card_type := str(resolved.get("type", "")).strip_edges().to_lower()
	if card_type != "equipaggiamento":
		return
	var slot := _get_equipment_slot_under_mouse(screen_pos)
	if slot == null:
		slot = _get_first_free_equipment_slot()
	if slot == null:
		return
	if slot.has_meta("occupied") and slot.get_meta("occupied", false):
		return
	_place_equipment_in_slot(slot, resolved)
	_remove_hand_card(card, resolved)
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
	var extra: int = 0
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
	var resolved := _resolve_card_data(card)
	var card_type := str(resolved.get("type", "")).strip_edges().to_lower()
	if card_type != "istantaneo":
		return
	if not CARD_TIMING.is_card_activation_allowed_now(self, resolved):
		CARD_TIMING.show_card_timing_hint(self, resolved)
		return
	_show_action_prompt(resolved, true, null)

func _resolve_card_data(card: Dictionary) -> Dictionary:
	var card_id := str(card.get("id", "")).strip_edges()
	if card_id == "":
		return card
	for entry in CardDatabase.cards:
		if str(entry.get("id", "")) == card_id:
			return entry
	return card

func _replace_hand_card(original: Dictionary, resolved: Dictionary) -> void:
	if original == resolved:
		return
	var idx := player_hand.find(original)
	if idx < 0:
		return
	player_hand[idx] = resolved

func _remove_hand_card(original: Dictionary, resolved: Dictionary) -> void:
	var idx := player_hand.find(original)
	if idx < 0 and original != resolved:
		idx = player_hand.find(resolved)
	if idx < 0:
		var original_id := str(original.get("id", ""))
		if original_id != "":
			for i in player_hand.size():
				var data: Variant = player_hand[i]
				if data is Dictionary and str((data as Dictionary).get("id", "")) == original_id:
					idx = i
					break
	if idx >= 0:
		player_hand.remove_at(idx)

func _spawn_regno_del_male() -> void:
	GNG_RULES.spawn_regno_del_male(self)

func _setup_regno_overlay() -> void:
	GNG_RULES.setup_regno_overlay(self)

func _build_regno_boxes() -> void:
	GNG_RULES.build_regno_boxes(self)

func _update_regno_overlay() -> void:
	GNG_RULES.update_regno_overlay(self)

func _update_regno_reward_label() -> void:
	GNG_RULES.update_regno_reward_label(self)

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
	return GNG_RULES.get_regno_track_nodes(self)

func _get_regno_track_rewards() -> Array:
	return GNG_RULES.get_regno_track_rewards(self)

func _format_regno_reward(code: String) -> String:
	return GNG_RULES.format_regno_reward(code)

func _load_texture(path: String) -> Texture2D:
	var tex := load(path)
	if tex is Texture2D:
		return tex
	return null

func _get_boss_stack_card_at(mouse_pos: Vector2) -> Node3D:
	var card := _get_card_under_mouse(mouse_pos)
	if card != null and card.has_meta("in_boss_stack") and card.get_meta("in_boss_stack", false):
		return _get_top_boss_card()
	var top := _get_top_boss_card()
	if top == null:
		return null
	var hit := _ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return null
	var center := boss_deck_pos
	if abs(hit.x - center.x) <= CARD_HIT_HALF_SIZE.x and abs(hit.z - center.z) <= CARD_HIT_HALF_SIZE.y:
		return top
	return null

func _spawn_astaroth() -> void:
	GNG_RULES.spawn_astaroth(self)

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
	music_player.volume_db = -28.0
	music_player.bus = "Master"
	add_child(music_player)
	music_player.play()
	battle_music_player = AudioStreamPlayer.new()
	battle_music_player.stream = BATTLE_MUSIC_TRACK
	battle_music_player.volume_db = -80.0
	battle_music_player.bus = "Master"
	add_child(battle_music_player)
	_update_phase_music(true)

func _update_phase_music(immediate: bool = false) -> void:
	if not music_enabled:
		return
	var to_battle: bool = (phase_index == 1)
	_crossfade_music(to_battle, immediate)

func _crossfade_music(to_battle: bool, immediate: bool = false) -> void:
	if music_player == null or battle_music_player == null:
		return
	if music_fade_tween != null and music_fade_tween.is_valid():
		music_fade_tween.kill()
	if music_delay_timer != null:
		music_delay_timer.stop()
	var target_db := -28.0
	var muted_db := -80.0
	if to_battle:
		if immediate:
			if not battle_music_player.playing:
				battle_music_player.play()
			if not music_player.playing:
				music_player.play()
			battle_music_player.volume_db = target_db
			music_player.volume_db = muted_db
			music_player.stop()
			return
		if music_delay_timer == null:
			music_delay_timer = Timer.new()
			music_delay_timer.one_shot = true
			add_child(music_delay_timer)
		music_delay_timer.wait_time = 3.0
		music_delay_timer.timeout.connect(func() -> void:
			if not music_enabled:
				return
			if phase_index != 1:
				return
			if not battle_music_player.playing:
				battle_music_player.play()
			if not music_player.playing:
				music_player.play()
			music_fade_tween = create_tween()
			music_fade_tween.set_parallel(true)
			music_fade_tween.tween_property(battle_music_player, "volume_db", target_db, 0.8)
			music_fade_tween.tween_property(music_player, "volume_db", muted_db, 0.8)
			music_fade_tween.chain().tween_callback(func() -> void:
				if music_player != null:
					music_player.stop()
			)
		)
		music_delay_timer.start()
	else:
		if not music_player.playing:
			music_player.play()
		if not battle_music_player.playing:
			battle_music_player.play()
		if immediate:
			music_player.volume_db = target_db
			battle_music_player.volume_db = muted_db
			battle_music_player.stop()
			return
		music_fade_tween = create_tween()
		music_fade_tween.set_parallel(true)
		music_fade_tween.tween_property(music_player, "volume_db", target_db, 0.8)
		music_fade_tween.tween_property(battle_music_player, "volume_db", muted_db, 0.8)
		music_fade_tween.chain().tween_callback(func() -> void:
			if battle_music_player != null:
				battle_music_player.stop()
		)

func _strip_variant_suffix(card_name: String) -> String:
	var parts := card_name.split(" ")
	if parts.size() > 1:
		var last := parts[parts.size() - 1]
		if last.is_valid_int():
			parts.remove_at(parts.size() - 1)
			return " ".join(parts)
	return card_name





