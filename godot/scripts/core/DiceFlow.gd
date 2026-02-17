extends RefCounted
class_name DiceFlow

static func launch_dice_at(main: Node, spawn_pos: Vector3, launch_dir: Vector3) -> void:
	clear_dice(main, false)
	main._hide_outcome()
	main.roll_in_progress = true
	main._deck_prepare_roll()
	main.dice_count = get_total_dice(main)
	spawn_dice(main, spawn_pos, launch_dir)
	main.blue_dice += 1
	main.dice_count = get_total_dice(main)
	track_dice_sum(main)

static func start_dice_hold(main: Node, mouse_pos: Vector2) -> void:
	if main.dice_hold_active:
		return
	if not can_start_roll(main):
		return
	main.dice_hold_active = true
	main.dice_hold_start_ms = Time.get_ticks_msec()
	clear_dice_preview(main)
	spawn_dice_preview(main)
	update_dice_hold(main, mouse_pos)

static func release_dice_hold(main: Node, mouse_pos: Vector2) -> void:
	if not main.dice_hold_active:
		return
	main.dice_hold_active = false
	clear_dice_preview(main)
	var hit_start: Vector3 = main._ray_to_plane(main.mouse_down_pos)
	var hit_end: Vector3 = main._ray_to_plane(mouse_pos)
	if hit_end == Vector3.INF or hit_start == Vector3.INF:
		return
	var launch_dir := hit_end - hit_start
	launch_dir.y = 0.0
	if launch_dir.length() > 0.001:
		launch_dir = launch_dir.normalized()
	launch_dice_at(main, hit_end, launch_dir)

static func can_start_roll(main: Node) -> bool:
	# While the player must choose a discard, dice rolling must stay paused.
	if int(main.pending_penalty_discards) > 0:
		return false
	if main.pending_chain_reveal_lock:
		return false
	if main.roll_pending_apply:
		return false
	if main.roll_in_progress:
		return false
	if main.last_roll_success or main.last_roll_penalty or main.roll_trigger_reset:
		return true
	if main.roll_history.is_empty():
		return true
	return false

static func reset_roll_trigger(main: Node) -> void:
	main.roll_trigger_reset = true

static func spawn_dice_preview(main: Node) -> void:
	var count: int = get_total_dice(main)
	var center: Vector3 = main.adventure_deck_pos + main.DICE_PREVIEW_OFFSET
	for i in count:
		var dice: RigidBody3D = main.DICE_SCENE.instantiate() as RigidBody3D
		main.add_child(dice)
		dice.freeze = true
		dice.global_position = center + Vector3(i * 0.5, 0.3, 0.0)
		main.dice_preview.append(dice)

static func ensure_idle_dice_preview(main: Node) -> void:
	if main.dice_hold_active:
		return
	if main.roll_pending_apply:
		return
	if not main.active_dice.is_empty():
		return
	var desired: int = get_total_dice(main)
	if main.dice_preview.size() == desired:
		return
	clear_dice_preview(main)
	spawn_dice_preview(main)

static func update_dice_hold(main: Node, mouse_pos: Vector2) -> void:
	if main.dice_preview.is_empty():
		return
	var hit: Vector3 = main._ray_to_plane(mouse_pos)
	if hit == Vector3.INF:
		return
	var radius: float = 0.8
	var t: float = Time.get_ticks_msec() / 1000.0
	var count: int = main.dice_preview.size()
	for i in count:
		var dice: RigidBody3D = main.dice_preview[i]
		if not is_instance_valid(dice):
			continue
		var angle: float = t * 2.5 + (TAU * float(i) / max(count, 1))
		var pos: Vector3 = hit + Vector3(cos(angle) * radius, 0.3, sin(angle) * radius)
		dice.global_position = pos
		dice.global_rotation = Vector3(0.0, angle, 0.0)

static func clear_dice_preview(main: Node) -> void:
	for dice in main.dice_preview:
		if is_instance_valid(dice):
			dice.queue_free()
	main.dice_preview.clear()

static func spawn_dice(main: Node, spawn_pos: Vector3, launch_dir: Vector3) -> void:
	var hold_scale: float = 1.0
	var offset_index: int = 0
	offset_index = spawn_dice_batch(main, spawn_pos, hold_scale, launch_dir, main.blue_dice, "blue", offset_index)
	offset_index = spawn_dice_batch(main, spawn_pos, hold_scale, launch_dir, main.green_dice, "green", offset_index)
	offset_index = spawn_dice_batch(main, spawn_pos, hold_scale, launch_dir, main.red_dice, "red", offset_index)

static func spawn_dice_batch(main: Node, spawn_pos: Vector3, hold_scale: float, launch_dir: Vector3, count: int, dice_type: String, start_index: int) -> int:
	for i in count:
		var dice: RigidBody3D = main.DICE_SCENE.instantiate() as RigidBody3D
		main.add_child(dice)
		var idx: int = start_index + i
		dice.global_position = spawn_pos + Vector3(idx * 0.6, 2.0, 0.0)
		dice.global_rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		var lateral_strength: float = randf_range(1.2, 2.0) * hold_scale
		var lateral_angle: float = randf() * TAU
		var dir_boost: Vector3 = launch_dir * 1.2
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
		main.pending_dice.append(dice)
		main.active_dice.append(dice)
	return start_index + count

