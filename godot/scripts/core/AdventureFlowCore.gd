extends RefCounted
class_name AdventureFlowCore

const ADVENTURE_PROMPT := preload("res://scripts/core/AdventurePrompt.gd")

static func get_adventure_stack_card_at(main: Node, mouse_pos: Vector2) -> Node3D:
	var card: Node3D = main._get_card_under_mouse(mouse_pos) as Node3D
	if card != null and card.has_meta("in_adventure_stack") and card.get_meta("in_adventure_stack", false):
		return main._get_top_adventure_card() as Node3D
	var top: Node3D = main._get_top_adventure_card() as Node3D
	if top == null:
		return null
	var hit: Vector3 = main._ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return null
	var center: Vector3 = top.global_position
	if abs(hit.x - center.x) <= main.CARD_HIT_HALF_SIZE.x and abs(hit.z - center.z) <= main.CARD_HIT_HALF_SIZE.y:
		return top
	return null

static func on_end_turn_with_battlefield(main: Node) -> void:
	var battlefield: Node3D = main._get_blocking_adventure_card() as Node3D
	if battlefield == null:
		return
	var card_data: Dictionary = battlefield.get_meta("card_data", {})
	var card_type := str(card_data.get("type", "")).strip_edges().to_lower()
	if card_type == "boss_finale":
		var hearts: int = int(battlefield.get_meta("battlefield_hearts", 1))
		if hearts > 0:
			main._return_final_boss_to_area(battlefield)
			return
	if main._is_portale_infernale_card(battlefield):
		main._return_portale_infernale_to_event_row(battlefield)
		return
	main._show_battlefield_warning()
	var hearts: int = int(battlefield.get_meta("battlefield_hearts", 1))
	battlefield.set_meta("battlefield_hearts", hearts + 1)
	main._spawn_battlefield_hearts(battlefield, hearts + 1)

static func try_show_adventure_prompt(main: Node, card: Node3D) -> void:
	if main.phase_index != 1:
		return
	if main._get_blocking_adventure_card() != null:
		main._show_battlefield_warning()
		return
	main.pending_adventure_card = card
	main._confirm_adventure_prompt()

static func hide_adventure_prompt(main: Node) -> void:
	ADVENTURE_PROMPT.hide(main)

static func decline_adventure_prompt(main: Node) -> void:
	main.retreated_this_turn = true
	hide_adventure_prompt(main)
