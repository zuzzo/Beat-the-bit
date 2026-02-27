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
const TOKEN_XP_1 := "res://assets/Token/1xp.png"
const TOKEN_XP_5 := "res://assets/Token/5xp.png"
const EXPLOSION_SHEET := "res://assets/Animation/explosion.png"
const DECK_UTILS := preload("res://scripts/DeckUtils.gd")
const CARD_TIMING := preload("res://scripts/core/CardTiming.gd")
const DICE_FLOW := preload("res://scripts/core/DiceFlow.gd")
const ACTION_PROMPT := preload("res://scripts/core/ActionPrompt.gd")
const ADVENTURE_PROMPT := preload("res://scripts/core/AdventurePrompt.gd")
const BATTLEFIELD_WARNING := preload("res://scripts/core/BattlefieldWarning.gd")
const PURCHASE_PROMPT := preload("res://scripts/core/PurchasePrompt.gd")
const CORE_UI := preload("res://scripts/core/CoreUI.gd")
const MUSIC_CORE := preload("res://scripts/core/MusicCore.gd")
const PHASE_VISUALS_CORE := preload("res://scripts/core/PhaseVisualsCore.gd")
const REWARD_RESOLUTION_CORE := preload("res://scripts/core/RewardResolutionCore.gd")
const BOSS_FLOW_CORE := preload("res://scripts/core/BossFlowCore.gd")
const HAND_FLOW_CORE := preload("res://scripts/core/HandFlowCore.gd")
const ADVENTURE_FLOW_CORE := preload("res://scripts/core/AdventureFlowCore.gd")
const ADVENTURE_BATTLE_CORE := preload("res://scripts/core/AdventureBattleCore.gd")
const BOARD_CORE := preload("res://scripts/core/BoardCore.gd")
const SPAWN_CORE := preload("res://scripts/core/SpawnCore.gd")
const EFFECTS_REGISTRY := preload("res://scripts/effects/EffectsRegistry.gd")
const CARD_EFFECT_DESCRIPTIONS := {
	"armor_extra_slot_1": "Aggiunge 1 slot equipaggiamento.",
	"armor_extra_slot_2": "Aggiunge 2 slot equipaggiamento.",
	"sacrifice_prevent_heart_loss": "Previene una perdita di cuore (se sacrificata).",
	"discard_revealed_adventure": "Scarta l'avventura rivelata.",
	"reroll_same_dice": "Rilancia i dadi selezionati.",
	"after_roll_minus_1_all_dice": "Dopo il lancio: -1 a tutti i dadi.",
	"after_roll_set_one_die_to_1": "Dopo il lancio: imposta 1 dado a 1.",
	"reroll_5_or_6": "Rilancia i dadi con valore 5 o 6.",
	"halve_even_dice": "Dopo il lancio: dimezza i dadi pari.",
	"add_red_die": "Aggiunge un dado rosso.",
	"add_green_die": "Aggiunge un dado verde.",
	"next_roll_plus_3": "Prima del lancio: +3 alla difficolta avventura.",
	"reflect_damage_poison": "Quando perdi un cuore: riflette danno/veleno.",
	"next_roll_minus_2_all_dice": "Prossimo lancio: -2 a tutti i dadi.",
	"lowest_die_applies_to_all": "Il dado piu basso vale per tutti.",
	"deal_1_damage": "Infligge 1 danno immediato.",
	"remove_one_blue_die": "Rimuove 1 dado blu prima del lancio.",
	"fendente_damage_10_12_return_hand": "Riprendila in mano: infligge 1 danno a nemico con difficolta 10-12.",
	"sferzata_damage_7_9_return_hand": "Riprendila in mano: infligge 1 danno a nemico con difficolta 7-9.",
	"calcio_damage_13_15_return_hand": "Riprendila in mano: infligge 1 danno a nemico con difficolta 13-15.",
	"smoke_cloud_end_turn": "Fine turno: non infliggi e non subisci danno.",
	"equipped_all_dice_minus_1": "Equipaggiata: tutti i dadi hanno -1.",
	"equip_max_hearts_plus_2": "Equipaggiata: +2 limite cuori.",
	"equip_max_hand_plus_2": "Equipaggiata: +2 limite carte.",
	"character_discard_set_blue_zero": "Scarta una carta: imposta 1 dado blu a 0.",
	"next_roll_double_then_remove_half": "Raddoppia i dadi e rimuove la meta piu bassa.",
	"on_heart_loss_destroy_fatigue": "Quando perdi un cuore: rimuovi fatica.",
	"regno_del_male_portal": "Interazione con Regno del male.",
	"sacrifice_open_portal": "Sacrifica per aprire il Portale.",
	"bonus_damage_multiheart": "Bonus danno su nemici con piu cuori.",
	"reset_hearts_and_dice": "Ripristina cuori e dadi base.",
	"return_to_hand": "Ritorna in mano dopo l'uso.",
	"discard_hand_card_1": "Scarta 1 carta dalla mano.",
	"pay_coins_2": "Paga 2 monete.",
	"pay_coins_3": "Paga 3 monete.",
	"pay_coins_4": "Paga 4 monete.",
	"pay_xp_2": "Paga 2 XP.",
	"pay_xp_3": "Paga 3 XP.",
	"pay_xp_4": "Paga 4 XP.",
	"extra_die_then_remove_blue": "Dopo il lancio: paga il costo e rimuovi 1 dado blu (una volta)."
}
const CARD_TIMING_DESCRIPTIONS := {
	"before_roll": "Prima del lancio",
	"after_roll": "Dopo il lancio",
	"before_adventure": "Prima dell'avventura",
	"on_heart_loss": "Quando perdi cuori",
	"equip": "Quando equipaggiata",
	"on_play": "Quando usata",
	"any_time": "In qualunque momento",
	"after_damage": "Dopo il danno",
	"next_roll": "Al prossimo lancio"
}

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
var card_debug_label: Label
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
var dice_drop_mode: String = "drop_half"
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
var player_experience: int = 0
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
var final_boss_prompt_panel: PanelContainer
var final_boss_prompt_label: Label
var final_boss_prompt_yes: Button
var final_boss_prompt_no: Button
var pending_final_boss_cost: int = 0
var map_actions_prompt_panel: PanelContainer
var map_actions_prompt_label: Label
var map_actions_buttons_box: VBoxContainer
var final_boss_table_card: Node3D
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
var adventure_sacrifice_prompt_panel: PanelContainer
var adventure_sacrifice_prompt_label: Label
var adventure_sacrifice_prompt_yes: Button
var adventure_sacrifice_prompt_no: Button
var pending_adventure_sacrifice_prompt_card: Node3D
var pending_adventure_sacrifice_roll_lock: bool = false
var pending_adventure_sacrifice_roll_lock_card: Node3D
var action_prompt_panel: PanelContainer
var action_prompt_label: Label
var action_prompt_yes: Button
var action_prompt_no: Button
var action_prompt_block_until_ms: int = 0
var chain_choice_panel: PanelContainer
var chain_choice_label: Label
var flip_choice_panel: PanelContainer
var flip_choice_label: Label
var pending_action_card_data: Dictionary = {}
var pending_action_is_magic: bool = false
var pending_action_source_card: Node3D
var pending_chain_bonus: int = 0
var pending_chain_choice_cards: Array[Node3D] = []
var pending_chain_choice_active: bool = false
var pending_chain_reveal_lock: bool = false
var pending_flip_equip_choice_cards: Array[Node3D] = []
var pending_flip_equip_choice_active: bool = false
var pending_flip_penalties_to_resolve: int = 0
var pending_mandatory_draw_locks: int = 0
var pending_adventure_sacrifice_waiting_cost: bool = false
var pending_adventure_sacrifice_effect: String = ""
var pending_adventure_sacrifice_card: Node3D
var pending_adventure_sacrifice_sequence_active: bool = false
var pending_adventure_sacrifice_remove_after_roll_count: int = 0
var pending_adventure_sacrifice_remove_choice_count: int = 0
var pending_adventure_sacrifice_slot_card: Node3D
var character_ability_used_this_roll: bool = false
var tyris_backpack_occupied: bool = false
var pending_character_backpack_prompt_mode: String = ""
var match_closed: bool = false
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
var active_curse_data: Dictionary = {}
var pending_curse_unequip_count: int = 0
var pending_forced_unequip_reason: String = "Slot equip ridotti"
var active_character_id: String = "character_sir_arthur_a"
var character_auto_form_by_hearts: bool = true
var character_transform_enabled: bool = false
const PURCHASE_FONT_SIZE := 44
const FINAL_BOSS_DEFAULT_COST := 20
var treasure_deck_pos := Vector3(-3, 0.0179999992251396, 0)
var treasure_reveal_pos := Vector3(-3.5, 0.0240000002086163, 0.0)
var revealed_treasure_count: int = 0
var market_order_counter: int = 0
var is_treasure_stack_hovered: bool = false
const REVEALED_Y_STEP := 0.01
const TREASURE_REVEALED_Y_STEP := 0.02
const TREASURE_CARD_THICKNESS_Y := 0.04
var adventure_deck_pos := Vector3(4, 0.02, 0)
var adventure_reveal_pos := Vector3(2, 0.2, 0)
var battlefield_pos := Vector3(0, 0.02, 0)
var adventure_discard_pos := Vector3(7.25, 0.026, 0.15)
var event_row_pos := Vector3(-4.601, 0.04, 2.330)
var revealed_adventure_count: int = 0
var mission_side_count: int = 0
var event_row_count: int = 0
var chain_row_count: int = 0
var discarded_adventure_count: int = 0
var is_adventure_stack_hovered: bool = false
var ADVENTURE_BACK := "res://assets/cards/ghost_n_goblins/adventure/Back_adventure.png"
const MISSION_SIDE_OFFSET := Vector3(1.6, 0.0, 0.0)
const EVENT_ROW_SPACING := 1.6
const CHAIN_ROW_SPACING := 0.9
const CHAIN_ROW_OFFSET := Vector3(-1.6, 0.0, 0.0)
const CHAIN_Z_STEP := 2.0
const TREASURE_REVEAL_OFFSET := Vector3(-0.5, 0.006, 0.0)
const ADVENTURE_REVEAL_OFFSET := Vector3(5, 0, 0.0)
const ADVENTURE_DISCARD_OFFSET := Vector3(3.25, 0.006, 0.15)
var adventure_image_index: Dictionary = {}
var adventure_variant_cursor: Dictionary = {}
const BOSS_X_EXTRA := 0.8
var BOSS_BACK := "res://assets/cards/ghost_n_goblins/boss/back_Boss.png"
var CHARACTER_FRONT := "res://assets/cards/ghost_n_goblins/singles/sir Arthur A.png"
var CHARACTER_FRONT_B := "res://assets/cards/ghost_n_goblins/singles/Sir Arthur B.png"
var CHARACTER_BACK := "res://assets/cards/ghost_n_goblins/singles/back_personaggio.png"
var REGNO_FRONT := "res://assets/cards/ghost_n_goblins/singles/Regno del male.png"
var REGNO_BACK := "res://assets/cards/ghost_n_goblins/singles/back_regno del male.png"
var ASTAROTH_FRONT := "res://assets/cards/ghost_n_goblins/singles/astaroth.png"
var TREASURE_BACK := "res://assets/cards/ghost_n_goblins/treasure/back_treasure.png"
var deck_spawn: Object
var deck_rules: Object
var active_deck: Dictionary = {}
var active_asset_dirs: Dictionary = {}
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
var reward_token_pile_count: int = 0
var coin_manual_offset: Vector3 = Vector3.ZERO
const COIN_PILE_SPACING_X := 0.8
const COIN_PILE_SPACING_Z := 0.55
const COIN_PILE_COLUMNS := 4
const COIN_MOVE_STEP := 0.2
const COIN_DROP_BASE_POS := Vector3(4.667, 0.012, 1.895)
const TOKEN_DROP_OFFSET := Vector3(0.95, 0.0, 0.35)
const REWARD_TOKEN_SPACING_X := 0.65
const REWARD_TOKEN_SPACING_Z := 0.55
const REWARD_TOKEN_COLUMNS := 2
const CHAIN_CHOICE_X_SPREAD := 1.08
const ADVENTURE_SACRIFICE_SLOT_LOCAL := Vector3(-0.46, 0.065, -0.62)

func _ui_text(text: String) -> String:
	return text.replace(" ", "  ")

func _ready() -> void:
	_configure_active_deck()
	CardDatabase.load_cards(GameConfig.selected_deck_id)
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
	_spawn_hand_ui()
	_create_coin_total_label()
	_update_phase_info()
	_create_adventure_prompt()
	_create_adventure_sacrifice_prompt()
	_create_final_boss_prompt()
	_create_map_actions_prompt()
	_create_chain_choice_prompt()
	_create_flip_choice_prompt()
	_create_battlefield_warning()
	_setup_regno_overlay()
	print("Deck selezionato:", GameConfig.selected_deck_id)
	print("Carte avventura:", CardDatabase.deck_adventure.size())
	# Example usage with placeholders.
	var example_deck := ["c1", "c2", "c3", "c4", "c5"]
	DECK_UTILS.shuffle_deck(example_deck)

func _configure_active_deck() -> void:
	active_deck = DeckRegistry.get_deck(GameConfig.selected_deck_id)
	active_asset_dirs = active_deck.get("asset_dirs", {}) as Dictionary
	var assets: Dictionary = active_deck.get("assets", {}) as Dictionary
	ADVENTURE_BACK = str(assets.get("adventure_back", ADVENTURE_BACK))
	BOSS_BACK = str(assets.get("boss_back", BOSS_BACK))
	CHARACTER_FRONT = str(assets.get("character_front", CHARACTER_FRONT))
	CHARACTER_FRONT_B = str(assets.get("character_front_b", CHARACTER_FRONT_B))
	CHARACTER_BACK = str(assets.get("character_back", CHARACTER_BACK))
	REGNO_FRONT = str(assets.get("regno_front", REGNO_FRONT))
	REGNO_BACK = str(assets.get("regno_back", REGNO_BACK))
	ASTAROTH_FRONT = str(assets.get("final_boss_front", ASTAROTH_FRONT))
	TREASURE_BACK = str(assets.get("treasure_back", TREASURE_BACK))
	active_character_id = str(active_deck.get("character_start_id", "character_sir_arthur_a")).strip_edges()
	if active_character_id.is_empty():
		active_character_id = "character_sir_arthur_a"
	character_auto_form_by_hearts = bool(active_deck.get("character_auto_form_by_hearts", true))
	character_transform_enabled = bool(active_deck.get("character_transform_enabled", false))
	var spawn_path: String = str(active_deck.get("spawn_script", ""))
	var rules_path: String = str(active_deck.get("rules_script", ""))
	var spawn_script: Script = load(spawn_path)
	var rules_script: Script = load(rules_path)
	if spawn_script == null:
		spawn_script = load("res://scripts/decks/ghost_n_goblins/Spawn.gd")
	if rules_script == null:
		rules_script = load("res://scripts/decks/ghost_n_goblins/DeckRules.gd")
	deck_spawn = spawn_script.new()
	deck_rules = rules_script.new()

