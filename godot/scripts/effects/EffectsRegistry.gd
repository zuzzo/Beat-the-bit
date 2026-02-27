extends RefCounted
class_name EffectsRegistry

const EFFECT_ALIASES := {
	# Keep legacy/variant codes mapped to a single canonical effect id.
	"reward_token_experience_1": "reward_xp_1",
	"reward_token_experience_5": "reward_xp_5",
	"reward_token_experience": "reward_xp_1"
}

static func canonical_effect_code(effect_name: String) -> String:
	var code: String = effect_name.strip_edges()
	if code == "":
		return ""
	if EFFECT_ALIASES.has(code):
		return str(EFFECT_ALIASES.get(code, code))
	return code

static func canonicalize_effect_list(effects: Array) -> Array:
	var out: Array = []
	var seen: Dictionary = {}
	for raw in effects:
		var code: String = canonical_effect_code(str(raw))
		if code == "":
			continue
		if seen.has(code):
			continue
		seen[code] = true
		out.append(code)
	return out

static func apply_direct_card_effect(main: Node, effect_name: String, _card_data: Dictionary, _action_window: String) -> bool:
	match canonical_effect_code(effect_name):
		"heal_1":
			main._apply_heal(1, "effect_heal_1")
			return true
		"add_red_die":
			main.red_dice += 1
			main.dice_count = main.DICE_FLOW.get_total_dice(main)
			if not main.roll_pending_apply and not main.roll_in_progress:
				main.DICE_FLOW.clear_dice_preview(main)
				main.DICE_FLOW.spawn_dice_preview(main)
			return true
		"deal_1_damage":
			apply_direct_damage_to_battlefield(main, 1)
			return true
		"remove_one_blue_die":
			main.blue_dice = max(0, int(main.blue_dice) - 1)
			main.dice_count = main.DICE_FLOW.get_total_dice(main)
			if not main.roll_pending_apply and not main.roll_in_progress:
				main.DICE_FLOW.clear_dice_preview(main)
				main.DICE_FLOW.spawn_dice_preview(main)
			return true
		"fendente_damage_10_12_return_hand":
			return _apply_range_damage_and_return(main, 10, 12)
		"sferzata_damage_7_9_return_hand":
			return _apply_range_damage_and_return(main, 7, 9)
		"calcio_damage_13_15_return_hand":
			return _apply_range_damage_and_return(main, 13, 15)
		"smoke_cloud_end_turn":
			main.roll_pending_apply = false
			main.last_roll_values.clear()
			main.selected_roll_dice.clear()
			main.post_roll_effects.clear()
			main._consume_pending_adventure_sacrifice_die_removal()
			if main.hand_ui != null and main.hand_ui.has_method("set_phase"):
				var turn_idx: int = 1
				if main.hand_ui.has_method("get_turn_index"):
					turn_idx = max(1, int(main.hand_ui.call("get_turn_index")))
				main.hand_ui.call("set_phase", 2, turn_idx)
			return true
		"discard_revealed_adventure":
			main._discard_revealed_adventure_card()
			return true
		"regno_del_male_portal":
			main._try_advance_regno_track()
			main._update_regno_reward_label()
			return true
		"sacrifice_open_portal":
			main._apply_sacrifice_open_portal()
			return true
		"reset_hearts_and_dice":
			main.player_current_hearts = main.player_max_hearts
			if main.has_method("_update_character_form_for_hearts"):
				main._update_character_form_for_hearts()
			main.blue_dice = main.base_dice_count
			main.green_dice = 0
			main.red_dice = 0
			main.dice_count = main.DICE_FLOW.get_total_dice(main)
			main._update_hand_ui_stats()
			if not main.roll_pending_apply and not main.roll_in_progress:
				main.DICE_FLOW.clear_dice_preview(main)
				main.DICE_FLOW.spawn_dice_preview(main)
			return true
		_:
			return false

static func apply_direct_damage_to_battlefield(main: Node, amount: int) -> void:
	if amount <= 0:
		return
	var battlefield: Node3D = main._get_battlefield_card()
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
		main.enemies_defeated_total += 1
	main._report_battlefield_reward(card_data, main.last_roll_total, int(card_data.get("difficulty", 0)))
	main._spawn_defeat_explosion(battlefield.global_position)
	main._move_adventure_to_discard(battlefield)
	main._cleanup_chain_cards_after_victory()

static func apply_post_roll_effect(main: Node, effect_name: String, selected_values: Array[int]) -> void:
	if main.last_roll_values.is_empty():
		return
	match canonical_effect_code(effect_name):
		"after_roll_minus_1_all_dice":
			for i in main.last_roll_values.size():
				main.last_roll_values[i] = max(1, int(main.last_roll_values[i]) - 1)
		"halve_even_dice":
			for i in main.last_roll_values.size():
				var v := int(main.last_roll_values[i])
				if v % 2 == 0:
					main.last_roll_values[i] = max(1, int(v / 2))
		"after_roll_set_one_die_to_1":
			var target := get_first_selected_die_index(main)
			if target >= 0:
				main.last_roll_values[target] = 1
		"lowest_die_applies_to_all":
			if selected_values.is_empty():
				return
			var low := selected_values[0]
			for v in selected_values:
				low = min(low, int(v))
			for i in main.last_roll_values.size():
				main.last_roll_values[i] = int(low)
		_:
			pass

static func get_first_selected_die_index(main: Node) -> int:
	for idx in main.selected_roll_dice:
		var i := int(idx)
		if i >= 0 and i < main.last_roll_values.size():
			return i
	if not main.last_roll_values.is_empty():
		return 0
	return -1

static func collect_reroll_indices(main: Node, effect_name: String, target: Array[int]) -> void:
	match canonical_effect_code(effect_name):
		"reroll_5_or_6":
			for i in main.last_roll_values.size():
				var v := int(main.last_roll_values[i])
				if (v == 5 or v == 6) and not target.has(i):
					target.append(i)
		"reroll_same_dice":
			for idx in main.selected_roll_dice:
				var i := int(idx)
				if i < 0 or i >= main.last_roll_values.size():
					continue
				if not target.has(i):
					target.append(i)
		_:
			pass

static func consume_next_roll_effects(main: Node, values: Array[int]) -> void:
	if values.is_empty() or main.post_roll_effects.is_empty():
		return
	var consumed: Array[String] = []
	for effect in main.post_roll_effects:
		var name := canonical_effect_code(str(effect))
		match name:
			"next_roll_minus_2_all_dice":
				for i in values.size():
					values[i] = max(1, int(values[i]) - 2)
				consumed.append(name)
			"next_roll_double_then_remove_half":
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
		main.post_roll_effects.erase(name)

static func _apply_range_damage_and_return(main: Node, min_difficulty: int, max_difficulty: int) -> bool:
	var battlefield: Node3D = main._get_battlefield_card()
	if battlefield == null or not is_instance_valid(battlefield):
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Nessun nemico in campo."))
		return true
	var card_data: Dictionary = battlefield.get_meta("card_data", {})
	var difficulty: int = int(card_data.get("difficulty", 0))
	if difficulty < min_difficulty or difficulty > max_difficulty:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Effetto valido solo su nemici difficolta %d-%d." % [min_difficulty, max_difficulty]))
		return true
	apply_direct_damage_to_battlefield(main, 1)
	var source: Node3D = main.pending_action_source_card
	if source != null and is_instance_valid(source):
		main._force_return_equipped_to_hand(source)
	return true
