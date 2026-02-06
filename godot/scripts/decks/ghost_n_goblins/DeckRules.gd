extends RefCounted
class_name GnGDeckRules

static func create_regno_reward_label(main: Node, ui: CanvasLayer) -> void:
	main.regno_reward_label = Label.new()
	main.regno_reward_label.text = main._ui_text("Regno: -")
	main.regno_reward_label.position = Vector2(20, 110)
	ui.add_child(main.regno_reward_label)

static func try_advance_regno_track(main: Node) -> void:
	# Advance only when leaving adventure with no unresolved blocking enemy.
	if main._get_blocking_adventure_card() != null:
		return
	if main.regno_card == null or not is_instance_valid(main.regno_card):
		return
	if main.regno_track_rewards.is_empty():
		return
	var max_index: int = main.regno_track_rewards.size() - 1
	if main.regno_track_index >= max_index:
		return
	main.regno_track_index += 1
	update_regno_reward_label(main)

static func try_spend_tombstone_on_regno(main: Node, card: Node3D) -> bool:
	if main.regno_card == null or not is_instance_valid(main.regno_card):
		return false
	if card != main.regno_card:
		return false
	if main.player_tombstones <= 0:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Non hai token Tombstone da spendere."))
		return true
	if main.regno_track_rewards.is_empty():
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Tracciato Regno non disponibile."))
		return true
	var max_index: int = main.regno_track_rewards.size() - 1
	if main.regno_track_index >= max_index:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Il Regno del Male e gia al massimo."))
		return true
	main.player_tombstones -= 1
	main.regno_track_index += 1
	update_regno_reward_label(main)
	_apply_regno_reward(main, str(main.regno_track_rewards[main.regno_track_index]))
	if main.hand_ui != null and main.hand_ui.has_method("set_tokens"):
		main.hand_ui.call("set_tokens", main.player_tombstones)
	if main.hand_ui != null and main.hand_ui.has_method("set_info"):
		var reward_code := str(main.regno_track_rewards[main.regno_track_index])
		main.hand_ui.call("set_info", main._ui_text("Speso 1 Tombstone: Regno avanza a %s." % format_regno_reward(reward_code)))
	return true

static func _apply_regno_reward(main: Node, code: String) -> void:
	match code:
		"reward_group_vaso_di_coccio":
			main._spawn_reward_tokens_with_code(1, main.TOKEN_VASO, code, main._get_reward_drop_center())
		"reward_group_chest":
			main._spawn_reward_tokens_with_code(1, main.TOKEN_CHEST, code, main._get_reward_drop_center())
		"reward_group_teca":
			main._spawn_reward_tokens_with_code(1, main.TOKEN_TECA, code, main._get_reward_drop_center())
		"gain_heart":
			main.player_current_hearts = min(main.player_max_hearts, main.player_current_hearts + 1)
			main._update_hand_ui_stats()
			main._refresh_character_hearts_tokens()
		"boss":
			main._claim_boss_to_hand_from_regno()
		"boss_finale":
			main._reveal_final_boss_from_regno()
		_:
			pass

static func get_next_chain_pos(main: Node, base_pos: Vector3) -> Vector3:
	var base: Vector3 = base_pos + main.CHAIN_ROW_OFFSET
	var pos := base + Vector3(main.chain_row_count * main.CHAIN_ROW_SPACING, 0.0, 0.0)
	main.chain_row_count += 1
	return pos

static func schedule_next_chain_reveal(main: Node) -> void:
	await main.get_tree().create_timer(1.0).timeout
	var top: Node3D = main._get_top_adventure_card()
	if top == null or not is_instance_valid(top):
		return
	main.pending_adventure_card = top
	main._confirm_adventure_prompt()

static func get_next_mission_side_pos(main: Node) -> Vector3:
	var base := Vector3(main.character_pos.x + main.MISSION_SIDE_OFFSET.x, main.adventure_reveal_pos.y, main.character_pos.z + main.MISSION_SIDE_OFFSET.z)
	var pos := base + Vector3(0.0, main.mission_side_count * main.REVEALED_Y_STEP, 0.0)
	main.mission_side_count += 1
	return pos