func _unhandled_input(event: InputEvent) -> void:
	if adventure_sacrifice_prompt_panel != null and adventure_sacrifice_prompt_panel.visible:
		if event is InputEventMouseButton and event.pressed:
			if adventure_sacrifice_prompt_yes != null and adventure_sacrifice_prompt_yes.get_global_rect().has_point(event.position):
				_confirm_adventure_sacrifice_prompt()
				return
			if adventure_sacrifice_prompt_no != null and adventure_sacrifice_prompt_no.get_global_rect().has_point(event.position):
				_hide_adventure_sacrifice_prompt()
				return
		return
	if final_boss_prompt_panel != null and final_boss_prompt_panel.visible and event is InputEventMouseButton and event.pressed:
		if final_boss_prompt_yes != null and final_boss_prompt_yes.get_global_rect().has_point(event.position):
			_confirm_final_boss_prompt()
			return
		if final_boss_prompt_no != null and final_boss_prompt_no.get_global_rect().has_point(event.position):
			_hide_final_boss_prompt()
			return
		return
	if _is_mandatory_action_locked():
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE:
				get_tree().quit()
			return
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and (pending_curse_unequip_count > 0 or pending_chain_choice_active or pending_flip_equip_choice_active):
				_handle_mouse_button(event)
			return
		return
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
		elif event.keycode == KEY_LEFT:
			_nudge_coin_pile(Vector3(-COIN_MOVE_STEP, 0.0, 0.0))
		elif event.keycode == KEY_RIGHT:
			_nudge_coin_pile(Vector3(COIN_MOVE_STEP, 0.0, 0.0))
		elif event.keycode == KEY_UP:
			if event.shift_pressed:
				_adjust_camera_pitch(-2.0)
			else:
				_nudge_coin_pile(Vector3(0.0, 0.0, -COIN_MOVE_STEP))
		elif event.keycode == KEY_DOWN:
			if event.shift_pressed:
				_adjust_camera_pitch(2.0)
			else:
				_nudge_coin_pile(Vector3(0.0, 0.0, COIN_MOVE_STEP))

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if Time.get_ticks_msec() < action_prompt_block_until_ms:
		return
	if action_prompt_panel != null and action_prompt_panel.visible and event.pressed:
		return
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_mouse_pos = event.position
			mouse_down_pos = event.position
			if map_actions_prompt_panel != null and map_actions_prompt_panel.visible:
				return
			var card := _get_card_under_mouse(event.position)
			if card == null and phase_index == 1:
				card = _get_battlefield_boss_at(event.position)
			if pending_curse_unequip_count > 0:
				if card != null and card.has_meta("equipped_slot"):
					_force_return_equipped_to_hand(card)
					pending_curse_unequip_count = max(0, pending_curse_unequip_count - 1)
					if pending_curse_unequip_count == 0:
						_apply_equipment_slot_limit_after_curse(pending_forced_unequip_reason)
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
			if pending_flip_equip_choice_active:
				if card != null and pending_flip_equip_choice_cards.has(card):
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
				_show_card_debug_info(card)
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
				if phase_index == 1 and _try_activate_portale_infernale(card):
					return
				if phase_index == 1 and _try_activate_character_card_ability(card):
					return
				if phase_index == 1 and _try_activate_adventure_sacrifice(card):
					return
				if phase_index == 0 and card.has_meta("in_boss_stack") and card.get_meta("in_boss_stack", false):
					if hand_ui != null and hand_ui.has_method("set_info"):
						hand_ui.call("set_info", _ui_text("I boss non si girano manualmente: si rivelano solo tramite evento."))
					return
				if (phase_index == 0 or phase_index == 1) and _try_show_map_actions_prompt(card):
					return
				if phase_index == 0 and _try_spend_tombstone_on_regno(card):
					return
				if phase_index == 0 and _try_show_final_boss_prompt(card):
					return
				if phase_index == 0 and _try_activate_character_backpack_ability(card):
					return
				if _try_transform_character(card):
					return
				if phase_index == 0:
					var top_market_left := _get_top_market_card()
					if top_market_left != null and card == top_market_left:
						_try_show_purchase_prompt(card, false)
						return
				if phase_index == 1 and card.has_meta("equipped_slot"):
					if _is_adventure_sacrifice_resolution_pending():
						if hand_ui != null and hand_ui.has_method("set_info"):
							hand_ui.call("set_info", _ui_text("Completa prima l'approccio alternativo: lancia e rimuovi i dadi richiesti."))
						return
					if bool(card.get_meta("equipped_flipped", false)):
						if hand_ui != null and hand_ui.has_method("set_info"):
							hand_ui.call("set_info", _ui_text("Equipaggiamento girato: non utilizzabile ora."))
						return
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
			if pending_flip_equip_choice_active and not moved:
				var card := _get_card_under_mouse(event.position)
				if card != null and pending_flip_equip_choice_cards.has(card):
					_resolve_flip_equipment_choice(card)
				return
			if not moved and pending_flip_card != null and is_instance_valid(pending_flip_card):
				if pending_flip_is_adventure:
					_try_show_adventure_prompt(pending_flip_card)
				else:
					var target_pos := treasure_reveal_pos
					target_pos.y = treasure_reveal_pos.y + (revealed_treasure_count * TREASURE_REVEALED_Y_STEP)
					pending_flip_card.set_meta("in_treasure_stack", false)
					pending_flip_card.set_meta("in_treasure_market", true)
					pending_flip_card.set_meta("market_index", _reserve_next_market_index())
					pending_flip_card.set_meta("in_treasure_reveal_animation", true)
					_lift_treasure_card_to_stack_top(pending_flip_card)
					pending_flip_card.set_meta("flip_rotate_on_lifted_axis", true)
					pending_flip_card.call("flip_to_side", target_pos)
					revealed_treasure_count += 1
					_finalize_treasure_reveal_animation(pending_flip_card, 1.45)
			pending_flip_card = null
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			if hand_ui != null and hand_ui.has_method("consume_right_click_capture"):
				if bool(hand_ui.call("consume_right_click_capture")):
					return
			last_mouse_pos = event.position
			var card: Node3D = _get_card_under_mouse(event.position)
			if card == null and phase_index == 1:
				card = _get_adventure_stack_card_at(event.position)
			if card == null and phase_index == 0:
				card = _get_boss_stack_card_at(event.position)
			if card == null and phase_index == 1:
				card = _get_battlefield_boss_at(event.position)
			if card != null:
				_show_card_debug_info(card)
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
	if phase_index == 0 and not _has_active_treasure_reveal_animation():
		_ensure_treasure_stack_from_market_if_empty()
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
	if final_boss_prompt_panel != null and final_boss_prompt_panel.visible:
		_center_final_boss_prompt()
	if map_actions_prompt_panel != null and map_actions_prompt_panel.visible:
		_center_map_actions_prompt()
	if adventure_sacrifice_prompt_panel != null and adventure_sacrifice_prompt_panel.visible:
		_center_adventure_sacrifice_prompt()
	if chain_choice_panel != null and chain_choice_panel.visible:
		_center_chain_choice_prompt()
	if flip_choice_panel != null and flip_choice_panel.visible:
		_center_flip_choice_prompt()
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
			if node.has_meta("in_treasure_market") and node.get_meta("in_treasure_market", false):
				return _get_top_market_card()
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

func _reset_card_pivot_center(card: Node3D) -> void:
	if card == null:
		return
	var pivot := card.get_node_or_null("Pivot")
	if pivot == null or not (pivot is Node3D):
		return
	var pivot_node := pivot as Node3D
	var shift_x: float = pivot_node.position.x
	if absf(shift_x) <= 0.001:
		return
	pivot_node.position.x = 0.0
	for child in pivot_node.get_children():
		if child is Node3D:
			var node := child as Node3D
			node.position.x += shift_x

func _normalize_treasure_card_for_stack(card: Node3D, stack_index: int = -1) -> void:
	if card == null or not is_instance_valid(card):
		return
	_reset_card_pivot_center(card)
	var pivot := card.get_node_or_null("Pivot")
	if pivot != null and (pivot is Node3D):
		(pivot as Node3D).rotation = Vector3.ZERO
	card.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	card.set_meta("in_treasure_reveal_animation", false)
	card.set_meta("flip_force_face_up", false)
	card.set_meta("flip_rotate_on_lifted_axis", false)
	card.set_meta("in_treasure_market", false)
	card.set_meta("in_treasure_stack", true)
	card.set_meta("market_index", -1)
	if stack_index >= 0:
		card.set_meta("stack_index", stack_index)
	if card.has_method("set_face_up"):
		card.call("set_face_up", false)

func _apply_stack_rotation_jitter(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.rotation = Vector3(-PI / 2.0, deg_to_rad(randf_range(-2.0, 2.0)), 0.0)

func _get_top_treasure_card() -> Node3D:
	return BOARD_CORE.get_top_treasure_card(self)

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
	if not in_market:
		return false
	var top_market := _get_top_market_card()
	if top_market == null or top_market != card:
		return false
	if not card.has_meta("card_data"):
		return false
	return PURCHASE_PROMPT.show(self, card, require_gold)

func _get_final_boss_summon_cost() -> int:
	var base_cost := FINAL_BOSS_DEFAULT_COST
	if final_boss_table_card != null and is_instance_valid(final_boss_table_card):
		var data: Dictionary = final_boss_table_card.get_meta("card_data", {})
		if not data.is_empty() and data.has("cost"):
			base_cost = max(0, int(data.get("cost", FINAL_BOSS_DEFAULT_COST)))
	if _has_event_row_effect("boss_finale_cost_minus_5"):
		base_cost = max(0, base_cost - 5)
	return base_cost

func _has_event_row_effect(effect_name: String) -> bool:
	if effect_name.strip_edges() == "":
		return false
	for child in get_children():
		if not (child is Node3D):
			continue
		if not bool(child.get_meta("in_event_row", false)):
			continue
		var data: Dictionary = child.get_meta("card_data", {})
		var effects: Array = data.get("effects", [])
		if effects.has(effect_name):
			return true
	return false

func _try_show_final_boss_prompt(card: Node3D) -> bool:
	if phase_index != 0:
		return false
	if card == null:
		return false
	if final_boss_table_card == null or not is_instance_valid(final_boss_table_card):
		return false
	if card != final_boss_table_card:
		return false
	if regno_final_boss_spawned:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Boss finale gia evocato."))
		return true
	if _get_blocking_adventure_card() != null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("C'e gia un nemico in campo."))
		return true
	var cost := _get_final_boss_summon_cost()
	if player_gold < cost:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Non hai abbastanza monete per evocare il boss finale (%d)." % cost))
		return true
	pending_final_boss_cost = cost
	if final_boss_prompt_label != null:
		final_boss_prompt_label.text = _ui_text("Evocare il Boss Finale pagando %d monete?" % cost)
	if final_boss_prompt_panel != null:
		final_boss_prompt_panel.visible = true
		_center_final_boss_prompt()
	return true

func _hide_final_boss_prompt() -> void:
	pending_final_boss_cost = 0
	if final_boss_prompt_panel != null:
		final_boss_prompt_panel.visible = false

func _confirm_final_boss_prompt() -> void:
	var cost: int = max(0, int(pending_final_boss_cost))
	if regno_final_boss_spawned:
		_hide_final_boss_prompt()
		return
	if _get_blocking_adventure_card() != null:
		_hide_final_boss_prompt()
		return
	if player_gold < cost:
		_hide_final_boss_prompt()
		return
	player_gold = max(0, player_gold - cost)
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)
	_reveal_final_boss_from_regno()
	_hide_final_boss_prompt()

func _hide_purchase_prompt() -> void:
	PURCHASE_PROMPT.hide(self)

func _update_purchase_prompt_position() -> void:
	PURCHASE_PROMPT.update_position(self)

func _resize_purchase_prompt() -> void:
	PURCHASE_PROMPT.resize(self)

func _confirm_purchase() -> void:
	PURCHASE_PROMPT.confirm(self)

func _on_phase_changed(new_phase_index: int, _turn_index: int) -> void:
	if dice_hold_active or roll_in_progress:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Attendi la fine del lancio dadi prima di cambiare fase."))
		if hand_ui != null and hand_ui.has_method("set_phase_silent"):
			hand_ui.call("set_phase_silent", phase_index, _turn_index)
		return
	if _is_mandatory_action_locked():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Completa prima l'azione obbligatoria in corso."))
		if hand_ui != null and hand_ui.has_method("set_phase_silent"):
			hand_ui.call("set_phase_silent", phase_index, _turn_index)
		return
	if new_phase_index == 0 and _block_turn_pass_if_hand_exceeds_limit(_turn_index):
		return
	phase_index = new_phase_index
	if phase_index == 0:
		retreated_this_turn = false
		_ensure_treasure_stack_from_market_if_empty()
	if phase_index == 1:
		_ensure_portale_infernale_on_top_for_gold_key()
	if phase_index != 0:
		_hide_purchase_prompt()
		_hide_final_boss_prompt()
		_hide_map_actions_prompt()
	if phase_index != 1:
		_hide_adventure_prompt()
		_hide_adventure_sacrifice_prompt()
	if phase_index == 2:
		_restore_flipped_equipment()
		await _cleanup_battlefield_rewards_for_recovery()
		_on_end_turn_with_battlefield()
		_apply_end_turn_equipped_rewards()
		if not retreated_this_turn:
			_try_advance_regno_track()
		_reset_dice_for_rest()
	_update_phase_music()
	_update_phase_lighting()
	_update_phase_info()

func _ensure_portale_infernale_on_top_for_gold_key() -> void:
	if not _has_equipped_card_id("treasure_chiave_oro"):
		return
	if _is_portale_infernale_on_table():
		return
	_move_portale_infernale_to_top_of_adventure_stack()

func _is_portale_infernale_on_table() -> bool:
	var portal: Node3D = _find_portale_infernale_in_play()
	if portal == null or not is_instance_valid(portal):
		return false
	return bool(portal.get_meta("in_battlefield", false)) or bool(portal.get_meta("in_event_row", false)) or bool(portal.get_meta("in_mission_side", false))

func _has_equipped_card_id(card_id: String) -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not bool(slot.get_meta("occupied", false)):
			continue
		var equipped: Node3D = slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {}) as Dictionary
		if str(data.get("id", "")) == card_id:
			return true
	return false

func _is_portale_infernale_in_play() -> bool:
	return _find_portale_infernale_in_play() != null

func _find_portale_infernale_in_play() -> Node3D:
	var found_event_or_mission: Node3D = null
	var found_stack: Node3D = null
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("card_data"):
			continue
		var data: Dictionary = child.get_meta("card_data", {}) as Dictionary
		if str(data.get("id", "")) != "event_portale_infernale":
			continue
		if bool(child.get_meta("in_battlefield", false)):
			return child as Node3D
		if found_event_or_mission == null and (bool(child.get_meta("in_event_row", false)) or bool(child.get_meta("in_mission_side", false))):
			found_event_or_mission = child as Node3D
		if found_stack == null and bool(child.get_meta("in_adventure_stack", false)):
			found_stack = child as Node3D
	if found_event_or_mission != null:
		return found_event_or_mission
	return found_stack

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
	_begin_mandatory_draw_lock()
	await REWARD_RESOLUTION_CORE.cleanup_battlefield_rewards_for_recovery(self)
	_end_mandatory_draw_lock()

func _resolve_reward_tokens_for_recovery() -> void:
	_begin_mandatory_draw_lock()
	await REWARD_RESOLUTION_CORE.resolve_reward_tokens_for_recovery(self)
	_end_mandatory_draw_lock()

func _draw_treasure_until_group(group_key: String) -> void:
	_begin_mandatory_draw_lock()
	await REWARD_RESOLUTION_CORE.draw_treasure_until_group(self, group_key)
	_end_mandatory_draw_lock()

func _consume_token_and_draw_treasure(token: RigidBody3D, group_key: String) -> void:
	_begin_mandatory_draw_lock()
	await REWARD_RESOLUTION_CORE.consume_token_and_draw_treasure(self, token, group_key)
	_end_mandatory_draw_lock()

func _flip_treasure_card_for_recovery(card: Node3D) -> void:
	await REWARD_RESOLUTION_CORE.flip_treasure_card_for_recovery(self, card)

