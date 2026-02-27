extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	var code: String = str(context.get("cost_code", "")).strip_edges().to_lower()
	var card: Node3D = context.get("card", null)
	var sacrifice_effect: String = str(context.get("sacrifice_effect", ""))
	if main == null:
		return
	if code.is_empty():
		context["cost_result"] = 1
		context["handled"] = true
		return
	if code == "discard_hand_card_1":
		if main.player_hand.size() <= 0:
			if main.hand_ui != null and main.hand_ui.has_method("set_info"):
				main.hand_ui.call("set_info", main._ui_text("Costo non pagabile: nessuna carta in mano da scartare."))
			context["cost_result"] = 0
			context["handled"] = true
			return
		if main.player_hand.size() == 1:
			if not main._discard_one_hand_card_for_effect({}):
				context["cost_result"] = 0
				context["handled"] = true
				return
			context["cost_result"] = 1
			context["handled"] = true
			return
		main.pending_adventure_sacrifice_waiting_cost = true
		main.pending_adventure_sacrifice_card = card
		main.pending_adventure_sacrifice_effect = sacrifice_effect
		main.pending_penalty_discards = max(main.pending_penalty_discards, 1)
		main._set_hand_discard_mode(true, "penalty")
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Approccio alternativo: scegli 1 carta da scartare come costo."))
		context["cost_result"] = 2
		context["handled"] = true
		return
	if code == "flip_equipment":
		var flipped: bool = bool(main._flip_one_equipped_card())
		if not flipped:
			if main.hand_ui != null and main.hand_ui.has_method("set_info"):
				main.hand_ui.call("set_info", main._ui_text("Costo non pagabile: nessun equipaggiamento da girare."))
			context["cost_result"] = 0
			context["handled"] = true
			return
		if main.pending_flip_equip_choice_active:
			main.pending_adventure_sacrifice_waiting_cost = true
			main.pending_adventure_sacrifice_card = card
			main.pending_adventure_sacrifice_effect = sacrifice_effect
			context["cost_result"] = 2
			context["handled"] = true
			return
		context["cost_result"] = 1
		context["handled"] = true
		return
	if code == "lose_heart_1":
		var lose_context := {
			"main": main,
			"amount": 1
		}
		AbilityRegistry.apply("lose_heart", lose_context)
		context["cost_result"] = 1
		context["handled"] = true
		return
	if code == "add_green_die":
		var green_context := {
			"main": main
		}
		AbilityRegistry.apply("add_green_die", green_context)
		context["cost_result"] = 1
		context["handled"] = true
		return
	if code.begins_with("pay_coins_"):
		var amount_text := code.trim_prefix("pay_coins_")
		var amount: int = int(amount_text)
		if amount <= 0:
			context["cost_result"] = 0
			context["handled"] = true
			return
		if main.player_gold < amount:
			if main.hand_ui != null and main.hand_ui.has_method("set_info"):
				main.hand_ui.call("set_info", main._ui_text("Costo non pagabile: servono %d monete." % amount))
			context["cost_result"] = 0
			context["handled"] = true
			return
		var coins_context := {
			"main": main,
			"amount": amount
		}
		AbilityRegistry.apply("lose_coins", coins_context)
		context["cost_result"] = 1
		context["handled"] = true
		return
	if code.begins_with("pay_xp_"):
		var amount_text := code.trim_prefix("pay_xp_")
		var amount: int = int(amount_text)
		if amount <= 0:
			context["cost_result"] = 0
			context["handled"] = true
			return
		if int(main.player_experience) < amount:
			if main.hand_ui != null and main.hand_ui.has_method("set_info"):
				main.hand_ui.call("set_info", main._ui_text("Costo non pagabile: servono %d XP." % amount))
			context["cost_result"] = 0
			context["handled"] = true
			return
		main.player_experience = max(0, int(main.player_experience) - amount)
		if main.hand_ui != null and main.hand_ui.has_method("set_experience"):
			main.hand_ui.call("set_experience", main.player_experience)
		context["cost_result"] = 1
		context["handled"] = true
		return
