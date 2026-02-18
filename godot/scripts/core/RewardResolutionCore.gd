extends RefCounted
class_name RewardResolutionCore

static func cleanup_battlefield_rewards_for_recovery(main: Node) -> void:
	await resolve_reward_tokens_for_recovery(main)
	# Move coins toward the player HUD area, then remove them.
	var target: Vector3 = get_player_collect_target(main)
	for coin in main.get_tree().get_nodes_in_group("coins"):
		if not (coin is RigidBody3D):
			continue
		var body := coin as RigidBody3D
		if not is_instance_valid(body):
			continue
		body.freeze = true
		body.sleeping = true
		var tween := main.create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(body, "global_position", target + Vector3(randf_range(-0.06, 0.06), 0.0, randf_range(-0.06, 0.06)), 0.35)
		tween.tween_callback(func() -> void:
			if is_instance_valid(body):
				body.queue_free()
		)
	main.coin_pile_count = 0

static func resolve_reward_tokens_for_recovery(main: Node) -> void:
	var tokens: Array = main.get_tree().get_nodes_in_group("reward_tokens")
	if tokens.is_empty():
		return
	var hud_target: Vector3 = get_player_collect_target(main)
	for node in tokens:
		var token := node as RigidBody3D
		if token == null or not is_instance_valid(token):
			continue
		var code := str(token.get_meta("reward_code", ""))
		match code:
			"reward_group_vaso_di_coccio":
				await consume_token_and_draw_treasure(main, token, "vaso_di_coccio")
			"reward_group_chest":
				await consume_token_and_draw_treasure(main, token, "chest")
			"reward_group_teca":
				await consume_token_and_draw_treasure(main, token, "teca")
			"reward_token_tombstone":
				collect_tombstone_token(main, token, hud_target)
			_:
				token.queue_free()

static func consume_token_and_draw_treasure(main: Node, token: RigidBody3D, group_key: String) -> void:
	if token != null and is_instance_valid(token):
		token.queue_free()
	await draw_treasure_until_group(main, group_key)

static func draw_treasure_until_group(main: Node, group_key: String) -> void:
	var hand_target: Vector3 = get_hand_collect_target(main)
	while true:
		var top: Node3D = main._get_top_treasure_card() as Node3D
		if top == null:
			if main._ensure_treasure_stack_from_market_if_empty():
				top = main._get_top_treasure_card() as Node3D
			if top == null:
				break
		var card_data: Dictionary = top.get_meta("card_data", {})
		top.set_meta("in_treasure_stack", false)
		await flip_treasure_card_for_recovery(main, top)
		var group := str(card_data.get("group", "")).strip_edges().to_lower()
		if group == group_key:
			var keep_tween := main.create_tween()
			keep_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			keep_tween.tween_property(top, "global_position", hand_target, 0.34)
			await keep_tween.finished
			main.player_hand.append(card_data)
			top.queue_free()
			main._refresh_hand_ui()
			main._ensure_treasure_stack_from_market_if_empty()
			return
		var market_index: int = int(main._reserve_next_market_index())
		top.set_meta("market_index", market_index)
		top.set_meta("in_treasure_market", true)
		var discard_pos: Vector3 = main.treasure_reveal_pos + Vector3(0.0, float(main.revealed_treasure_count) * main.TREASURE_REVEALED_Y_STEP, 0.0)
		var tween := main.create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(top, "global_position", discard_pos, 0.18)
		await tween.finished
		main.revealed_treasure_count += 1
		main._reposition_market_stack()
		main._ensure_treasure_stack_from_market_if_empty()

static func flip_treasure_card_for_recovery(main: Node, card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var reveal_pos: Vector3 = main.treasure_reveal_pos + Vector3(0.0, main.revealed_treasure_count * main.TREASURE_REVEALED_Y_STEP, 0.0)
	card.set_meta("in_treasure_reveal_animation", true)
	if card.has_method("flip_to_side"):
		lift_treasure_card_to_stack_top(main, card)
		card.set_meta("flip_rotate_on_lifted_axis", true)
		card.call("flip_to_side", reveal_pos)
		await main.get_tree().create_timer(1.45).timeout
	else:
		card.global_position = reveal_pos
	if card != null and is_instance_valid(card):
		card.set_meta("in_treasure_reveal_animation", false)

static func lift_treasure_card_to_stack_top(main: Node, card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	var deck_top_y: float = main.treasure_deck_pos.y
	var market_top_y: float = main.treasure_reveal_pos.y
	var top_deck: Node3D = main._get_top_treasure_card() as Node3D
	if top_deck != null and is_instance_valid(top_deck):
		deck_top_y = top_deck.global_position.y
	var top_market: Node3D = main._get_top_market_card() as Node3D
	if top_market != null and is_instance_valid(top_market):
		market_top_y = top_market.global_position.y
	var lift_y: float = max(deck_top_y, market_top_y) + main.TREASURE_CARD_THICKNESS_Y
	# Set the lift height immediately before flip to avoid any tween interruption.
	var pos := card.global_position
	pos.y = lift_y
	card.global_position = pos

static func collect_tombstone_token(main: Node, token: RigidBody3D, target: Vector3) -> void:
	if token == null or not is_instance_valid(token):
		return
	token.freeze = true
	token.sleeping = true
	var tween := main.create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(token, "global_position", target + Vector3(randf_range(-0.06, 0.06), 0.0, randf_range(-0.06, 0.06)), 0.35)
	tween.tween_callback(func() -> void:
		if is_instance_valid(token):
			token.queue_free()
		main.player_tombstones += 1
		if main.hand_ui != null and main.hand_ui.has_method("set_tokens"):
			main.hand_ui.call("set_tokens", main.player_tombstones)
	)

static func get_player_collect_target(main: Node) -> Vector3:
	var view_size := main.get_viewport().get_visible_rect().size
	var hud_point := Vector2(210.0, view_size.y - 120.0)
	var world: Vector3 = main._ray_to_plane(hud_point)
	if world == Vector3.INF:
		return main.battlefield_pos + Vector3(-2.4, 0.02, 1.9)
	world.y = main.battlefield_pos.y + 0.02
	return world

static func get_hand_collect_target(main: Node) -> Vector3:
	var view_size := main.get_viewport().get_visible_rect().size
	var hud_point := Vector2(view_size.x * 0.5, view_size.y - 92.0)
	var world: Vector3 = main._ray_to_plane(hud_point)
	if world == Vector3.INF:
		return main.battlefield_pos + Vector3(0.0, 0.02, 2.1)
	world.y = main.battlefield_pos.y + 0.02
	return world
