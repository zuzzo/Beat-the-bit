extends RefCounted
class_name AdventureBattleCore

static func get_effective_difficulty(main: Node, card_data: Dictionary) -> Dictionary:
	var base := int(card_data.get("difficulty", 0))
	var modifier := 0
	for effect in main.post_roll_effects:
		var effect_name := str(effect)
		if effect_name == "next_roll_plus_3":
			modifier -= 3
	var effective := base + modifier
	return {
		"base": base,
		"modifier": modifier,
		"effective": effective
	}

static func get_roll_total_with_chain_bonus(main: Node) -> int:
	var total: int = int(main.last_roll_total)
	if main.pending_chain_bonus != 0:
		total += int(main.pending_chain_bonus)
	if main.has_method("_get_equipped_roll_total_modifier"):
		total += int(main.call("_get_equipped_roll_total_modifier"))
	return total

static func consume_chain_bonus(main: Node) -> void:
	if main.pending_chain_bonus == 0:
		return
	main.pending_chain_bonus = 0
	update_adventure_value_box(main)

static func update_adventure_value_box(main: Node) -> void:
	if main.adventure_value_panel == null or main.adventure_value_label == null:
		return
	if main.phase_index != 1:
		main.adventure_value_panel.visible = false
		return
	var battlefield: Node3D = main._get_battlefield_card() as Node3D
	if battlefield == null:
		main.adventure_value_panel.visible = false
		return
	var data: Dictionary = battlefield.get_meta("card_data", {})
	if data.is_empty():
		main.adventure_value_panel.visible = false
		return
	var diff_info: Dictionary = get_effective_difficulty(main, data)
	var base: int = int(diff_info.get("base", 0))
	var modifier: int = int(diff_info.get("modifier", 0))
	var effective: int = int(diff_info.get("effective", 0))
	if modifier != 0:
		main.adventure_value_label.text = main._ui_text("Mostro: %d\n(mod %d)" % [effective, modifier])
	else:
		main.adventure_value_label.text = main._ui_text("Mostro: %d" % base)
	if main.player_value_label != null:
		if main.roll_pending_apply:
			var total: int = get_roll_total_with_chain_bonus(main)
			if main.pending_chain_bonus != 0:
				main.player_value_label.text = main._ui_text("Tuo tiro: %d (+%d)" % [total, main.pending_chain_bonus])
			else:
				main.player_value_label.text = main._ui_text("Tuo tiro: %d" % total)
		else:
			main.player_value_label.text = main._ui_text("Tuo tiro: -")
	main.DICE_FLOW.refresh_roll_dice_buttons(main)
	if main.compare_button != null:
		main.compare_button.disabled = (not main.roll_pending_apply) or main._get_pending_roll_dice_choice_count() > 0 or main._is_mandatory_action_locked()
	main.adventure_value_panel.visible = true

static func on_compare_pressed(main: Node) -> void:
	if main._is_mandatory_action_locked():
		return
	if not main.roll_pending_apply:
		return
	if main._get_pending_roll_dice_choice_count() > 0:
		return
	var battlefield: Node3D = main._get_battlefield_card() as Node3D
	if battlefield == null:
		return
	var total: int = get_roll_total_with_chain_bonus(main)
	apply_battlefield_result(main, battlefield, total)
	consume_chain_bonus(main)