static func get_next_event_pos(main: Node) -> Vector3:
	var pos: Vector3 = main.event_row_pos + Vector3(main.event_row_count * main.EVENT_ROW_SPACING, 0.0, 0.0)
	main.event_row_count += 1
	return pos

static func reveal_event_card(main: Node, card: Node3D, _card_data: Dictionary) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_adventure_stack", false)
	card.set_meta("in_event_row", true)
	card.set_meta("adventure_type", "evento")
	var target_pos := get_next_event_pos(main)
	card.call("flip_to_side", target_pos)

static func reveal_mission_card(main: Node, card: Node3D, _card_data: Dictionary) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_adventure_stack", false)
	card.set_meta("in_mission_side", true)
	card.set_meta("adventure_type", "missione")
	var target_pos := get_next_mission_side_pos(main)
	card.call("flip_to_side", target_pos)

static func try_claim_mission(main: Node, card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	if main.phase_index != 0:
		return
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		return
	if not is_mission_completed(main, card_data):
		report_mission_status(main, card_data, false)
		return
	apply_mission_cost(main, card_data)
	report_mission_status(main, card_data, true)
	card.queue_free()

static func is_mission_completed(main: Node, card_data: Dictionary) -> bool:
	var req := get_mission_requirements(main, card_data)
	var enemies_required := int(req.get("defeat_enemies", 0))
	var coins_required := int(req.get("pay_coins", 0))
	if enemies_required <= 0 and coins_required <= 0:
		return false
	if enemies_required > 0 and main.enemies_defeated_total < enemies_required:
		return false
	if coins_required > 0 and main.player_gold < coins_required:
		return false
	return true

static func apply_mission_cost(main: Node, card_data: Dictionary) -> void:
	var req := get_mission_requirements(main, card_data)
	var coins_required := int(req.get("pay_coins", 0))
	if coins_required <= 0:
		return
	main.player_gold = max(0, main.player_gold - coins_required)
	if main.hand_ui != null and main.hand_ui.has_method("set_gold"):
		main.hand_ui.call("set_gold", main.player_gold)

static func get_mission_requirements(_main: Node, card_data: Dictionary) -> Dictionary:
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

static func report_mission_status(main: Node, card_data: Dictionary, completed: bool) -> void:
	if main.hand_ui == null or not main.hand_ui.has_method("set_info"):
		return
	var name := str(card_data.get("name", "Missione"))
	if not completed:
		main.hand_ui.call("set_info", "%s non completata." % name)
		return
	var rewards: Array = card_data.get("reward_brown", [])
	var silver: Array = card_data.get("reward_silver", [])
	if not silver.is_empty():
		rewards = rewards.duplicate()
		rewards.append_array(silver)
	var text := "%s completata!\nPremio:\n-" % name
	if not rewards.is_empty():
		text = "%s completata!\nPremio:\n- %s" % [name, "\n- ".join(rewards)]
	main.hand_ui.call("set_info", text)

static func spawn_regno_del_male(main: Node) -> void:
	var card: Node3D = main.CARD_SCENE.instantiate()
	main.add_child(card)
	card.global_position = main.regno_pos
	card.rotate_x(-PI / 2.0)
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", main.REGNO_FRONT)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", main.REGNO_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	main.regno_card = card

static func setup_regno_overlay(main: Node) -> void:
	main.regno_track_nodes = get_regno_track_nodes(main)
	main.regno_track_rewards = get_regno_track_rewards(main)
	_ensure_regno_outline(main)

static func build_regno_boxes(main: Node) -> void:
	return

static func update_regno_overlay(main: Node) -> void:
	if main.regno_card == null or not is_instance_valid(main.regno_card):
		return
	if main.regno_track_nodes.is_empty():
		return
	_ensure_regno_outline(main)
	main.regno_blink_time = Time.get_ticks_msec() / 1000.0
	var alpha: float = 0.25 + 0.55 * abs(sin(main.regno_blink_time * 3.0))
	var outline := main.get_meta("regno_outline", null) as MeshInstance3D
	if outline != null and outline.is_inside_tree():
		var mat := outline.material_override as ShaderMaterial
		if mat != null:
			mat.set_shader_parameter("border_color", Color(1.0, 0.9, 0.2, alpha))
		var data: Dictionary = main.regno_track_nodes[main.regno_track_index]
		_update_regno_outline_transform(main, outline, data)
	update_regno_reward_label(main)

static func _ensure_regno_outline(main: Node) -> void:
	if main.regno_card == null or not is_instance_valid(main.regno_card):
		return
	var parent_node := main.regno_card.get_node_or_null("Pivot") as Node3D
	if parent_node == null:
		parent_node = main.regno_card
	var outline := main.get_meta("regno_outline", null) as MeshInstance3D
	if outline == null or not outline.is_inside_tree():
		outline = MeshInstance3D.new()
		parent_node.add_child(outline)
		main.set_meta("regno_outline", outline)
	var quad := outline.mesh as QuadMesh
	if quad == null:
		quad = QuadMesh.new()
		outline.mesh = quad
	quad.size = Vector2(0.2, 0.2)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.9, 0.2, 0.9)
	mat.albedo_texture = _get_regno_border_texture()
	outline.material_override = mat
	outline.position = Vector3(0.0, 0.0, 0.04)
	outline.rotation = Vector3.ZERO
	outline.visible = true