func _lift_treasure_card_to_stack_top(card: Node3D) -> void:
	REWARD_RESOLUTION_CORE.lift_treasure_card_to_stack_top(self, card)

func _collect_tombstone_token(token: RigidBody3D, target: Vector3) -> void:
	REWARD_RESOLUTION_CORE.collect_tombstone_token(self, token, target)

func _get_player_collect_target() -> Vector3:
	return REWARD_RESOLUTION_CORE.get_player_collect_target(self)

func _reveal_boss_from_regno() -> void:
	BOSS_FLOW_CORE.reveal_boss_from_regno(self)

func _claim_boss_to_hand_from_regno() -> void:
	_begin_mandatory_draw_lock()
	await BOSS_FLOW_CORE.claim_boss_to_hand_from_regno(self)
	_end_mandatory_draw_lock()

func _claim_boss_to_hand_from_stack() -> void:
	_begin_mandatory_draw_lock()
	await BOSS_FLOW_CORE.claim_boss_to_hand_from_stack(self)
	_end_mandatory_draw_lock()

func _reveal_final_boss_from_regno() -> void:
	BOSS_FLOW_CORE.reveal_final_boss_from_regno(self)

func _update_phase_info() -> void:
	if hand_ui == null or not hand_ui.has_method("set_info"):
		return
	var text := ""
	if phase_index == 0:
		text = "Organizzazione:\n- compra tesori (clic sul mercato)\n- equip/unequip dalla mano\n- gira carta tesoro\n- riscatta missione (clic)\n- tasto destro: info carta"
	elif phase_index == 1:
		text = "Avventura:\n- gira carta avventura (clic sul mazzo)\n- lancia dadi (tieni sx, rilascia)\n- usa equip e magie (sx)\n- applica risultato (pulsante fight)\n- tasto destro: info carta"
	else:
		text = "Recupero:\n- ripristino dadi\n- fine turno"
	hand_ui.call("set_info", _ui_text(text))

func _update_phase_lighting() -> void:
	PHASE_VISUALS_CORE.update_phase_lighting(self, phase_index, LIGHT_COLOR_ORG, LIGHT_COLOR_ADV, LIGHT_COLOR_REC)

func _get_adventure_stack_card_at(mouse_pos: Vector2) -> Node3D:
	return ADVENTURE_FLOW_CORE.get_adventure_stack_card_at(self, mouse_pos)

func _on_end_turn_with_battlefield() -> void:
	ADVENTURE_FLOW_CORE.on_end_turn_with_battlefield(self)

func _try_advance_regno_track() -> void:
	deck_rules.try_advance_regno_track(self)

func _try_spend_tombstone_on_regno(card: Node3D) -> bool:
	return deck_rules.try_spend_tombstone_on_regno(self, card)

func _try_show_map_actions_prompt(card: Node3D) -> bool:
	if str(GameConfig.selected_deck_id).strip_edges().to_lower() != "golden_axe":
		return false
	if deck_rules == null or not deck_rules.has_method("try_open_map_actions"):
		return false
	return deck_rules.try_open_map_actions(self, card)

func _is_portale_infernale_card(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	var data: Dictionary = card.get_meta("card_data", {})
	return str(data.get("id", "")) == "event_portale_infernale"

func _try_activate_portale_infernale(card: Node3D) -> bool:
	if phase_index != 1:
		return false
	if card == null or not is_instance_valid(card):
		return false
	if not bool(card.get_meta("in_event_row", false)):
		return false
	if not _is_portale_infernale_card(card):
		return false
	if _get_blocking_adventure_card() != null:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("C'e gia un nemico in campo."))
		return true
	card.set_meta("portal_home_position", card.global_position)
	card.set_meta("portal_home_rotation", card.rotation)
	card.set_meta("in_event_row", false)
	card.set_meta("in_battlefield", true)
	card.set_meta("adventure_blocking", true)
	card.set_meta("battlefield_hearts", 1)
	card.call("flip_to_side", _get_battlefield_target_pos())
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Portale Infernale attivo: continua a lanciare finche fai 5 o meno."))
	_update_adventure_value_box()
	return true

func _try_activate_adventure_sacrifice(card: Node3D) -> bool:
	if phase_index != 1:
		return false
	if card == null or not is_instance_valid(card):
		return false
	if not bool(card.get_meta("in_battlefield", false)):
		return false
	if pending_adventure_sacrifice_waiting_cost:
		return true
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		return false
	var ctype := str(card_data.get("type", "")).strip_edges().to_lower()
	if ctype != "scontro" and ctype != "maledizione":
		return false
	if bool(card.get_meta("sacrifice_used", false)):
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Approccio alternativo gia usato per questa carta."))
		return true
	if roll_in_progress:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Attendi la fine del lancio dadi."))
		return true
	if not roll_pending_apply or last_roll_values.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Approccio alternativo disponibile dopo il lancio dadi."))
		return true
	var sacrifice_effect := str(card_data.get("sacrifice_effect", "")).strip_edges()
	if sacrifice_effect.is_empty():
		return false
	_show_adventure_sacrifice_prompt(card)
	return true

func _execute_adventure_sacrifice(card: Node3D) -> bool:
	if phase_index != 1:
		return false
	if card == null or not is_instance_valid(card):
		return false
	if not bool(card.get_meta("in_battlefield", false)):
		return false
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		return false
	var ctype := str(card_data.get("type", "")).strip_edges().to_lower()
	if ctype != "scontro" and ctype != "maledizione":
		return false
	if bool(card.get_meta("sacrifice_used", false)):
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Approccio alternativo gia usato per questa carta."))
		return true
	if roll_in_progress:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Attendi la fine del lancio dadi."))
		return true
	if not roll_pending_apply or last_roll_values.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Approccio alternativo disponibile dopo il lancio dadi."))
		return true
	var sacrifice_effect := str(card_data.get("sacrifice_effect", "")).strip_edges()
	if sacrifice_effect.is_empty():
		return false
	var sacrifice_cost := str(card_data.get("sacrifice_cost", "")).strip_edges()
	var cost_result := _pay_adventure_sacrifice_cost(sacrifice_cost, card, sacrifice_effect)
	if cost_result == 0:
		return true
	if cost_result == 2:
		return true
	_apply_adventure_sacrifice_effect(card, sacrifice_effect)
	return true

func _show_adventure_sacrifice_prompt(card: Node3D) -> void:
	pending_adventure_sacrifice_prompt_card = card
	if adventure_sacrifice_prompt_panel == null or adventure_sacrifice_prompt_label == null:
		return
	adventure_sacrifice_prompt_label.text = _ui_text("Usare l'effetto della carta Avventura?")
	adventure_sacrifice_prompt_panel.visible = true
	_center_adventure_sacrifice_prompt()

func _hide_adventure_sacrifice_prompt() -> void:
	pending_adventure_sacrifice_prompt_card = null
	if adventure_sacrifice_prompt_panel != null:
		adventure_sacrifice_prompt_panel.visible = false

func _confirm_adventure_sacrifice_prompt() -> void:
	var card := pending_adventure_sacrifice_prompt_card
	_hide_adventure_sacrifice_prompt()
	if card == null or not is_instance_valid(card):
		return
	_execute_adventure_sacrifice(card)

func _pay_adventure_sacrifice_cost(cost_code: String, card: Node3D, sacrifice_effect: String) -> int:
	var code := cost_code.strip_edges().to_lower()
	var cost_context := {
		"main": self,
		"cost_code": code,
		"card": card,
		"sacrifice_effect": sacrifice_effect
	}
	AbilityRegistry.apply("sacrifice_cost_router", cost_context)
	if bool(cost_context.get("handled", false)):
		return int(cost_context.get("cost_result", 1))
	return 1

func _apply_adventure_sacrifice_effect(card: Node3D, sacrifice_effect: String) -> void:
	if card == null or not is_instance_valid(card):
		return
	var effect := sacrifice_effect.strip_edges().to_lower()
	if effect == "":
		return
	var effect_context := {
		"main": self,
		"card": card,
		"effect_code": effect
	}
	AbilityRegistry.apply("sacrifice_effect_router", effect_context)
	if bool(effect_context.get("handled", false)):
		return
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Effetto approccio alternativo non riconosciuto: %s" % effect))

func _try_resolve_pending_adventure_sacrifice_after_cost() -> void:
	if not pending_adventure_sacrifice_waiting_cost:
		return
	if pending_penalty_discards > 0:
		return
	if pending_flip_equip_choice_active:
		return
	var card := pending_adventure_sacrifice_card
	var effect := pending_adventure_sacrifice_effect
	pending_adventure_sacrifice_waiting_cost = false
	pending_adventure_sacrifice_card = null
	pending_adventure_sacrifice_effect = ""
	if card == null or not is_instance_valid(card):
		return
	_apply_adventure_sacrifice_effect(card, effect)

func _consume_pending_adventure_sacrifice_die_removal() -> void:
	if pending_adventure_sacrifice_remove_choice_count <= 0 and pending_adventure_sacrifice_remove_after_roll_count <= 0:
		return
	pending_adventure_sacrifice_remove_choice_count = 0
	pending_adventure_sacrifice_remove_after_roll_count = 0
	pending_adventure_sacrifice_sequence_active = false
	if dice_drop_mode == "sacrifice_remove":
		_hide_drop_half_prompt()
		dice_drop_mode = "drop_half"
	dice_count = DICE_FLOW.get_total_dice(self)
	if not roll_pending_apply and not roll_in_progress:
		DICE_FLOW.clear_dice_preview(self)
		DICE_FLOW.spawn_dice_preview(self)

func _place_sacrifice_die_on_card(die: RigidBody3D) -> void:
	if die == null or not is_instance_valid(die):
		return
	var card: Node3D = pending_adventure_sacrifice_slot_card
	if card == null or not is_instance_valid(card):
		die.queue_free()
		return
	var previous: Node3D = card.get_meta("sacrifice_slot_die", null) as Node3D
	if previous != null and is_instance_valid(previous):
		previous.queue_free()
	var start_pos: Vector3 = die.global_position
	var start_rot: Vector3 = die.rotation
	var start_scale: Vector3 = die.scale
	var target_rot := Vector3(-PI / 2.0, deg_to_rad(randf_range(-10.0, 10.0)), 0.0)
	var target_global: Vector3 = card.to_global(ADVENTURE_SACRIFICE_SLOT_LOCAL)
	if die.get_parent() != null:
		die.get_parent().remove_child(die)
	add_child(die)
	die.top_level = true
	die.freeze = true
	die.sleeping = true
	die.linear_velocity = Vector3.ZERO
	die.angular_velocity = Vector3.ZERO
	for child in die.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = true
	die.global_position = start_pos
	die.rotation = start_rot
	die.scale = start_scale
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(die, "global_position", target_global, 0.24)
	tween.parallel().tween_property(die, "rotation", target_rot, 0.24)
	tween.finished.connect(Callable(self, "_finalize_sacrifice_die_on_card").bind(die, card, target_rot, start_scale))
	die.set_meta("adventure_sacrifice_slot_die", true)
	card.set_meta("sacrifice_slot_die", die)

func _finalize_sacrifice_die_on_card(die: RigidBody3D, card: Node3D, target_rot: Vector3, keep_scale: Vector3) -> void:
	if die == null or not is_instance_valid(die):
		return
	if card == null or not is_instance_valid(card):
		die.queue_free()
		return
	if die.get_parent() != null:
		die.get_parent().remove_child(die)
	card.add_child(die)
	die.top_level = false
	die.position = ADVENTURE_SACRIFICE_SLOT_LOCAL
	die.rotation = target_rot
	die.scale = keep_scale
	die.set_meta("adventure_sacrifice_slot_die", true)
	card.set_meta("sacrifice_slot_die", die)

