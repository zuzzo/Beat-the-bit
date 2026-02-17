extends RefCounted
class_name HandFlowCore

static func resolve_card_data(main: Node, card: Dictionary) -> Dictionary:
	var card_id := str(card.get("id", "")).strip_edges()
	if card_id == "":
		return card
	for entry in CardDatabase.cards:
		if str(entry.get("id", "")) == card_id:
			return entry
	return card

static func replace_hand_card(main: Node, original: Dictionary, resolved: Dictionary) -> void:
	if original == resolved:
		return
	var idx: int = int(main.player_hand.find(original))
	if idx < 0:
		return
	main.player_hand[idx] = resolved

static func remove_hand_card(main: Node, original: Dictionary, resolved: Dictionary) -> void:
	var idx: int = int(main.player_hand.find(original))
	if idx < 0 and original != resolved:
		idx = int(main.player_hand.find(resolved))
	if idx < 0:
		var original_id := str(original.get("id", ""))
		if original_id != "":
			for i in main.player_hand.size():
				var data: Variant = main.player_hand[i]
				if data is Dictionary and str((data as Dictionary).get("id", "")) == original_id:
					idx = i
					break
	if idx >= 0:
		main.player_hand.remove_at(idx)

static func discard_one_hand_card(main: Node) -> bool:
	if main.player_hand.is_empty():
		return false
	var removed_card: Dictionary = {}
	if main.player_hand[main.player_hand.size() - 1] is Dictionary:
		removed_card = main.player_hand[main.player_hand.size() - 1] as Dictionary
	main.player_hand.remove_at(main.player_hand.size() - 1)
	main._add_hand_card_to_treasure_market(removed_card)
	main._refresh_hand_ui()
	return true

static func discard_one_card_for_penalty(main: Node) -> bool:
	# If there are multiple cards, let the player choose.
	if main.player_hand.size() > 1:
		main.pending_penalty_discards += 1
		set_hand_discard_mode(main, true, "penalty")
		return true
	# Prefer hand discard; if hand is empty fallback to one equipped card.
	if discard_one_hand_card(main):
		return true
	return main._discard_one_equipped_card()

static func set_hand_discard_mode(main: Node, active: bool, reason: String = "") -> void:
	if active and bool(main.dice_hold_active):
		main.dice_hold_active = false
		main.DICE_FLOW.clear_dice_preview(main)
	if main.hand_ui == null or not main.hand_ui.has_method("set_discard_mode"):
		return
	main.pending_discard_reason = reason if active else ""
	main.hand_ui.call("set_discard_mode", active)
	if main.hand_ui.has_method("set_phase_button_enabled"):
		var can_pass: bool = (not active) and (not main._is_mandatory_action_locked())
		main.hand_ui.call("set_phase_button_enabled", can_pass)
	if active and main.hand_ui.has_method("set_info"):
		if main.pending_discard_reason == "hand_limit":
			main.hand_ui.call("set_info", "Fine turno: scegli carte dalla mano da scartare.")
		elif main.pending_discard_reason == "effect":
			main.hand_ui.call("set_info", "Scegli 1 carta da scartare per attivare l'effetto.")
		else:
			main.hand_ui.call("set_info", "Penalita: scegli 1 carta dalla mano da scartare.")

static func on_hand_request_discard_card(main: Node, card: Dictionary) -> void:
	if main.pending_penalty_discards <= 0:
		return
	var idx: int = int(main.player_hand.find(card))
	if idx < 0:
		return
	main.player_hand.remove_at(idx)
	main._add_hand_card_to_treasure_market(card)
	main.pending_penalty_discards = max(0, main.pending_penalty_discards - 1)
	main._refresh_hand_ui()
	if main.pending_penalty_discards <= 0:
		var finished_reason: String = str(main.pending_discard_reason)
		set_hand_discard_mode(main, false)
		if finished_reason == "effect" and not main.pending_effect_effects.is_empty():
			main.pending_discard_paid = true
			var effects: Array = main.pending_effect_effects.duplicate()
			var card_data: Dictionary = main.pending_effect_card_data.duplicate()
			var window: String = str(main.pending_effect_window)
			main.pending_effect_card_data = {}
			main.pending_effect_effects.clear()
			main.pending_effect_window = ""
			main._use_card_effects(card_data, effects, window)
			return
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			if finished_reason == "hand_limit":
				main.hand_ui.call("set_info", "Limite mano rispettato.")
			else:
				main.hand_ui.call("set_info", "Penalita applicata:\n- scarta 1 carta")