static func apply_battlefield_result(main: Node, card: Node3D, total: int) -> void:
	if card == null or not is_instance_valid(card):
		return
	var card_data: Dictionary = card.get_meta("card_data", {})
	var diff_info: Dictionary = get_effective_difficulty(main, card_data)
	var difficulty: int = int(diff_info.get("effective", card_data.get("difficulty", 0)))
	var hearts: int = int(card.get_meta("battlefield_hearts", 1))
	var card_type: String = str(card_data.get("type", "")).strip_edges().to_lower()
	var card_id: String = str(card_data.get("id", "")).strip_edges()
	if card_id == "event_portale_infernale":
		if total <= difficulty:
			main._resolve_portale_infernale_success(card, total, difficulty)
			main.last_roll_success = true
			if total == difficulty:
				main._show_outcome("SUCCESSO PERFETTO", Color(1.0, 0.9, 0.2))
			else:
				main._show_outcome("SUCCESSO", Color(0.2, 0.9, 0.3))
		else:
			main._apply_failure_penalty(card_data, total)
			main._move_adventure_to_discard(card)
			main.last_roll_penalty = true
			main._show_outcome("INSUCCESSO", Color(0.95, 0.2, 0.2))
		main.roll_pending_apply = false
		main.last_roll_values.clear()
		main.selected_roll_dice.clear()
		main.post_roll_effects.clear()
		main._consume_pending_adventure_sacrifice_die_removal()
		if main.hand_ui != null and main.hand_ui.has_method("set_phase_button_enabled"):
			main.hand_ui.call("set_phase_button_enabled", true)
		if main.adventure_value_panel != null:
			main.adventure_value_panel.visible = false
		return
	if card_type == "maledizione" and main._has_equipped_effect("ignore_fatigue_if_all_different") and main._are_all_roll_values_different(main.last_roll_values):
		total = min(total, difficulty)
	if card_type == "maledizione":
		if total <= difficulty:
			main._move_adventure_to_discard(card)
			main.last_roll_success = true
			main._show_outcome("SUCCESSO", Color(0.2, 0.9, 0.3))
		else:
			main._apply_curse(card_data)
			# Curse is now represented on player state/form, so do not keep the same
			# physical card also in adventure discard.
			if card != null and is_instance_valid(card):
				card.queue_free()
			main.last_roll_penalty = true
			main._show_outcome("INSUCCESSO", Color(0.95, 0.2, 0.2))
		main.roll_pending_apply = false
		main.last_roll_values.clear()
		main.selected_roll_dice.clear()
		main.post_roll_effects.clear()
		main._consume_pending_adventure_sacrifice_die_removal()
		cleanup_chain_cards_after_victory(main)
		if main.hand_ui != null and main.hand_ui.has_method("set_phase_button_enabled"):
			main.hand_ui.call("set_phase_button_enabled", true)
		return
	if total <= difficulty:
		hearts -= 1
		if hearts > 0 and main._has_equipped_effect("bonus_damage_multiheart"):
			hearts -= 1
		card.set_meta("battlefield_hearts", hearts)
		if hearts > 0:
			main._spawn_battlefield_hearts(card, hearts)
		if hearts <= 0:
			var defeated_pos: Vector3 = card.global_position
			if card_type == "scontro":
				main.enemies_defeated_total += 1
			main._report_battlefield_reward(card_data, total, difficulty)
			main._move_adventure_to_discard(card)
			main._spawn_defeat_explosion(defeated_pos)
			cleanup_chain_cards_after_victory(main)
			if card_type == "boss_finale":
				main._show_match_end_message("Vittoria: Boss finale sconfitto.")
		main.last_roll_success = true
		if total == difficulty:
			main._show_outcome("SUCCESSO PERFETTO", Color(1.0, 0.9, 0.2))
		else:
			main._show_outcome("SUCCESSO", Color(0.2, 0.9, 0.3))
	else:
		main._apply_failure_penalty(card_data, total)
		main.last_roll_penalty = true
		main._show_outcome("INSUCCESSO", Color(0.95, 0.2, 0.2))
	main.roll_pending_apply = false
	main.last_roll_values.clear()
	main.selected_roll_dice.clear()
	main.post_roll_effects.clear()
	main._consume_pending_adventure_sacrifice_die_removal()
	if main.hand_ui != null and main.hand_ui.has_method("set_phase_button_enabled"):
		main.hand_ui.call("set_phase_button_enabled", true)
	if main.adventure_value_panel != null:
		main.adventure_value_panel.visible = false

static func cleanup_chain_cards_after_victory(main: Node) -> void:
	if main.chain_row_count <= 0 and main.pending_chain_bonus == 0 and main.pending_chain_choice_cards.is_empty():
		return
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_battlefield"):
			continue
		if not child.get_meta("in_battlefield", false):
			continue
		var data: Dictionary = child.get_meta("card_data", {})
		var ctype := str(data.get("type", "")).strip_edges().to_lower()
		if ctype == "concatenamento":
			main._move_adventure_to_discard(child)
	main.pending_chain_bonus = 0
	main.pending_chain_choice_cards.clear()
	main.pending_chain_choice_active = false
	main.chain_row_count = 0