func _return_portale_infernale_to_event_row(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_battlefield", false)
	card.set_meta("adventure_blocking", false)
	card.set_meta("in_event_row", true)
	var home_pos: Vector3 = card.get_meta("portal_home_position", event_row_pos)
	var home_rot: Vector3 = card.get_meta("portal_home_rotation", Vector3(-PI / 2.0, 0.0, 0.0))
	card.global_position = home_pos
	card.rotation = home_rot
	if card.has_method("set_face_up"):
		card.call("set_face_up", true)
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Portale Infernale non superato: torna in gioco."))
	_update_adventure_value_box()

func _resolve_portale_infernale_success(card: Node3D, total: int, difficulty: int) -> void:
	if card == null or not is_instance_valid(card):
		return
	var defeated_pos: Vector3 = card.global_position
	var card_data: Dictionary = card.get_meta("card_data", {})
	_report_battlefield_reward(card_data, total, difficulty)
	_move_adventure_to_discard(card)
	_spawn_defeat_explosion(defeated_pos, card)
	_reveal_final_boss_from_regno()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Portale Infernale sconfitto: Boss finale evocato!"))

func _return_final_boss_to_area(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_battlefield", false)
	card.set_meta("adventure_blocking", false)
	card.set_meta("battlefield_hearts", 0)
	card.queue_free()
	regno_final_boss_spawned = false
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Ritirata: il Boss finale torna nella sua area."))

func _find_equipped_card_by_id(card_id: String) -> Node3D:
	if card_id.strip_edges() == "":
		return null
	for slot in equipment_slots:
		if slot == null:
			continue
		if not bool(slot.get_meta("occupied", false)):
			continue
		var equipped: Node3D = slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		if str(data.get("id", "")) == card_id:
			return equipped
	return null

func _destroy_equipped_card(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if not card.has_meta("equipped_slot"):
		return false
	var slot := card.get_meta("equipped_slot") as Area3D
	if slot != null:
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
	card.queue_free()
	_apply_equipment_slot_limit_after_curse()
	_refresh_hand_ui()
	return true

func _consume_gold_key_for_sacrifice() -> bool:
	var source := pending_action_source_card
	if source != null and is_instance_valid(source):
		var source_data: Dictionary = source.get_meta("card_data", {})
		if str(source_data.get("id", "")) == "treasure_chiave_oro":
			return _destroy_equipped_card(source)
	var key_card := _find_equipped_card_by_id("treasure_chiave_oro")
	if key_card != null and is_instance_valid(key_card):
		return _destroy_equipped_card(key_card)
	return false

func _apply_sacrifice_open_portal() -> void:
	var portal := _find_portale_infernale_in_play()
	if portal == null or not is_instance_valid(portal) or not _is_portale_infernale_card(portal):
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessun Portale Infernale disponibile."))
		return
	if not _consume_gold_key_for_sacrifice():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessuna Chiave d'oro equipaggiata da sacrificare."))
		return
	_move_adventure_to_discard(portal)
	_reveal_final_boss_from_regno()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Sacrificata Chiave d'oro: Portale negli scarti, Boss finale evocato."))

func _reset_dice_for_rest() -> void:
	DICE_FLOW.clear_dice(self)
	roll_pending_apply = false
	character_ability_used_this_roll = false
	pending_adventure_sacrifice_sequence_active = false
	pending_adventure_sacrifice_remove_after_roll_count = 0
	pending_adventure_sacrifice_remove_choice_count = 0
	pending_adventure_sacrifice_waiting_cost = false
	pending_adventure_sacrifice_card = null
	pending_adventure_sacrifice_effect = ""
	pending_adventure_sacrifice_slot_card = null
	dice_drop_mode = "drop_half"
	_hide_drop_half_prompt()
	blue_dice = base_dice_count + green_dice + red_dice
	if tyris_backpack_occupied and active_character_id == "character_sir_arthur_a":
		blue_dice = max(0, blue_dice - 1)
	green_dice = 0
	red_dice = 0
	dice_count = DICE_FLOW.get_total_dice(self)
	DICE_FLOW.clear_dice_preview(self)
	DICE_FLOW.spawn_dice_preview(self)
	_refresh_character_backpack_marker()

func _try_show_adventure_prompt(card: Node3D) -> void:
	ADVENTURE_FLOW_CORE.try_show_adventure_prompt(self, card)

func _hide_adventure_prompt() -> void:
	ADVENTURE_FLOW_CORE.hide_adventure_prompt(self)

func _decline_adventure_prompt() -> void:
	ADVENTURE_FLOW_CORE.decline_adventure_prompt(self)

func _show_action_prompt(card_data: Dictionary, is_magic: bool, source_card: Node3D = null) -> void:
	if Time.get_ticks_msec() < action_prompt_block_until_ms:
		return
	ACTION_PROMPT.show(self, card_data, is_magic, source_card)

func _hide_action_prompt() -> void:
	action_prompt_block_until_ms = Time.get_ticks_msec() + 400
	pending_character_backpack_prompt_mode = ""
	ACTION_PROMPT.hide(self)

func _center_action_prompt() -> void:
	ACTION_PROMPT.center(self)

func _confirm_action_prompt() -> void:
	action_prompt_block_until_ms = Time.get_ticks_msec() + 400
	if not pending_character_backpack_prompt_mode.is_empty():
		_confirm_character_backpack_prompt()
		_hide_action_prompt()
		return
	ACTION_PROMPT.confirm(self)

func _use_card_effects(card_data: Dictionary, effects: Array = [], action_window: String = "") -> void:
	if effects.is_empty():
		effects = card_data.get("effects", [])
	if effects.is_empty():
		return
	_hide_outcome()
	var local_effects := EFFECTS_REGISTRY.canonicalize_effect_list(effects)
	if local_effects.has("return_to_hand") and not pending_action_is_magic and pending_action_source_card != null and is_instance_valid(pending_action_source_card):
		_force_return_equipped_to_hand(pending_action_source_card)
		local_effects.erase("return_to_hand")
	var selected_values := DICE_FLOW.get_selected_roll_values(self)
	if selected_values.is_empty():
		selected_values = last_roll_values.duplicate()
	var reroll_indices: Array[int] = []
	for effect in local_effects:
		var effect_name := EFFECTS_REGISTRY.canonical_effect_code(str(effect))
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
			deck_rules.set_next_roll_lowest(self)
			continue
		if effect_name == "next_roll_double_then_remove_half" and action_window == "before_roll" and not roll_pending_apply:
			deck_rules.set_next_roll_clone(self)
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
		_sync_roll_totals_and_ui()
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
	_add_hand_card_to_treasure_market(removed_card)
	_refresh_hand_ui()
	return true

func _discard_revealed_adventure_card() -> void:
	var discard_context := {
		"main": self
	}
	AbilityRegistry.apply("discard_revealed_adventure", discard_context)
	if bool(discard_context.get("handled", false)):
		return
	var battlefield := _get_battlefield_card()
	if battlefield != null:
		var data: Dictionary = battlefield.get_meta("card_data", {})
		var ctype := str(data.get("type", "")).strip_edges().to_lower()
		_move_adventure_to_discard(battlefield)
		if ctype != "concatenamento":
			_cleanup_chain_cards_after_victory()
		return
	var top := _get_top_adventure_card()
	if top == null:
		return
	top.set_meta("in_adventure_stack", false)
	_move_adventure_to_discard(top)

func _recalculate_last_roll_total() -> void:
	DICE_FLOW.recalculate_last_roll_total(self)

func _sync_roll_totals_and_ui() -> void:
	if roll_in_progress:
		return
	DICE_FLOW.recalculate_last_roll_total(self)
	DICE_FLOW.refresh_roll_dice_buttons(self)
	_update_adventure_value_box()

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
	_sync_roll_totals_and_ui()

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

func _try_activate_character_card_ability(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if card != character_card:
		return false
	if active_character_id != "character_sir_arthur_b":
		return false
	if roll_in_progress:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Attendi la fine del lancio dadi."))
		return true
	if not roll_pending_apply:
		return false
	if character_ability_used_this_roll:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Abilita personaggio gia usata in questo lancio."))
		return true
	if player_hand.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessuna carta da scartare per attivare l'abilita."))
		return true
	if selected_roll_dice.is_empty() or selected_roll_dice.size() != 1:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Seleziona 1 dado blu da portare a 0."))
		return true
	var idx: int = int(selected_roll_dice[0])
	if idx < 0 or idx >= last_roll_values.size() or idx >= active_dice.size():
		return true
	var die: RigidBody3D = active_dice[idx]
	if die == null or not is_instance_valid(die) or not die.has_method("get_dice_type"):
		return true
	var dtype := str(die.call("get_dice_type"))
	if dtype != "blue":
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Puoi selezionare solo un dado blu."))
		return true
	if not _discard_one_hand_card_for_effect({}):
		return true
	last_roll_values[idx] = 0
	character_ability_used_this_roll = true
	_sync_roll_totals_and_ui()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Abilita usata: dado blu impostato a 0."))
	return true

func _try_activate_character_backpack_ability(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if card != character_card:
		return false
	if active_character_id != "character_sir_arthur_a":
		return false
	if phase_index != 0:
		return false
	if roll_in_progress or roll_pending_apply:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Abilita zaino disponibile solo in organizzazione, fuori dal lancio."))
		return true
	if tyris_backpack_occupied:
		if player_current_hearts <= 0:
			if hand_ui != null and hand_ui.has_method("set_info"):
				hand_ui.call("set_info", _ui_text("Nessun cuore disponibile per distruggere il dado nello zaino."))
			return true
		_show_character_backpack_prompt("destroy")
		return true
	if blue_dice <= 0:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Nessun dado blu disponibile da mettere nello zaino."))
		return true
	_show_character_backpack_prompt("store")
	return true

func _show_character_backpack_prompt(mode: String) -> void:
	if action_prompt_panel == null or action_prompt_label == null:
		return
	pending_character_backpack_prompt_mode = mode
	if mode == "destroy":
		action_prompt_label.text = _ui_text("Tyrius: pagare 1 cuore per distruggere il dado nello zaino?")
	else:
		action_prompt_label.text = _ui_text("Tyrius: mettere 1 dado blu nello zaino?")
	action_prompt_panel.visible = true
	_center_action_prompt()

func _confirm_character_backpack_prompt() -> void:
	var mode := pending_character_backpack_prompt_mode
	pending_character_backpack_prompt_mode = ""
	if mode.is_empty():
		return
	if mode == "store":
		if active_character_id != "character_sir_arthur_a" or phase_index != 0:
			return
		if tyris_backpack_occupied:
			return
		if blue_dice <= 0:
			if hand_ui != null and hand_ui.has_method("set_info"):
				hand_ui.call("set_info", _ui_text("Nessun dado blu disponibile da mettere nello zaino."))
			return
		blue_dice = max(0, blue_dice - 1)
		dice_count = DICE_FLOW.get_total_dice(self)
		tyris_backpack_occupied = true
		DICE_FLOW.clear_dice_preview(self)
		DICE_FLOW.spawn_dice_preview(self)
		_refresh_character_backpack_marker()
		_update_hand_ui_stats()
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Tyrius: 1 dado blu messo nello zaino."))
		return
	if mode == "destroy":
		if active_character_id != "character_sir_arthur_a" or phase_index != 0:
			return
		if not tyris_backpack_occupied:
			return
		if player_current_hearts <= 0:
			if hand_ui != null and hand_ui.has_method("set_info"):
				hand_ui.call("set_info", _ui_text("Nessun cuore disponibile per distruggere il dado nello zaino."))
			return
		_apply_player_heart_loss(1)
		tyris_backpack_occupied = false
		_refresh_character_backpack_marker()
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Tyrius: dado nello zaino distrutto (-1 cuore)."))
		return

func _refresh_character_backpack_marker() -> void:
	if character_card == null or not is_instance_valid(character_card):
		return
	for child in character_card.get_children():
		if child is Node3D and child.has_meta("character_backpack_die"):
			child.queue_free()
	if not tyris_backpack_occupied or active_character_id != "character_sir_arthur_a":
		return
	var die := DICE_SCENE.instantiate() as RigidBody3D
	if die == null:
		return
	die.set_meta("character_backpack_die", true)
	die.freeze = true
	die.sleeping = true
	die.gravity_scale = 0.0
	die.collision_layer = 0
	die.collision_mask = 0
	die.position = Vector3(0.98, -0.72, 0.58)
	die.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	if die.has_method("set_dice_type"):
		die.call("set_dice_type", "blue")
	character_card.add_child(die)

func _confirm_adventure_prompt() -> void:
	if pending_adventure_card == null or not is_instance_valid(pending_adventure_card):
		pending_chain_reveal_lock = false
		pending_chain_choice_active = false
		_hide_chain_choice_prompt()
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
	# Chain lock must be released as soon as we reveal a non-chain card.
	# Otherwise dice rolling can remain blocked after chain reveals.
	if card_type != "concatenamento":
		pending_chain_reveal_lock = false
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
		if not effects.has("reveal_2_keep_1"):
			_schedule_next_chain_reveal()
		_hide_adventure_prompt()
		return
	elif card_type == "evento":
		pending_chain_reveal_lock = false
		_reveal_event_card(pending_adventure_card, card_data)
		_cleanup_chain_cards_after_victory()
		_hide_adventure_prompt()
		return
	elif card_type == "missione":
		pending_chain_reveal_lock = false
		_reveal_mission_card(pending_adventure_card, card_data)
		_cleanup_chain_cards_after_victory()
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
	return deck_rules.get_next_chain_pos(self, base_pos)

func _schedule_next_chain_reveal() -> void:
	await deck_rules.schedule_next_chain_reveal(self)

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

func _reserve_next_market_index() -> int:
	var idx := market_order_counter
	market_order_counter += 1
	return idx

func _ensure_treasure_stack_from_market_if_empty() -> bool:
	if _get_top_treasure_card() != null:
		return false
	var recycled: Array[Node3D] = []
	var waiting_reveal_animation: bool = false
	for child in get_children():
		if not (child is Node3D):
			continue
		var card := child as Node3D
		var is_in_stack: bool = bool(card.get_meta("in_treasure_stack", false))
		var is_in_market: bool = bool(card.get_meta("in_treasure_market", false))
		if not is_in_stack and not is_in_market:
			continue
		if bool(card.get_meta("in_treasure_reveal_animation", false)) or _is_card_flip_animating(card):
			waiting_reveal_animation = true
			continue
		recycled.append(card)
	# Never rebuild/shuffle while any treasure card is still flipping/revealing.
	# Otherwise the last flipped card can stay outside the rebuilt deck at lifted Y.
	if waiting_reveal_animation:
		return false
	if recycled.is_empty():
		return _rebuild_treasure_stack_from_database()
	DECK_UTILS.shuffle_deck(recycled)
	for i in recycled.size():
		var card := recycled[i]
		_normalize_treasure_card_for_stack(card, i)
		card.global_position = treasure_deck_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)
		_apply_stack_rotation_jitter(card)
		if card.has_method("set_sorting_offset"):
			card.call("set_sorting_offset", float(i))
	revealed_treasure_count = 0
	return true

func _has_active_treasure_reveal_animation() -> bool:
	for child in get_children():
		if not (child is Node3D):
			continue
		if bool(child.get_meta("in_treasure_reveal_animation", false)) or _is_card_flip_animating(child as Node3D):
			return true
	return false

func _finalize_treasure_reveal_animation(card: Node3D, delay_sec: float = 1.45) -> void:
	if card == null or not is_instance_valid(card):
		return
	await get_tree().create_timer(maxf(0.1, delay_sec)).timeout
	while card != null and is_instance_valid(card) and _is_card_flip_animating(card):
		await get_tree().process_frame
	if card != null and is_instance_valid(card):
		card.set_meta("in_treasure_reveal_animation", false)
	_ensure_treasure_stack_from_market_if_empty()

func _is_card_flip_animating(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	var value: Variant = card.get("is_animating")
	if value is bool:
		return bool(value)
	return false

func _rebuild_treasure_stack_from_database() -> bool:
	if _get_top_treasure_card() != null:
		return false
	var owned_counts: Dictionary = {}
	for hand_card_any in player_hand:
		if not (hand_card_any is Dictionary):
			continue
		var hand_card: Dictionary = hand_card_any as Dictionary
		if not _is_treasure_card_data(hand_card):
			continue
		var hid: String = str(hand_card.get("id", "")).strip_edges()
		if hid.is_empty():
			continue
		owned_counts[hid] = int(owned_counts.get(hid, 0)) + 1
	for slot in equipment_slots:
		if slot == null:
			continue
		if not bool(slot.get_meta("occupied", false)):
			continue
		var equipped: Node3D = slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		var eq_data: Dictionary = equipped.get_meta("card_data", {}) as Dictionary
		if not _is_treasure_card_data(eq_data):
			continue
		var eid: String = str(eq_data.get("id", "")).strip_edges()
		if eid.is_empty():
			continue
		owned_counts[eid] = int(owned_counts.get(eid, 0)) + 1
	var rebuild_cards: Array[Dictionary] = []
	var set_id: String = DeckRegistry.get_card_set(GameConfig.selected_deck_id)
	for entry_any in CardDatabase.deck_treasures:
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = entry_any as Dictionary
		if str(entry.get("set", "")) != set_id:
			continue
		var id: String = str(entry.get("id", "")).strip_edges()
		if not id.is_empty():
			var pending_owned: int = int(owned_counts.get(id, 0))
			if pending_owned > 0:
				owned_counts[id] = pending_owned - 1
				continue
		rebuild_cards.append(entry)
	if rebuild_cards.is_empty():
		return false
	DECK_UTILS.shuffle_deck(rebuild_cards)
	for i in rebuild_cards.size():
		var data: Dictionary = rebuild_cards[i]
		var card: Node3D = CARD_SCENE.instantiate()
		card.color = Color(0.2, 0.2, 0.4, 1.0)
		add_child(card)
		card.global_position = treasure_deck_pos + Vector3(0.0, i * REVEALED_Y_STEP, 0.0)
		_apply_stack_rotation_jitter(card)
		card.set_meta("in_treasure_stack", true)
		card.set_meta("card_data", data)
		card.set_meta("in_treasure_market", false)
		card.set_meta("stack_index", i)
		var image_path: String = str(data.get("image", ""))
		if not image_path.is_empty() and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", TREASURE_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)
	revealed_treasure_count = 0
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
	return deck_rules.get_next_mission_side_pos(self)

func _get_next_event_pos() -> Vector3:
	return deck_rules.get_next_event_pos(self)

func _reveal_event_card(card: Node3D, card_data: Dictionary) -> void:
	deck_rules.reveal_event_card(self, card, card_data)

func _reveal_mission_card(card: Node3D, card_data: Dictionary) -> void:
	deck_rules.reveal_mission_card(self, card, card_data)

func _try_claim_mission(card: Node3D) -> void:
	deck_rules.try_claim_mission(self, card)

func _is_mission_completed(card_data: Dictionary) -> bool:
	return deck_rules.is_mission_completed(self, card_data)

func _apply_mission_cost(card_data: Dictionary) -> void:
	deck_rules.apply_mission_cost(self, card_data)

func _get_mission_requirements(card_data: Dictionary) -> Dictionary:
	return deck_rules.get_mission_requirements(self, card_data)

func _report_mission_status(card_data: Dictionary, completed: bool) -> void:
	deck_rules.report_mission_status(self, card_data, completed)

func _resize_adventure_prompt() -> void:
	ADVENTURE_PROMPT.resize(self)

func _update_adventure_prompt_position() -> void:
	ADVENTURE_PROMPT.update_position(self)

func _create_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.create(self)

func _show_battlefield_warning() -> void:
	BATTLEFIELD_WARNING.show(self)

func _show_match_end_message(message: String) -> void:
	if match_closed:
		return
	match_closed = true
	_hide_purchase_prompt()
	_hide_final_boss_prompt()
	_hide_adventure_prompt()
	_hide_adventure_sacrifice_prompt()
	_hide_action_prompt()
	_hide_map_actions_prompt()
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text(message))
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", false)
	if battlefield_warning_panel != null and battlefield_warning_label != null:
		battlefield_warning_label.text = _ui_text(message)
		battlefield_warning_panel.visible = true
		_center_battlefield_warning()

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
	deck_rules.create_regno_reward_label(self, ui)
	_create_outcome_banner(ui)
	_create_adventure_value_box(ui)
	_create_music_toggle(ui)
	_create_purchase_prompt()
	_create_action_prompt()
	_create_sell_prompt()
	_create_dice_drop_prompt()

func _spawn_position_marker() -> void:
	return

func _get_reward_drop_center() -> Vector3:
	return COIN_DROP_BASE_POS + coin_manual_offset

func _get_reward_token_drop_center() -> Vector3:
	return COIN_DROP_BASE_POS + TOKEN_DROP_OFFSET + coin_manual_offset

func _get_next_reward_token_center() -> Vector3:
	var idx: int = reward_token_pile_count
	reward_token_pile_count += 1
	var col: int = idx % REWARD_TOKEN_COLUMNS
	var row: int = int(idx / REWARD_TOKEN_COLUMNS)
	return _get_reward_token_drop_center() + Vector3(float(col) * REWARD_TOKEN_SPACING_X, 0.0, float(row) * REWARD_TOKEN_SPACING_Z)

func _nudge_coin_pile(delta: Vector3) -> void:
	coin_manual_offset += delta
	var coins: Array = get_tree().get_nodes_in_group("coins")
	for node in coins:
		if not (node is Node3D):
			continue
		var coin: Node3D = node as Node3D
		coin.global_position += delta
	var tokens: Array = get_tree().get_nodes_in_group("reward_tokens")
	for node in tokens:
		if not (node is Node3D):
			continue
		var token: Node3D = node as Node3D
		token.global_position += delta
	_position_coin_total_label()
	_update_coin_total_label()
	var center: Vector3 = _get_current_coin_center()
	var msg: String = "Monete: X=%.3f Y=%.3f Z=%.3f" % [center.x, center.y, center.z]
	print(msg)
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text(msg))

func _get_current_coin_center() -> Vector3:
	var coins: Array = get_tree().get_nodes_in_group("coins")
	if coins.is_empty():
		return _get_reward_drop_center()
	var sum: Vector3 = Vector3.ZERO
	var count: int = 0
	for node in coins:
		if not (node is Node3D):
			continue
		sum += (node as Node3D).global_position
		count += 1
	if count <= 0:
		return _get_reward_drop_center()
	return sum / float(count)

func _get_hand_collect_target() -> Vector3:
	return REWARD_RESOLUTION_CORE.get_hand_collect_target(self)

func _update_coord_label() -> void:
	return

func _show_card_debug_info(card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var card_data: Dictionary = {}
	if card.has_meta("card_data") and card.get_meta("card_data") is Dictionary:
		card_data = card.get_meta("card_data", {})
	_show_card_info_from_data(card_data)

func _show_card_info_from_data(card_data: Dictionary) -> void:
	if hand_ui == null or not hand_ui.has_method("set_info"):
		return
	var message: String = _build_card_info_text(card_data)
	if message.strip_edges() == "":
		message = "Carta: nessun testo disponibile."
	hand_ui.call("set_info", _ui_text(message))

func _build_card_info_text(card_data: Dictionary) -> String:
	if card_data.is_empty():
		return "Carta: nessun testo disponibile."
	var name: String = str(card_data.get("name", "Carta")).strip_edges()
	if name == "":
		name = "Carta"
	var lines: Array[String] = []
	lines.append(name)
	var card_type_label: String = _describe_card_type(str(card_data.get("type", "")))
	if card_type_label != "":
		lines.append("Tipo: %s" % card_type_label)
	var main_text: String = _get_card_primary_text(card_data)
	if main_text != "":
		# Prefer card-native rules text when available.
		lines.append(main_text)
		return "\n".join(lines)
	var effects: Array = card_data.get("effects", [])
	if not effects.is_empty():
		var effect_labels: Array[String] = []
		for entry in effects:
			var effect_code: String = str(entry).strip_edges()
			if effect_code == "":
				continue
			effect_labels.append(_describe_effect_code(effect_code))
		if not effect_labels.is_empty():
			lines.append("Effetti: %s" % ", ".join(effect_labels))
	var timed_effects: Array = card_data.get("timed_effects", [])
	if not timed_effects.is_empty():
		var timed_lines: Array[String] = []
		for item in timed_effects:
			if not (item is Dictionary):
				continue
			var data: Dictionary = item as Dictionary
			var effect_name: String = str(data.get("effect", "")).strip_edges()
			if effect_name == "":
				continue
			var when_name: String = str(data.get("when", "")).strip_edges().to_lower()
			var when_text: String = str(CARD_TIMING_DESCRIPTIONS.get(when_name, when_name))
			timed_lines.append("%s: %s" % [when_text, _describe_effect_code(effect_name)])
		if not timed_lines.is_empty():
			lines.append("Tempistiche: %s" % "; ".join(timed_lines))
	var sacrifice_effect: String = str(card_data.get("sacrifice_effect", "")).strip_edges()
	if sacrifice_effect != "":
		var sacrifice_cost: String = str(card_data.get("sacrifice_cost", "")).strip_edges()
		if sacrifice_cost != "":
			lines.append("Sacrificio: %s -> %s" % [sacrifice_cost, _describe_effect_code(sacrifice_effect)])
		else:
			lines.append("Sacrificio: %s" % _describe_effect_code(sacrifice_effect))
	var penalty: Array = card_data.get("penalty_violet", [])
	if not penalty.is_empty():
		var penalty_codes: Array[String] = []
		for entry in penalty:
			penalty_codes.append(str(entry))
		lines.append("Penalita: %s" % ", ".join(penalty_codes))
	var rewards: Array = card_data.get("reward_brown", [])
	if not rewards.is_empty():
		var reward_codes: Array[String] = []
		for entry in rewards:
			reward_codes.append(str(entry))
		lines.append("Premio: %s" % ", ".join(reward_codes))
	return "\n".join(lines)

func _get_card_primary_text(card_data: Dictionary) -> String:
	var keys: Array[String] = [
		"text", "card_text", "rules_text", "rule_text", "effect_text",
		"description", "desc", "descrizione", "testo", "ability_text",
		"flavor_text", "flavor"
	]
	for key in keys:
		var value: String = str(card_data.get(key, "")).strip_edges()
		if value != "":
			return value
	return ""

func _describe_card_type(raw_type: String) -> String:
	var t: String = raw_type.strip_edges().to_lower()
	match t:
		"scontro":
			return "Scontro"
		"concatenamento":
			return "Concatenamento"
		"maledizione":
			return "Maledizione"
		"missione":
			return "Missione (icona zaino)"
		"evento":
			return "Evento"
		"equipaggiamento":
			return "Equipaggiamento"
		"istantaneo":
			return "Istantaneo"
		"boss":
			return "Boss"
		"boss_finale":
			return "Boss finale"
		"personaggio":
			return "Personaggio"
		_:
			return raw_type.strip_edges()

func _describe_effect_code(effect_code: String) -> String:
	var code: String = EFFECTS_REGISTRY.canonical_effect_code(effect_code)
	if code == "":
		return ""
	if CARD_EFFECT_DESCRIPTIONS.has(code):
		return str(CARD_EFFECT_DESCRIPTIONS.get(code))
	return code.replace("_", " ")

func _create_music_toggle(ui_layer: CanvasLayer) -> void:
	CORE_UI.create_music_toggle(self, ui_layer)

func _toggle_music() -> void:
	MUSIC_CORE.toggle_music(self, MUSIC_ON_ICON, MUSIC_OFF_ICON)

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

func _create_final_boss_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 11
	add_child(prompt_layer)
	final_boss_prompt_panel = PanelContainer.new()
	final_boss_prompt_panel.visible = false
	final_boss_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	final_boss_prompt_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	final_boss_prompt_panel.add_theme_stylebox_override("panel", panel_style)

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

	final_boss_prompt_label = Label.new()
	final_boss_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	final_boss_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_boss_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	final_boss_prompt_label.custom_minimum_size = Vector2(460, 0)
	final_boss_prompt_label.text = _ui_text("Evocare il Boss Finale?")
	final_boss_prompt_label.add_theme_font_override("font", UI_FONT)
	final_boss_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	final_boss_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(final_boss_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.set("theme_override_constants/separation", 20)
	final_boss_prompt_yes = Button.new()
	final_boss_prompt_yes.text = _ui_text("Si")
	final_boss_prompt_yes.add_theme_font_override("font", UI_FONT)
	final_boss_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	final_boss_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	final_boss_prompt_yes.pressed.connect(_confirm_final_boss_prompt)
	final_boss_prompt_no = Button.new()
	final_boss_prompt_no.text = _ui_text("No")
	final_boss_prompt_no.add_theme_font_override("font", UI_FONT)
	final_boss_prompt_no.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	final_boss_prompt_no.add_theme_constant_override("font_spacing/space", 8)
	final_boss_prompt_no.pressed.connect(_hide_final_boss_prompt)
	button_row.add_child(final_boss_prompt_yes)
	button_row.add_child(final_boss_prompt_no)
	content.add_child(button_row)

	final_boss_prompt_panel.add_child(content)
	prompt_layer.add_child(final_boss_prompt_panel)

func _center_final_boss_prompt() -> void:
	if final_boss_prompt_panel == null:
		return
	final_boss_prompt_panel.custom_minimum_size = Vector2.ZERO
	final_boss_prompt_panel.reset_size()
	final_boss_prompt_panel.custom_minimum_size = final_boss_prompt_panel.get_combined_minimum_size()
	final_boss_prompt_panel.reset_size()
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = final_boss_prompt_panel.size
	final_boss_prompt_panel.position = Vector2((view_size.x - size.x) * 0.5, 170.0)

func _create_map_actions_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 11
	add_child(prompt_layer)
	map_actions_prompt_panel = PanelContainer.new()
	map_actions_prompt_panel.visible = false
	map_actions_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	map_actions_prompt_panel.z_index = 212
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.78)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	map_actions_prompt_panel.add_theme_stylebox_override("panel", panel_style)

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

	map_actions_prompt_label = Label.new()
	map_actions_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	map_actions_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_actions_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	map_actions_prompt_label.custom_minimum_size = Vector2(760, 0)
	map_actions_prompt_label.text = _ui_text("Mappa: scegli un'azione")
	map_actions_prompt_label.add_theme_font_override("font", UI_FONT)
	map_actions_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	map_actions_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(map_actions_prompt_label)

	map_actions_buttons_box = VBoxContainer.new()
	map_actions_buttons_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_actions_buttons_box.set("theme_override_constants/separation", 8)
	content.add_child(map_actions_buttons_box)

	var close_button := Button.new()
	close_button.text = _ui_text("Chiudi")
	close_button.add_theme_font_override("font", UI_FONT)
	close_button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	close_button.add_theme_constant_override("font_spacing/space", 8)
	close_button.pressed.connect(_hide_map_actions_prompt)
	content.add_child(close_button)

	map_actions_prompt_panel.add_child(content)
	prompt_layer.add_child(map_actions_prompt_panel)

func _show_map_actions_prompt() -> void:
	if map_actions_prompt_panel == null or map_actions_buttons_box == null:
		return
	for child in map_actions_buttons_box.get_children():
		child.queue_free()
	var options: Array = deck_rules.get_map_action_options(self)
	for item_any in options:
		if not (item_any is Dictionary):
			continue
		var item: Dictionary = item_any as Dictionary
		var code: String = str(item.get("code", "")).strip_edges()
		var label: String = str(item.get("label", ""))
		if code == "" or label == "":
			continue
		var button := Button.new()
		button.text = _ui_text(label)
		button.add_theme_font_override("font", UI_FONT)
		button.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE - 6)
		button.add_theme_constant_override("font_spacing/space", 8)
		button.pressed.connect(Callable(self, "_on_map_action_pressed").bind(code))
		map_actions_buttons_box.add_child(button)
	map_actions_prompt_panel.visible = true
	_center_map_actions_prompt()

func _hide_map_actions_prompt() -> void:
	if map_actions_prompt_panel != null:
		map_actions_prompt_panel.visible = false

func _center_map_actions_prompt() -> void:
	if map_actions_prompt_panel == null:
		return
	map_actions_prompt_panel.custom_minimum_size = Vector2.ZERO
	map_actions_prompt_panel.reset_size()
	map_actions_prompt_panel.custom_minimum_size = map_actions_prompt_panel.get_combined_minimum_size()
	map_actions_prompt_panel.reset_size()
	var view_size: Vector2 = get_viewport().get_visible_rect().size
	var size: Vector2 = map_actions_prompt_panel.size
	map_actions_prompt_panel.position = Vector2((view_size.x - size.x) * 0.5, (view_size.y - size.y) * 0.5)

func _on_map_action_pressed(code: String) -> void:
	_hide_map_actions_prompt()
	await deck_rules.execute_map_action(self, code)

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
	if card_data.is_empty():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Carta non vendibile."))
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
		_add_treasure_card_data_to_market(pending_sell_card, true)
	player_gold += max(0, pending_sell_price)
	if hand_ui != null and hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)
	_refresh_hand_ui()
	_hide_sell_prompt()

func _add_treasure_card_data_to_market(card_data: Dictionary, from_sell: bool = false) -> void:
	if card_data.is_empty():
		return
	var card: Node3D = CARD_SCENE.instantiate()
	add_child(card)
	card.set_meta("card_data", card_data.duplicate(true))
	card.set_meta("in_treasure_market", true)
	card.set_meta("in_treasure_stack", false)
	card.set_meta("sold_from_hand", from_sell)
	card.rotate_x(-PI / 2.0)
	card.set_meta("market_index", _reserve_next_market_index())
	if card.has_method("set_card_texture"):
		var image_path := str(card_data.get("image", ""))
		if not image_path.is_empty():
			card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", TREASURE_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	var discard_pos := treasure_reveal_pos + Vector3(0.0, float(revealed_treasure_count) * TREASURE_REVEALED_Y_STEP, 0.0)
	card.global_position = discard_pos
	revealed_treasure_count += 1
	_reposition_market_stack()

func _add_hand_card_to_treasure_market(card_data: Dictionary) -> void:
	if not _is_treasure_card_data(card_data):
		return
	_add_treasure_card_data_to_market(card_data)

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

func _show_drop_half_prompt(count: int, mode: String = "drop_half") -> void:
	if dice_drop_panel == null or dice_drop_label == null:
		return
	dice_drop_mode = mode
	# Start from an empty selection: player clicks the dice to discard.
	selected_roll_dice.clear()
	_refresh_roll_dice_buttons()
	if mode == "sacrifice_remove":
		dice_drop_label.text = _ui_text("Approccio alternativo: seleziona %d dado/i blu da rimuovere." % count)
	else:
		dice_drop_label.text = _ui_text("Seleziona %d dado/i da eliminare." % count)
	dice_drop_panel.visible = true
	_center_drop_half_prompt()
	if hand_ui != null and hand_ui.has_method("set_info"):
		if mode == "sacrifice_remove":
			hand_ui.call("set_info", _ui_text("Approccio alternativo: scegli %d dado/i blu da rimuovere e premi Ok." % count))
		else:
			hand_ui.call("set_info", _ui_text("Scegli %d dado/i da eliminare e premi Ok." % count))

func _get_pending_drop_half_count() -> int:
	return deck_rules.get_pending_drop_half_count(self)

func _set_pending_drop_half_count(value: int) -> void:
	deck_rules.set_pending_drop_half_count(self, value)

func _deck_prepare_roll() -> void:
	character_ability_used_this_roll = false
	if pending_adventure_sacrifice_roll_lock:
		pending_adventure_sacrifice_roll_lock = false
		pending_adventure_sacrifice_roll_lock_card = null
	deck_rules.prepare_roll_for_clone(self)

func _deck_apply_roll_overrides(values: Array[int]) -> void:
	deck_rules.apply_next_roll_overrides(self, values)

func _deck_after_roll_setup() -> void:
	deck_rules.start_drop_half_if_pending(self, last_roll_values.size())
	if _get_pending_drop_half_count() <= 0:
		_start_pending_adventure_sacrifice_die_removal_choice()
	deck_rules.finalize_roll_for_clone(self)

func _start_pending_adventure_sacrifice_die_removal_choice() -> void:
	if not pending_adventure_sacrifice_sequence_active:
		return
	if pending_adventure_sacrifice_remove_after_roll_count <= 0:
		return
	var available: int = max(0, int(last_roll_values.size()))
	if available <= 0:
		pending_adventure_sacrifice_remove_after_roll_count = 0
		pending_adventure_sacrifice_remove_choice_count = 0
		pending_adventure_sacrifice_sequence_active = false
		return
	pending_adventure_sacrifice_remove_choice_count = min(pending_adventure_sacrifice_remove_after_roll_count, available)
	pending_adventure_sacrifice_remove_after_roll_count = 0
	if pending_adventure_sacrifice_remove_choice_count > 0:
		_show_drop_half_prompt(pending_adventure_sacrifice_remove_choice_count, "sacrifice_remove")

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
	var mode := dice_drop_mode
	var pending_count := _get_pending_roll_dice_choice_count()
	if pending_count <= 0:
		_hide_drop_half_prompt()
		dice_drop_mode = "drop_half"
		return
	if selected_roll_dice.size() != pending_count:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Seleziona %d dadi." % pending_count))
		return
	var drop_indices: Array[int] = []
	var removed_sacrifice_dice: Array[RigidBody3D] = []
	for idx in selected_roll_dice:
		var i := int(idx)
		if i >= 0 and i < last_roll_values.size() and i < active_dice.size():
			var die: RigidBody3D = active_dice[i]
			if die != null and die.has_method("get_dice_type"):
				var dtype := str(die.call("get_dice_type"))
				if mode == "sacrifice_remove" and dtype != "blue":
					continue
			drop_indices.append(i)
	if drop_indices.size() != pending_count:
		if hand_ui != null and hand_ui.has_method("set_info"):
			if mode == "drop_half" or mode == "sacrifice_remove":
				hand_ui.call("set_info", _ui_text("Puoi eliminare solo dadi blu."))
			else:
				hand_ui.call("set_info", _ui_text("Seleziona esattamente %d dadi." % pending_count))
		return
	drop_indices.sort()
	for i in range(drop_indices.size() - 1, -1, -1):
		var drop_idx := int(drop_indices[i])
		if drop_idx >= 0 and drop_idx < active_dice.size():
			var die: RigidBody3D = active_dice[drop_idx]
			if die != null and is_instance_valid(die):
				if mode == "sacrifice_remove":
					removed_sacrifice_dice.append(die)
				else:
					die.queue_free()
			active_dice.remove_at(drop_idx)
		if drop_idx >= 0 and drop_idx < last_roll_values.size():
			last_roll_values.remove_at(drop_idx)
	if mode == "sacrifice_remove":
		for die in removed_sacrifice_dice:
			_place_sacrifice_die_on_card(die)
		dice_count = DICE_FLOW.get_total_dice(self)
		pending_adventure_sacrifice_remove_choice_count = max(0, pending_adventure_sacrifice_remove_choice_count - pending_count)
		if pending_adventure_sacrifice_remove_choice_count <= 0 and pending_adventure_sacrifice_remove_after_roll_count <= 0:
			pending_adventure_sacrifice_sequence_active = false
			pending_adventure_sacrifice_slot_card = null
	else:
		_set_pending_drop_half_count(0)
	selected_roll_dice.clear()
	_sync_roll_totals_and_ui()
	_hide_drop_half_prompt()
	dice_drop_mode = "drop_half"
	if _get_pending_drop_half_count() <= 0:
		_start_pending_adventure_sacrifice_die_removal_choice()

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

func _create_adventure_sacrifice_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 12
	add_child(prompt_layer)
	adventure_sacrifice_prompt_panel = PanelContainer.new()
	adventure_sacrifice_prompt_panel.visible = false
	adventure_sacrifice_prompt_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	adventure_sacrifice_prompt_panel.z_index = 211
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.75)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	adventure_sacrifice_prompt_panel.add_theme_stylebox_override("panel", panel_style)

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

	adventure_sacrifice_prompt_label = Label.new()
	adventure_sacrifice_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	adventure_sacrifice_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	adventure_sacrifice_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	adventure_sacrifice_prompt_label.custom_minimum_size = Vector2(420, 0)
	adventure_sacrifice_prompt_label.text = _ui_text("Usare l'effetto della carta Avventura?")
	adventure_sacrifice_prompt_label.add_theme_font_override("font", UI_FONT)
	adventure_sacrifice_prompt_label.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_sacrifice_prompt_label.add_theme_constant_override("font_spacing/space", 8)
	content.add_child(adventure_sacrifice_prompt_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.set("theme_override_constants/separation", 20)
	adventure_sacrifice_prompt_yes = Button.new()
	adventure_sacrifice_prompt_yes.text = _ui_text("Si")
	adventure_sacrifice_prompt_yes.add_theme_font_override("font", UI_FONT)
	adventure_sacrifice_prompt_yes.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_sacrifice_prompt_yes.add_theme_constant_override("font_spacing/space", 8)
	adventure_sacrifice_prompt_yes.pressed.connect(_confirm_adventure_sacrifice_prompt)
	adventure_sacrifice_prompt_no = Button.new()
	adventure_sacrifice_prompt_no.text = _ui_text("No")
	adventure_sacrifice_prompt_no.add_theme_font_override("font", UI_FONT)
	adventure_sacrifice_prompt_no.add_theme_font_size_override("font_size", PURCHASE_FONT_SIZE)
	adventure_sacrifice_prompt_no.add_theme_constant_override("font_spacing/space", 8)
	adventure_sacrifice_prompt_no.pressed.connect(_hide_adventure_sacrifice_prompt)
	button_row.add_child(adventure_sacrifice_prompt_yes)
	button_row.add_child(adventure_sacrifice_prompt_no)
	content.add_child(button_row)

	adventure_sacrifice_prompt_panel.add_child(content)
	prompt_layer.add_child(adventure_sacrifice_prompt_panel)

func _center_adventure_sacrifice_prompt() -> void:
	if adventure_sacrifice_prompt_panel == null:
		return
	adventure_sacrifice_prompt_panel.custom_minimum_size = Vector2.ZERO
	adventure_sacrifice_prompt_panel.reset_size()
	adventure_sacrifice_prompt_panel.custom_minimum_size = adventure_sacrifice_prompt_panel.get_combined_minimum_size()
	adventure_sacrifice_prompt_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size := adventure_sacrifice_prompt_panel.size
	adventure_sacrifice_prompt_panel.position = Vector2((view_size.x - size.x) * 0.5, (view_size.y - size.y) * 0.5)

func _create_chain_choice_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 12
	add_child(prompt_layer)
	chain_choice_panel = PanelContainer.new()
	chain_choice_panel.visible = false
	chain_choice_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chain_choice_panel.z_index = 220
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.45)
	chain_choice_panel.add_theme_stylebox_override("panel", panel_style)
	chain_choice_label = Label.new()
	chain_choice_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	chain_choice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chain_choice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chain_choice_label.custom_minimum_size = Vector2(760, 64)
	chain_choice_label.text = _ui_text("Scala: scegli una carta Avventura da tenere.")
	chain_choice_label.add_theme_font_override("font", UI_FONT)
	chain_choice_label.add_theme_font_size_override("font_size", 30)
	chain_choice_label.add_theme_constant_override("font_spacing/space", 8)
	chain_choice_panel.add_child(chain_choice_label)
	prompt_layer.add_child(chain_choice_panel)
	_center_chain_choice_prompt()

func _create_flip_choice_prompt() -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 13
	add_child(prompt_layer)
	flip_choice_panel = PanelContainer.new()
	flip_choice_panel.visible = false
	flip_choice_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flip_choice_panel.z_index = 221
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.45)
	flip_choice_panel.add_theme_stylebox_override("panel", panel_style)
	flip_choice_label = Label.new()
	flip_choice_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	flip_choice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flip_choice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	flip_choice_label.custom_minimum_size = Vector2(760, 64)
	flip_choice_label.text = _ui_text("Penalita Flip: scegli 1 equipaggiamento da girare.")
	flip_choice_label.add_theme_font_override("font", UI_FONT)
	flip_choice_label.add_theme_font_size_override("font_size", 30)
	flip_choice_label.add_theme_constant_override("font_spacing/space", 8)
	flip_choice_panel.add_child(flip_choice_label)
	prompt_layer.add_child(flip_choice_panel)
	_center_flip_choice_prompt()

