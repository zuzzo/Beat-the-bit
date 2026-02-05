extends RefCounted
class_name EffectsRegistry

static func apply_direct_card_effect(main: Node, effect_name: String, _card_data: Dictionary, _action_window: String) -> bool:
	match effect_name:
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
		"discard_revealed_adventure":
			main._discard_revealed_adventure_card()
			return true
		"regno_del_male_portal", "sacrifice_open_portal":
			main._try_advance_regno_track()
			main._update_regno_reward_label()
			return true
		"reset_hearts_and_dice":
			main.player_current_hearts = main.player_max_hearts
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

static func apply_post_roll_effect(main: Node, effect_name: String, selected_values: Array[int]) -> void:
	if main.last_roll_values.is_empty():
		return
	match effect_name:
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
	match effect_name:
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
		main.post_roll_effects.erase(name)