static func get_total_dice(main: Node) -> int:
	return max(1, main.blue_dice + main.green_dice + main.red_dice)

static func track_dice_sum(main: Node) -> void:
	if main.pending_dice.is_empty():
		return
	await wait_for_dice_settle(main, main.pending_dice)
	var values: Array[int] = []
	var names: Array[String] = []
	var total: int = 0
	for dice in main.pending_dice:
		if not is_instance_valid(dice):
			continue
		var value: int = get_top_face_value(main, dice)
		values.append(value)
		names.append(get_top_face_name(main, dice))
		total += _get_signed_die_value(value, dice)
	main.pending_dice.clear()
	main.roll_in_progress = false
	main._consume_next_roll_effects(values)
	main._deck_apply_roll_overrides(values)
	main.last_roll_values = values.duplicate()
	main.selected_roll_dice.clear()
	if main._get_pending_drop_half_count() <= 0:
		for i in main.last_roll_values.size():
			main.selected_roll_dice.append(i)
	main.last_roll_total = total
	main.roll_pending_apply = true
	main.last_roll_success = false
	main.last_roll_penalty = false
	main.roll_trigger_reset = false
	main._deck_after_roll_setup()
	main.roll_history.append(total)
	main.roll_color_history.append(", ".join(names))
	if main.sum_label != null:
		main.sum_label.text = main._ui_text("Risultati: %s | Colori: %s" % [", ".join(main.roll_history), " | ".join(main.roll_color_history)])
	if main.hand_ui != null and main.hand_ui.has_method("set_phase_button_enabled"):
		main.hand_ui.call("set_phase_button_enabled", false)

static func wait_for_dice_settle(_main: Node, dice_list: Array[RigidBody3D]) -> void:
	var elapsed: float = 0.0
	var timeout: float = 5.0
	var stable_time: float = 0.0
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
		await _main.get_tree().create_timer(0.1).timeout
		elapsed += 0.1

static func clear_dice(main: Node, clear_post_roll_effects: bool = true) -> void:
	for dice in main.active_dice:
		if is_instance_valid(dice):
			dice.queue_free()
	main.active_dice.clear()
	main.pending_dice.clear()
	main.roll_pending_apply = false
	main.last_roll_values.clear()
	main.selected_roll_dice.clear()
	if clear_post_roll_effects:
		main.post_roll_effects.clear()

static func get_top_face_value(_main: Node, dice: RigidBody3D) -> int:
	if dice.has_method("get_top_value"):
		return dice.get_top_value()
	return 1

static func get_top_face_name(_main: Node, dice: RigidBody3D) -> String:
	if dice.has_method("get_top_name"):
		return dice.get_top_name()
	return "?"

static func rebuild_roll_values_from_active_dice(main: Node) -> void:
	main.last_roll_values.clear()
	main.selected_roll_dice.clear()
	var names: Array[String] = []
	var total: int = 0
	for i in main.active_dice.size():
		var dice: RigidBody3D = main.active_dice[i]
		if dice == null or not is_instance_valid(dice):
			continue
		var value: int = get_top_face_value(main, dice)
		main.last_roll_values.append(value)
		total += _get_signed_die_value(value, dice)
		names.append(get_top_face_name(main, dice))
		main.selected_roll_dice.append(main.last_roll_values.size() - 1)
	main.last_roll_total = total
	if main.sum_label != null:
		main.sum_label.text = "Risultati: %s | Colori: %s | Attuale: %d" % [", ".join(main.roll_history), " | ".join(main.roll_color_history), main.last_roll_total]

static func recalculate_last_roll_total(main: Node) -> void:
	var total: int = 0
	for i in main.last_roll_values.size():
		var value: int = int(main.last_roll_values[i])
		var dice: RigidBody3D = null
		if i < main.active_dice.size():
			dice = main.active_dice[i]
		total += _get_signed_die_value(value, dice)
	main.last_roll_total = total

static func _get_signed_die_value(value: int, dice: RigidBody3D) -> int:
	if dice != null and is_instance_valid(dice) and dice.has_method("get_dice_type"):
		var dice_type := str(dice.call("get_dice_type"))
		if dice_type == "red":
			return -value
	return value