func _show_chain_choice_prompt(text: String = "") -> void:
	if chain_choice_panel == null:
		return
	if chain_choice_label != null and text != "":
		chain_choice_label.text = _ui_text(text)
	chain_choice_panel.visible = true
	_center_chain_choice_prompt()

func _hide_chain_choice_prompt() -> void:
	if chain_choice_panel == null:
		return
	chain_choice_panel.visible = false

func _center_chain_choice_prompt() -> void:
	if chain_choice_panel == null:
		return
	chain_choice_panel.custom_minimum_size = Vector2.ZERO
	chain_choice_panel.reset_size()
	chain_choice_panel.custom_minimum_size = chain_choice_panel.get_combined_minimum_size()
	chain_choice_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size := chain_choice_panel.size
	chain_choice_panel.position = Vector2((view_size.x - size.x) * 0.5, 12.0)

func _show_flip_choice_prompt(text: String = "") -> void:
	if flip_choice_panel == null:
		return
	if flip_choice_label != null and text != "":
		flip_choice_label.text = _ui_text(text)
	flip_choice_panel.visible = true
	_center_flip_choice_prompt()

func _hide_flip_choice_prompt() -> void:
	if flip_choice_panel == null:
		return
	flip_choice_panel.visible = false

func _center_flip_choice_prompt() -> void:
	if flip_choice_panel == null:
		return
	flip_choice_panel.custom_minimum_size = Vector2.ZERO
	flip_choice_panel.reset_size()
	flip_choice_panel.custom_minimum_size = flip_choice_panel.get_combined_minimum_size()
	flip_choice_panel.reset_size()
	var view_size := get_viewport().get_visible_rect().size
	var size := flip_choice_panel.size
	flip_choice_panel.position = Vector2((view_size.x - size.x) * 0.5, 240.0)

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
	if hand_root.has_signal("request_card_info"):
		hand_root.connect("request_card_info", Callable(self, "_on_hand_request_card_info"))

	var view_size := get_viewport().get_visible_rect().size
	var card_height := view_size.y * 0.2
	if hand_root.has_method("populate"):
		hand_root.call("populate", player_hand, card_height)
	if hand_root.has_method("set_gold"):
		hand_root.call("set_gold", player_gold)
	if hand_root.has_method("set_tokens"):
		hand_root.call("set_tokens", player_tombstones)
	if hand_root.has_method("set_experience"):
		hand_root.call("set_experience", player_experience)
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
	var top_market := _get_top_market_card()
	for child in get_children():
		if not (child is Node3D):
			continue
		if not child.has_method("set_highlighted"):
			continue
		if child.has_meta("in_treasure_market") and child.get_meta("in_treasure_market", false):
			if child != top_market:
				child.set_highlighted(false)