static func _update_regno_outline_transform(_main: Node, outline: MeshInstance3D, data: Dictionary) -> void:
	var x := float(data.get("x", 0.0))
	var y := float(data.get("y", 0.0))
	var w := float(data.get("w", 0.0))
	var h := float(data.get("h", 0.0))
	var width: float = 1.4
	var height: float = 2.0
	var size := Vector2(w * width, h * height)
	var quad := outline.mesh as QuadMesh
	if quad != null:
		quad.size = size
	var center_x: float = -width * 0.5 + (x + w * 0.5) * width + _main.CARD_CENTER_X_OFFSET
	var center_y: float = height * 0.5 - (y + h * 0.5) * height
	outline.position = Vector3(center_x, center_y, 0.04)
	var mat := outline.material_override as StandardMaterial3D
	if mat != null:
		var color: Color = mat.albedo_color
		color.a = 0.25 + 0.55 * abs(sin(_main.regno_blink_time * 3.0))
		mat.albedo_color = color

static func _get_regno_border_texture() -> Texture2D:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var border := 4
	var color := Color(1, 1, 1, 1)
	for x in range(64):
		for y in range(64):
			if x < border or x >= 64 - border or y < border or y >= 64 - border:
				image.set_pixel(x, y, color)
	var tex := ImageTexture.create_from_image(image)
	return tex

static func update_regno_reward_label(main: Node) -> void:
	if main.regno_reward_label == null:
		return
	if main.regno_track_rewards.is_empty() or main.regno_track_index < 0 or main.regno_track_index >= main.regno_track_rewards.size():
		main.regno_reward_label.text = main._ui_text("Regno: -")
		return
	var code := str(main.regno_track_rewards[main.regno_track_index])
	main.regno_reward_label.text = main._ui_text("Regno: %s" % format_regno_reward(code))

static func get_regno_track_nodes(_main: Node) -> Array:
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

static func get_regno_track_rewards(_main: Node) -> Array:
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

static func format_regno_reward(code: String) -> String:
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

static func spawn_astaroth(main: Node) -> void:
	var card: Node3D = main.CARD_SCENE.instantiate()
	main.add_child(card)
	card.global_position = main.astaroth_pos
	card.rotate_x(-PI / 2.0)
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", main.ASTAROTH_FRONT)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", main.BOSS_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