static func refresh_roll_dice_buttons(main: Node) -> void:
	if main.player_dice_buttons_row == null:
		return
	var selected: Array = main.selected_roll_dice.duplicate()
	selected.sort()
	var dice_types_sig := ""
	for i in main.last_roll_values.size():
		dice_types_sig += "|%s" % _get_roll_die_type(main, i)
	var key := "%s|%s|%s|%d|%s" % [str(main.roll_pending_apply), str(main.last_roll_values), str(selected), int(main.pending_chain_bonus), dice_types_sig]
	if key == main.player_dice_buttons_key:
		return
	main.player_dice_buttons_key = key
	for child in main.player_dice_buttons_row.get_children():
		child.queue_free()
	if not main.roll_pending_apply:
		return
	for i in main.last_roll_values.size():
		var idx: int = i
		var value: int = main.last_roll_values[idx]
		var btn := Button.new()
		btn.toggle_mode = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(36, 30)
		btn.text = str(value)
		btn.add_theme_font_override("font", main.UI_FONT)
		btn.add_theme_font_size_override("font_size", 24)
		_apply_roll_die_button_theme(btn, _get_roll_die_type(main, idx))
		btn.button_pressed = main.selected_roll_dice.has(idx)
		btn.pressed.connect(func() -> void:
			on_roll_die_button_pressed(main, idx)
		)
		main.player_dice_buttons_row.add_child(btn)
	var chain_bonus_count := int(main.pending_chain_bonus / 3)
	for _i in chain_bonus_count:
		var bonus_btn := Button.new()
		bonus_btn.focus_mode = Control.FOCUS_NONE
		bonus_btn.disabled = true
		bonus_btn.custom_minimum_size = Vector2(36, 30)
		bonus_btn.text = "3"
		bonus_btn.tooltip_text = main._ui_text("Bonus Piattaforma")
		bonus_btn.add_theme_font_override("font", main.UI_FONT)
		bonus_btn.add_theme_font_size_override("font_size", 24)
		main.player_dice_buttons_row.add_child(bonus_btn)

static func _get_roll_die_type(main: Node, index: int) -> String:
	if index < 0 or index >= main.active_dice.size():
		return "blue"
	var die: RigidBody3D = main.active_dice[index]
	if die == null or not is_instance_valid(die):
		return "blue"
	if die.has_method("get_dice_type"):
		return str(die.call("get_dice_type"))
	return "blue"

static func _apply_roll_die_button_theme(btn: Button, die_type: String) -> void:
	var bg := Color(0.35, 0.35, 0.35, 0.9)
	var border := Color(0.95, 0.95, 0.95, 0.85)
	var fg := Color(1, 1, 1, 1)
	match die_type:
		"green":
			bg = Color(0.28, 0.82, 0.36, 0.95)
			border = Color(0.10, 0.35, 0.12, 0.95)
			fg = Color(0.03, 0.08, 0.03, 1)
		"red":
			bg = Color(0.90, 0.28, 0.30, 0.95)
			border = Color(0.38, 0.08, 0.09, 0.95)
			fg = Color(1, 1, 1, 1)
		_:
			bg = Color(0.25, 0.50, 0.92, 0.95)
			border = Color(0.08, 0.22, 0.45, 0.95)
			fg = Color(1, 1, 1, 1)
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = border
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = bg.darkened(0.25)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", fg)
	btn.add_theme_color_override("font_pressed_color", fg)

static func on_roll_die_button_pressed(main: Node, index: int) -> void:
	if main._get_pending_roll_dice_choice_count() > 0:
		if main._is_drop_half_prompt_mode():
			if main.active_dice[index] != null and is_instance_valid(main.active_dice[index]):
				var dice_type := ""
				if main.active_dice[index].has_method("get_dice_type"):
					dice_type = str(main.active_dice[index].call("get_dice_type"))
				if dice_type == "green":
					if main.hand_ui != null and main.hand_ui.has_method("set_info"):
						main.hand_ui.call("set_info", main._ui_text("Non puoi eliminare dadi verdi."))
					refresh_roll_dice_buttons(main)
					return
		if main.selected_roll_dice.has(index):
			main.selected_roll_dice.erase(index)
		else:
			main.selected_roll_dice.append(index)
		refresh_roll_dice_buttons(main)
		return
	if main.selected_roll_dice.has(index):
		main.selected_roll_dice.erase(index)
	else:
		main.selected_roll_dice.append(index)
	if main.action_prompt_panel != null and main.action_prompt_panel.visible:
		var action_window := CardTiming.get_current_card_action_window(main, main.pending_action_card_data)
		var effects := CardTiming.get_effects_for_window(main.pending_action_card_data, action_window)
		if main.roll_pending_apply and effects.has("after_roll_set_one_die_to_1"):
			main.selected_roll_dice.clear()
			main.selected_roll_dice.append(index)
			main.last_roll_values[index] = 1
			recalculate_last_roll_total(main)
			refresh_roll_dice_buttons(main)
			if not main.pending_action_is_magic and main.pending_action_source_card != null and is_instance_valid(main.pending_action_source_card):
				if effects.has("return_to_hand"):
					main._force_return_equipped_to_hand(main.pending_action_source_card)
			if main.pending_action_is_magic:
				if not effects.has("return_to_hand"):
					main.player_hand.erase(main.pending_action_card_data)
					main._refresh_hand_ui()
			main._hide_action_prompt()

static func get_selected_roll_values(main: Node) -> Array[int]:
	var out: Array[int] = []
	for idx in main.selected_roll_dice:
		var i := int(idx)
		if i < 0 or i >= main.last_roll_values.size():
			continue
		out.append(main.last_roll_values[i])
	return out