func _track_dice_sum() -> void:
	await DICE_FLOW.track_dice_sum(self)

func _consume_next_roll_effects(values: Array[int]) -> void:
	EFFECTS_REGISTRY.consume_next_roll_effects(self, values)
	deck_rules.consume_next_roll_effects(self, values)

func _wait_for_dice_settle(dice_list: Array[RigidBody3D]) -> void:
	await DICE_FLOW.wait_for_dice_settle(self, dice_list)

func _clear_dice() -> void:
	DICE_FLOW.clear_dice(self)

func _get_top_face_value(dice: RigidBody3D) -> int:
	return DICE_FLOW.get_top_face_value(self, dice)

func _get_top_face_name(dice: RigidBody3D) -> String:
	return DICE_FLOW.get_top_face_name(self, dice)

func _get_effective_difficulty(card_data: Dictionary) -> Dictionary:
	return ADVENTURE_BATTLE_CORE.get_effective_difficulty(self, card_data)

func _apply_chain_card_effects(card: Node3D, effects: Array) -> void:
	if card == null or effects.is_empty():
		return
	for effect in effects:
		var name := str(effect).strip_edges()
		if name.is_empty():
			continue
		var chain_effect_context := {
			"main": self,
			"effect_name": name
		}
		AbilityRegistry.apply("chain_effect_router", chain_effect_context)
		if bool(chain_effect_context.get("handled", false)):
			continue

func _get_roll_total_with_chain_bonus() -> int:
	return ADVENTURE_BATTLE_CORE.get_roll_total_with_chain_bonus(self)

func _consume_chain_bonus() -> void:
	ADVENTURE_BATTLE_CORE.consume_chain_bonus(self)

func _reveal_two_adventures_for_choice() -> void:
	if pending_chain_choice_active:
		return
	var cards := _get_top_adventure_cards(2)
	if cards.size() <= 0:
		# No available cards: Scala resolves automatically.
		_cleanup_chain_cards_after_victory()
		return
	var base := _get_battlefield_target_pos()
	var offset: float = CHAIN_CHOICE_X_SPREAD
	for i in cards.size():
		var card: Node3D = cards[i]
		if card == null or not is_instance_valid(card):
			continue
		card.set_meta("in_adventure_stack", false)
		card.set_meta("in_battlefield", false)
		card.set_meta("adventure_blocking", false)
		card.set_meta("in_chain_preview", true)
		var pos := base
		if cards.size() > 1:
			pos = base + Vector3((i * 2 - 1) * offset, 0.0, 0.0)
		card.call("flip_to_side", pos)
	if cards.size() == 1:
		# One available card: no choice, keep it automatically.
		var chosen := cards[0]
		if chosen == null or not is_instance_valid(chosen):
			_cleanup_chain_cards_after_victory()
			return
		chosen.set_meta("in_chain_preview", false)
		pending_adventure_card = chosen
		_confirm_adventure_prompt()
		return
	pending_chain_choice_cards = cards
	pending_chain_choice_active = true
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", false)
	_show_chain_choice_prompt("Scala: scegli quale carta Avventura tenere. L'altra va negli scarti Avventura.")
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Scala: scegli quale avventura affrontare. L'altra va negli scarti avventura."))

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

func _get_flippable_equipped_cards() -> Array[Node3D]:
	var cards: Array[Node3D] = []
	for slot in equipment_slots:
		if slot == null:
			continue
		if not bool(slot.get_meta("occupied", false)):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		cards.append(equipped)
	return cards

func _start_flip_equipment_choice(cards: Array[Node3D]) -> void:
	pending_flip_equip_choice_cards.clear()
	for card in cards:
		if card == null or not is_instance_valid(card):
			continue
		pending_flip_equip_choice_cards.append(card)
	if pending_flip_equip_choice_cards.is_empty():
		pending_flip_equip_choice_active = false
		return
	pending_flip_equip_choice_active = true
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", false)
	_show_flip_choice_prompt("Penalita Flip: scegli 1 equipaggiamento da girare.")
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("Penalita Flip: scegli quale equipaggiamento girare."))

func _resolve_flip_equipment_choice(chosen: Node3D) -> void:
	if chosen == null or not is_instance_valid(chosen):
		return
	if not pending_flip_equip_choice_cards.has(chosen):
		return
	_apply_flip_to_equipment_card(chosen)
	pending_flip_equip_choice_cards.clear()
	pending_flip_equip_choice_active = false
	_hide_flip_choice_prompt()
	_continue_pending_flip_penalties()
	_try_resolve_pending_adventure_sacrifice_after_cost()
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not _is_mandatory_action_locked())

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
	chosen.set_meta("in_chain_preview", false)
	if other != null and is_instance_valid(other):
		other.set_meta("in_chain_preview", false)
		_move_adventure_to_discard(other)
	_hide_chain_choice_prompt()
	pending_adventure_card = chosen
	_confirm_adventure_prompt()

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
	card.set_meta("in_chain_preview", false)
	card.set_meta("in_mission_side", false)
	card.set_meta("in_event_row", false)
	card.set_meta("in_adventure_discard", false)
	card.remove_meta("adventure_discard_index")
	card.set_meta("in_adventure_stack", true)
	card.set_meta("stack_index", min_index - 1)
	card.rotation = Vector3(-PI / 2.0, 0.0, 0.0)
	if card.has_method("set_face_up"):
		card.call("set_face_up", false)
	if card.has_meta("adventure_type"):
		card.remove_meta("adventure_type")
	BOARD_CORE.reposition_stack(self, "in_adventure_stack", adventure_deck_pos)
	BOARD_CORE.reposition_adventure_discard_stack(self)

func _update_adventure_value_box() -> void:
	ADVENTURE_BATTLE_CORE.update_adventure_value_box(self)

func _refresh_roll_dice_buttons() -> void:
	DICE_FLOW.refresh_roll_dice_buttons(self)

func _on_roll_die_button_pressed(index: int) -> void:
	DICE_FLOW.on_roll_die_button_pressed(self, index)

func _get_selected_roll_values() -> Array[int]:
	return DICE_FLOW.get_selected_roll_values(self)

func _on_compare_pressed() -> void:
	_try_resolve_active_curse_after_roll()
	ADVENTURE_BATTLE_CORE.on_compare_pressed(self)

func _apply_battlefield_result(card: Node3D, total: int) -> void:
	ADVENTURE_BATTLE_CORE.apply_battlefield_result(self, card, total)

func _cleanup_chain_cards_after_victory() -> void:
	ADVENTURE_BATTLE_CORE.cleanup_chain_cards_after_victory(self)
	pending_chain_reveal_lock = false
	if not pending_flip_equip_choice_active:
		_hide_chain_choice_prompt()
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not _is_mandatory_action_locked())

func _is_chain_resolution_locked() -> bool:
	return pending_chain_choice_active or pending_chain_reveal_lock or pending_flip_equip_choice_active

func _is_mandatory_action_locked() -> bool:
	if match_closed:
		return true
	if adventure_sacrifice_prompt_panel != null and adventure_sacrifice_prompt_panel.visible:
		return true
	if _is_sacrifice_remove_choice_locked():
		return true
	if pending_curse_unequip_count > 0:
		return true
	if pending_penalty_discards > 0:
		return true
	if pending_mandatory_draw_locks > 0:
		return true
	return _is_chain_resolution_locked()

func _begin_mandatory_draw_lock() -> void:
	pending_mandatory_draw_locks += 1
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not _is_mandatory_action_locked())

func _end_mandatory_draw_lock() -> void:
	pending_mandatory_draw_locks = max(0, pending_mandatory_draw_locks - 1)
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not _is_mandatory_action_locked())

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
	if player_current_hearts <= 0:
		_show_match_end_message("Game Over: hai finito i cuori.")

func _consume_equipped_prevent_heart_loss() -> bool:
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		if not _card_has_timed_effect(data, "sacrifice_prevent_heart_loss", "on_heart_loss"):
			continue
		slot.set_meta("occupied", false)
		slot.set_meta("equipped_card", null)
		equipped.queue_free()
		_apply_equipment_slot_limit_after_curse()
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
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		var effects: Array = data.get("effects", [])
		if effects.has(effect_name):
			return true
	return false

func _count_equipped_timed_effect(effect_name: String, when: String = "") -> int:
	var count: int = 0
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if bool(equipped.get_meta("equipped_flipped", false)):
			continue
		var data: Dictionary = equipped.get_meta("card_data", {})
		if _card_has_timed_effect(data, effect_name, when):
			count += 1
	return count

func _get_equipped_roll_total_modifier() -> int:
	var modifier: int = 0
	modifier -= _count_equipped_timed_effect("equipped_roll_total_minus_1", "after_roll")
	var all_dice_minus_cards: int = _count_equipped_timed_effect("equipped_all_dice_minus_1", "after_roll")
	if all_dice_minus_cards > 0 and not last_roll_values.is_empty():
		var reducible: int = 0
		for v in last_roll_values:
			if int(v) > 1:
				reducible += 1
		modifier -= reducible * all_dice_minus_cards
	return modifier

func _apply_end_turn_equipped_rewards() -> void:
	if phase_index != 2:
		return
	if retreated_this_turn:
		return
	if _get_blocking_adventure_card() != null:
		return
	var bonus_coins: int = 2 * _count_equipped_timed_effect("end_turn_if_no_enemy_gain_coin_2", "end_turn")
	var bonus_xp: int = 2 * _count_equipped_timed_effect("end_turn_if_no_enemy_gain_xp_2", "end_turn")
	if bonus_coins > 0:
		player_gold += bonus_coins
		if hand_ui != null and hand_ui.has_method("set_gold"):
			hand_ui.call("set_gold", player_gold)
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Fine turno senza nemici: +%d monete." % bonus_coins))
	if bonus_xp > 0:
		player_experience += bonus_xp
		if hand_ui != null and hand_ui.has_method("set_experience"):
			hand_ui.call("set_experience", player_experience)
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Fine turno senza nemici: +%d XP." % bonus_xp))

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

func _get_current_battlefield_hearts_for_penalty(card_data: Dictionary) -> int:
	var battlefield := _get_battlefield_card()
	if battlefield == null or not is_instance_valid(battlefield):
		return -1
	var battlefield_data: Dictionary = battlefield.get_meta("card_data", {})
	var requested_id := str(card_data.get("id", "")).strip_edges()
	var battlefield_id := str(battlefield_data.get("id", "")).strip_edges()
	if requested_id != "" and battlefield_id != "" and requested_id != battlefield_id:
		return -1
	return int(battlefield.get_meta("battlefield_hearts", -1))

func _force_end_turn_from_failure() -> void:
	if phase_index != 1:
		return
	if hand_ui == null or not hand_ui.has_method("set_phase"):
		return
	var turn_idx := 1
	if hand_ui.has_method("get_turn_index"):
		turn_idx = max(1, int(hand_ui.call("get_turn_index")))
	hand_ui.call("set_phase", 2, turn_idx)

func _apply_failure_penalty(card_data: Dictionary, total: int) -> void:
	var penalties: Array = card_data.get("penalty_violet", [])
	if penalties.is_empty():
		return
	var applied: Array[String] = []
	var battlefield_hearts := _get_current_battlefield_hearts_for_penalty(card_data)
	for penalty in penalties:
		var code := str(penalty).strip_edges()
		if code.is_empty():
			continue
		var penalty_context := {
			"main": self,
			"code": code,
			"total": int(total),
			"battlefield_hearts": battlefield_hearts,
			"applied": applied
		}
		AbilityRegistry.apply("penalty_code_router", penalty_context)
		if bool(penalty_context.get("handled", false)):
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
	return HAND_FLOW_CORE.discard_one_hand_card(self)

func _discard_one_card_for_penalty() -> bool:
	return HAND_FLOW_CORE.discard_one_card_for_penalty(self)

func _set_hand_discard_mode(active: bool, reason: String = "") -> void:
	HAND_FLOW_CORE.set_hand_discard_mode(self, active, reason)

func _on_hand_request_discard_card(card: Dictionary) -> void:
	if _is_mandatory_action_locked():
		if pending_penalty_discards <= 0:
			return
		if pending_curse_unequip_count > 0 or pending_mandatory_draw_locks > 0 or _is_chain_resolution_locked():
			return
	HAND_FLOW_CORE.on_hand_request_discard_card(self, card)
	_try_resolve_pending_adventure_sacrifice_after_cost()

func _on_hand_request_sell_card(card: Dictionary) -> void:
	if phase_index != 0:
		return
	if match_closed:
		return
	if pending_penalty_discards > 0 or pending_curse_unequip_count > 0:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Completa prima gli scarti obbligatori."))
		return
	var resolved := _resolve_card_data(card)
	_show_sell_prompt(resolved)

func _on_hand_request_card_info(card: Dictionary) -> void:
	var resolved: Dictionary = _resolve_card_data(card)
	_show_card_info_from_data(resolved)

func _on_hand_request_play_boss(card: Dictionary) -> void:
	if _is_mandatory_action_locked():
		return
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
		player_hand.append(card_data)
		equipped.queue_free()
		_apply_equipment_slot_limit_after_curse()
		_refresh_hand_ui()
		return true
	return false

func _flip_one_equipped_card() -> bool:
	if pending_flip_equip_choice_active:
		pending_flip_penalties_to_resolve += 1
		return true
	var cards := _get_flippable_equipped_cards()
	if cards.is_empty():
		# No valid targets (none equipped or all already flipped): penalty resolves automatically.
		return false
	if cards.size() == 1:
		return _apply_flip_to_equipment_card(cards[0])
	_start_flip_equipment_choice(cards)
	return true

func _continue_pending_flip_penalties() -> void:
	while pending_flip_penalties_to_resolve > 0 and not pending_flip_equip_choice_active:
		pending_flip_penalties_to_resolve -= 1
		# Resolve one pending flip at a time.
		_flip_one_equipped_card()

func _apply_flip_to_equipment_card(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if bool(card.get_meta("equipped_flipped", false)):
		return false
	card.set_meta("equipped_flipped", true)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", false)
	_apply_equipment_slot_limit_after_curse()
	return true

func _restore_flipped_equipment() -> void:
	var changed := false
	for slot in equipment_slots:
		if slot == null:
			continue
		if not slot.has_meta("occupied") or not slot.get_meta("occupied", false):
			continue
		var equipped := slot.get_meta("equipped_card", null) as Node3D
		if equipped == null or not is_instance_valid(equipped):
			continue
		if not bool(equipped.get_meta("equipped_flipped", false)):
			continue
		equipped.set_meta("equipped_flipped", false)
		if equipped.has_method("set_face_up"):
			equipped.call_deferred("set_face_up", true)
		changed = true
	if changed:
		_apply_equipment_slot_limit_after_curse()

func _spawn_defeat_explosion(world_pos: Vector3, defeated_card: Node3D = null) -> void:
	var explosion_points: Array[Vector3] = []
	if defeated_card != null and is_instance_valid(defeated_card):
		var center: Vector3 = defeated_card.global_position + Vector3(0.0, 0.12, 0.0)
		var right: Vector3 = defeated_card.global_transform.basis.x.normalized()
		var forward: Vector3 = defeated_card.global_transform.basis.z.normalized()
		if right.length_squared() < 0.001:
			right = Vector3.RIGHT
		if forward.length_squared() < 0.001:
			forward = Vector3.FORWARD
		var spread_offsets: Array[Vector2] = [
			Vector2(-0.35, -0.55),
			Vector2(0.32, -0.15),
			Vector2(-0.22, 0.30),
			Vector2(0.28, 0.60)
		]
		for off in spread_offsets:
			explosion_points.append(center + right * off.x + forward * off.y)
	else:
		explosion_points.append(world_pos + Vector3(0.0, 0.12, 0.0))

	var tex := ResourceLoader.load(EXPLOSION_SHEET) as Texture2D
	if tex != null:
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
		for i in explosion_points.size():
			var point: Vector3 = explosion_points[i]
			var sprite := AnimatedSprite3D.new()
			sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			sprite.pixel_size = 0.01
			sprite.sprite_frames = frames
			add_child(sprite)
			sprite.global_position = point
			sprite.play("default")
			sprite.animation_finished.connect(Callable(self, "_queue_free_if_valid").bind(sprite))
			if i < explosion_points.size() - 1:
				await get_tree().create_timer(0.2).timeout
		return
	for i in explosion_points.size():
		var point: Vector3 = explosion_points[i]
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
		flash.global_position = point
		var tween := create_tween()
		tween.tween_property(flash, "scale", Vector3(1.6, 1.6, 1.6), 0.25)
		tween.parallel().tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.25)
		tween.finished.connect(Callable(self, "_queue_free_if_valid").bind(flash))
		if i < explosion_points.size() - 1:
			await get_tree().create_timer(0.2).timeout

func _queue_free_if_valid(node: Node) -> void:
	if node != null and is_instance_valid(node):
		node.queue_free()

func _apply_curse(card_data: Dictionary) -> void:
	curse_stats_override = card_data.get("stats", {}) as Dictionary
	active_curse_id = str(card_data.get("id", ""))
	curse_texture_override = _get_curse_texture_path(card_data)
	active_curse_data = card_data.duplicate(true)
	_apply_character_texture_override()
	_init_character_stats(true)
	player_current_hearts = clamp(player_current_hearts, 0, player_max_hearts)
	_apply_equipment_slot_limit_after_curse("Maledizione")
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()

func _clear_active_curse(send_to_discard: bool = true) -> void:
	if active_curse_id.strip_edges() == "":
		return
	if send_to_discard and not active_curse_data.is_empty():
		_spawn_active_curse_into_adventure_discard(active_curse_data)
	curse_stats_override = {}
	active_curse_id = ""
	curse_texture_override = ""
	active_curse_data = {}
	_apply_character_texture_override()
	_init_character_stats(true)
	player_current_hearts = clamp(player_current_hearts, 0, player_max_hearts)
	_apply_equipment_slot_limit_after_curse()
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()

func _spawn_active_curse_into_adventure_discard(card_data: Dictionary) -> void:
	if card_data.is_empty():
		return
	var card: Node3D = CARD_SCENE.instantiate()
	add_child(card)
	card.set_meta("card_data", card_data.duplicate(true))
	var image_path: String = str(card_data.get("image", ""))
	if image_path == "":
		image_path = _get_adventure_image_path(card_data)
	if image_path != "" and card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", ADVENTURE_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	_move_adventure_to_discard(card)

func _try_resolve_active_curse_after_roll() -> void:
	if active_curse_id.strip_edges() == "" or active_curse_data.is_empty():
		return
	var remove_condition: String = str(active_curse_data.get("remove_condition", "")).strip_edges().to_lower()
	if remove_condition == "":
		return
	match remove_condition:
		"when_two_dice_match":
			if _roll_has_matching_pair(last_roll_values):
				var curse_name: String = str(active_curse_data.get("name", "Maledizione"))
				_clear_active_curse(true)
				if hand_ui != null and hand_ui.has_method("set_info"):
					hand_ui.call("set_info", _ui_text("Maledizione rimossa: %s negli scarti avventura." % curse_name))
		_:
			pass

func _roll_has_matching_pair(values: Array) -> bool:
	if values.is_empty():
		return false
	var seen: Dictionary = {}
	for raw in values:
		var v: int = int(raw)
		if seen.has(v):
			return true
		seen[v] = true
	return false

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
	_refresh_character_backpack_marker()

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
	_spawn_battlefield_rewards(rewards, _get_reward_drop_center())

func _spawn_battlefield_rewards(rewards: Array, coin_pile_center: Vector3) -> void:
	if rewards.is_empty():
		return
	reward_token_pile_count = 0
	for reward in rewards:
		var code := str(reward)
		if code.begins_with("reward_coin_"):
			var count := int(code.get_slice("_", 2))
			if count > 0:
				spawn_reward_coins_stack(count, coin_pile_center)
			continue
		if code.begins_with("reward_xp_"):
			var xp_count: int = max(0, int(code.get_slice("_", 2)))
			if xp_count > 0:
				var token_center: Vector3 = _get_next_reward_token_center()
				_spawn_reward_tokens_with_code(xp_count, TOKEN_XP_1, "reward_xp_1", token_center)
			continue
		var token_center: Vector3 = _get_next_reward_token_center()
		match code:
			"reward_group_vaso_di_coccio":
				_spawn_reward_tokens_with_code(1, TOKEN_VASO, code, token_center)
			"reward_group_chest":
				_spawn_reward_tokens_with_code(1, TOKEN_CHEST, code, token_center)
			"reward_group_teca":
				_spawn_reward_tokens_with_code(1, TOKEN_TECA, code, token_center)
			"reward_tier_1":
				_spawn_reward_tokens_with_code(1, TOKEN_VASO, code, token_center)
			"reward_tier_2":
				_spawn_reward_tokens_with_code(1, TOKEN_CHEST, code, token_center)
			"reward_tier_3":
				_spawn_reward_tokens_with_code(1, TOKEN_TECA, code, token_center)
			"reward_token_tombstone":
				_spawn_reward_tokens_with_code(1, TOKEN_TOMBSTONE, code, token_center)
			"reward_xp_1", "reward_token_experience_1":
				_spawn_reward_tokens_with_code(1, TOKEN_XP_1, "reward_xp_1", token_center)
			"reward_xp_5", "reward_token_experience_5":
				_spawn_reward_tokens_with_code(1, TOKEN_XP_5, "reward_xp_5", token_center)
			"reward_token_experience":
				_spawn_reward_tokens_with_code(1, TOKEN_XP_1, "reward_xp_1", token_center)

func _get_next_coin_pile_center() -> Vector3:
	return _get_reward_drop_center()

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
	deck_spawn.spawn_treasure_cards(self)

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
		center = _get_reward_token_drop_center()
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
	if not character_auto_form_by_hearts:
		return
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

func _try_transform_character(card: Node3D) -> bool:
	if card == null or not is_instance_valid(card):
		return false
	if not character_transform_enabled:
		return false
	if card != character_card:
		return false
	if phase_index == 2:
		return false
	var current_entry: Dictionary = _get_character_entry(active_character_id)
	if current_entry.is_empty():
		return false
	var target_id: String = str(current_entry.get("transform_to", "")).strip_edges()
	if target_id.is_empty():
		return false
	var cost: int = int(current_entry.get("transform_cost", 0))
	if cost < 0:
		cost = 0
	if player_gold < cost:
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Servono %d oro per trasformare il personaggio." % cost))
		return true
	player_gold -= cost
	active_character_id = target_id
	_apply_character_texture_override()
	_init_character_stats(true)
	_update_hand_ui_stats()
	if hand_ui != null and hand_ui.has_method("set_info"):
		var target_name: String = str(_get_character_entry(active_character_id).get("name", active_character_id))
		hand_ui.call("set_info", _ui_text("Trasformazione riuscita: %s (-%d oro)." % [target_name, cost]))
	return true

func _spawn_adventure_cards() -> void:
	deck_spawn.spawn_adventure_cards(self)

func _spawn_boss_cards() -> void:
	deck_spawn.spawn_boss_cards(self)

func _find_boss_image(card: Dictionary) -> String:
	var card_name := _normalize_name(str(card.get("name", "")))
	var boss_dir: String = str(active_asset_dirs.get("boss", "res://assets/cards/ghost_n_goblins/boss"))
	var dir := DirAccess.open(boss_dir)
	if dir == null:
		return ""
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			var base := _normalize_name(file_name.get_basename())
			if base == card_name:
				dir.list_dir_end()
				return "%s/%s" % [boss_dir, file_name]
		file_name = dir.get_next()
	dir.list_dir_end()
	return ""

func _spawn_character_card() -> void:
	deck_spawn.spawn_character_card(self)

func _init_character_stats(preserve_current: bool = false) -> void:
	var character_entry: Dictionary = _get_character_entry(active_character_id)
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
		# Test override: keep 30 starting gold even if character card defines a lower value.
		if not character_entry.is_empty():
			player_gold = max(player_gold, 30)
			player_experience = int(character_entry.get("start_xp", player_experience))
	dice_count = DICE_FLOW.get_total_dice(self)
	_update_hand_ui_stats()
	_refresh_character_hearts_tokens()
	_refresh_character_backpack_marker()

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

func _get_equipment_bonus_slots_from_card_data(card_data: Dictionary) -> int:
	if card_data.is_empty():
		return 0
	var effects: Array = card_data.get("effects", [])
	var extra: int = 0
	for effect in effects:
		var name := EFFECTS_REGISTRY.canonical_effect_code(str(effect))
		if name == "armor_extra_slot_1":
			extra += 1
		elif name == "armor_extra_slot_2":
			extra += 2
	return max(0, extra)

func _get_equipment_bonus_hearts_from_card_data(card_data: Dictionary) -> int:
	if card_data.is_empty():
		return 0
	var effects: Array = card_data.get("effects", [])
	var extra: int = 0
	for effect in effects:
		var name := EFFECTS_REGISTRY.canonical_effect_code(str(effect))
		if name == "equip_max_hearts_plus_2":
			extra += 2
	return max(0, extra)

func _get_equipment_bonus_hand_from_card_data(card_data: Dictionary) -> int:
	if card_data.is_empty():
		return 0
	var effects: Array = card_data.get("effects", [])
	var extra: int = 0
	for effect in effects:
		var name := EFFECTS_REGISTRY.canonical_effect_code(str(effect))
		if name == "equip_max_hand_plus_2":
			extra += 2
	return max(0, extra)

func _get_active_equipment_bonus_slots() -> int:
	var extra: int = 0
	for card in _get_equipped_cards_sorted():
		if card == null or not is_instance_valid(card):
			continue
		if bool(card.get_meta("equipped_flipped", false)):
			continue
		var card_data: Dictionary = card.get_meta("card_data", {})
		extra += _get_equipment_bonus_slots_from_card_data(card_data)
	return max(0, extra)

func _get_active_equipment_bonus_hearts() -> int:
	var extra: int = 0
	for card in _get_equipped_cards_sorted():
		if card == null or not is_instance_valid(card):
			continue
		if bool(card.get_meta("equipped_flipped", false)):
			continue
		var card_data: Dictionary = card.get_meta("card_data", {})
		extra += _get_equipment_bonus_hearts_from_card_data(card_data)
	return max(0, extra)

func _get_active_equipment_bonus_hand() -> int:
	var extra: int = 0
	for card in _get_equipped_cards_sorted():
		if card == null or not is_instance_valid(card):
			continue
		if bool(card.get_meta("equipped_flipped", false)):
			continue
		var card_data: Dictionary = card.get_meta("card_data", {})
		extra += _get_equipment_bonus_hand_from_card_data(card_data)
	return max(0, extra)

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

func _request_forced_unequip(count: int, reason: String = "Slot equip ridotti") -> void:
	pending_curse_unequip_count = max(0, count)
	if not reason.strip_edges().is_empty():
		pending_forced_unequip_reason = reason.strip_edges()
	_update_curse_unequip_prompt()

func _apply_equipment_slot_limit_after_curse(reason: String = "Slot equip ridotti") -> void:
	if equipment_slots_root == null or character_card == null:
		return
	if not reason.strip_edges().is_empty():
		pending_forced_unequip_reason = reason.strip_edges()
	var base_stats: Dictionary = _get_character_stats()
	if not curse_stats_override.is_empty():
		base_stats = curse_stats_override
	player_max_hearts = max(0, int(base_stats.get("max_hearts", player_max_hearts)) + _get_active_equipment_bonus_hearts())
	player_max_hand = max(0, int(base_stats.get("max_hand", player_max_hand)) + _get_active_equipment_bonus_hand())
	player_current_hearts = clamp(player_current_hearts, 0, player_max_hearts)
	var target_slots: int = max(0, _get_character_max_slots() + _get_active_equipment_bonus_slots())
	if equipment_slots.size() < target_slots:
		_add_equipment_slots(target_slots - equipment_slots.size())
		_request_forced_unequip(0, pending_forced_unequip_reason)
		_update_hand_ui_stats()
		return
	_compact_equipment_slots()
	var equipped_cards: Array[Node3D] = _get_equipped_cards_sorted()
	var equipped_count: int = equipped_cards.size()
	var must_unequip: int = max(0, equipped_count - target_slots)
	if must_unequip > 0:
		_request_forced_unequip(must_unequip, pending_forced_unequip_reason)
		return
	var extra_slots: int = equipment_slots.size() - target_slots
	if extra_slots > 0:
		_remove_equipment_slots(extra_slots)
	_request_forced_unequip(0, pending_forced_unequip_reason)
	_update_hand_ui_stats()

func _update_curse_unequip_prompt() -> void:
	if hand_ui != null and hand_ui.has_method("set_phase_button_enabled"):
		hand_ui.call("set_phase_button_enabled", not _is_mandatory_action_locked())
	if pending_curse_unequip_count <= 0:
		return
	if hand_ui != null and hand_ui.has_method("set_info"):
		hand_ui.call("set_info", _ui_text("%s: riprendi %d equipaggiamenti in mano." % [pending_forced_unequip_reason, pending_curse_unequip_count]))

func _on_hand_request_place_equipment(card: Dictionary, screen_pos: Vector2) -> void:
	if _is_mandatory_action_locked():
		return
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
	card.set_meta("equipped_flipped", false)
	var extra := _apply_equipment_extra_slots(card_data)
	card.set_meta("extra_slots", extra)
	_apply_equipment_slot_limit_after_curse()

func _apply_equipment_extra_slots(card_data: Dictionary) -> int:
	return _get_equipment_bonus_slots_from_card_data(card_data)

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
	if hand_ui.has_method("set_gold"):
		hand_ui.call("set_gold", player_gold)
	if hand_ui.has_method("set_tokens"):
		hand_ui.call("set_tokens", player_tombstones)
	if hand_ui.has_method("set_experience"):
		hand_ui.call("set_experience", player_experience)

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
	player_hand.append(card_data)
	card.queue_free()
	_apply_equipment_slot_limit_after_curse()
	_refresh_hand_ui()

func _on_hand_request_use_magic(card: Dictionary) -> void:
	if _is_mandatory_action_locked():
		return
	if phase_index != 1:
		return
	var resolved := _resolve_card_data(card)
	var card_type := str(resolved.get("type", "")).strip_edges().to_lower()
	if card_type != "istantaneo":
		return
	if _is_adventure_sacrifice_resolution_pending():
		if hand_ui != null and hand_ui.has_method("set_info"):
			hand_ui.call("set_info", _ui_text("Completa prima l'approccio alternativo: lancia e rimuovi i dadi richiesti."))
		return
	if not CARD_TIMING.is_card_activation_allowed_now(self, resolved):
		CARD_TIMING.show_card_timing_hint(self, resolved)
		return
	_show_action_prompt(resolved, true, null)

func _get_pending_roll_dice_choice_count() -> int:
	if dice_drop_mode == "sacrifice_remove":
		return max(0, pending_adventure_sacrifice_remove_choice_count)
	return _get_pending_drop_half_count()

func _is_drop_half_prompt_mode() -> bool:
	return dice_drop_mode == "drop_half"

func _is_sacrifice_remove_prompt_mode() -> bool:
	return dice_drop_mode == "sacrifice_remove"

func _is_adventure_sacrifice_resolution_pending() -> bool:
	return pending_adventure_sacrifice_sequence_active or pending_adventure_sacrifice_remove_after_roll_count > 0 or pending_adventure_sacrifice_remove_choice_count > 0

func _is_sacrifice_remove_choice_locked() -> bool:
	if dice_drop_mode != "sacrifice_remove":
		return false
	if dice_drop_panel == null or not dice_drop_panel.visible:
		return false
	return _get_pending_roll_dice_choice_count() > 0

func _resolve_card_data(card: Dictionary) -> Dictionary:
	return HAND_FLOW_CORE.resolve_card_data(self, card)

func _replace_hand_card(original: Dictionary, resolved: Dictionary) -> void:
	HAND_FLOW_CORE.replace_hand_card(self, original, resolved)

func _remove_hand_card(original: Dictionary, resolved: Dictionary) -> void:
	HAND_FLOW_CORE.remove_hand_card(self, original, resolved)

func _spawn_regno_del_male() -> void:
	deck_rules.spawn_regno_del_male(self)

func _setup_regno_overlay() -> void:
	deck_rules.setup_regno_overlay(self)

func _build_regno_boxes() -> void:
	deck_rules.build_regno_boxes(self)

func _update_regno_overlay() -> void:
	deck_rules.update_regno_overlay(self)

func _update_regno_reward_label() -> void:
	deck_rules.update_regno_reward_label(self)

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
	return deck_rules.get_regno_track_nodes(self)

func _get_regno_track_rewards() -> Array:
	return deck_rules.get_regno_track_rewards(self)

func _format_regno_reward(code: String) -> String:
	return deck_rules.format_regno_reward(code)

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
	deck_rules.spawn_astaroth(self)

func _build_adventure_image_index() -> void:
	adventure_image_index.clear()
	var adventure_dir: String = str(active_asset_dirs.get("adventure", "res://assets/cards/ghost_n_goblins/adventure"))
	var dir := DirAccess.open(adventure_dir)
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
			adventure_image_index[key].append("%s/%s" % [adventure_dir, file_name])
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
	MUSIC_CORE.play_music(self, MUSIC_TRACK, BATTLE_MUSIC_TRACK)

func _update_phase_music(immediate: bool = false) -> void:
	MUSIC_CORE.update_phase_music(self, immediate)

func _crossfade_music(to_battle: bool, immediate: bool = false) -> void:
	MUSIC_CORE.crossfade_music(self, to_battle, immediate)

func _on_battle_music_delay_timeout() -> void:
	if not music_enabled:
		return
	if phase_index != 1:
		return
	if music_player == null or battle_music_player == null:
		return
	if not battle_music_player.playing:
		battle_music_player.play()
	if not music_player.playing:
		music_player.play()
	music_fade_tween = create_tween()
	music_fade_tween.set_parallel(true)
	music_fade_tween.tween_property(battle_music_player, "volume_db", -28.0, 0.8)
	music_fade_tween.tween_property(music_player, "volume_db", -80.0, 0.8)
	music_fade_tween.chain().tween_callback(func() -> void:
		if music_player != null:
			music_player.stop()
	)

func _strip_variant_suffix(card_name: String) -> String:
	var parts := card_name.split(" ")
	if parts.size() > 1:
		var last := parts[parts.size() - 1]
		if last.is_valid_int():
			parts.remove_at(parts.size() - 1)
			return " ".join(parts)
	return card_name
