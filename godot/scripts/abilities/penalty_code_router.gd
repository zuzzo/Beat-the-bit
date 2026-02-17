extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	var code: String = str(context.get("code", "")).strip_edges()
	if main == null or code.is_empty():
		return
	var total: int = int(context.get("total", 0))
	var battlefield_hearts: int = int(context.get("battlefield_hearts", -1))
	var applied: Array = context.get("applied", [])

	if code.begins_with("fail_") and code.find("_hearts_") > 0:
		var hearts_context := {
			"main": main,
			"code": code,
			"battlefield_hearts": battlefield_hearts,
			"applied": applied
		}
		AbilityRegistry.apply("fail_hearts_conditional", hearts_context)
		context["applied"] = hearts_context.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("lose_heart_"):
		var amount: int = max(1, int(code.get_slice("_", 2)))
		var lose_context := {
			"main": main,
			"amount": amount,
			"applied": applied
		}
		AbilityRegistry.apply("lose_heart", lose_context)
		context["applied"] = lose_context.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("lose_coins_"):
		var coins: int = max(0, int(code.get_slice("_", 2)))
		var coins_context := {
			"main": main,
			"amount": coins,
			"applied": applied
		}
		AbilityRegistry.apply("lose_coins", coins_context)
		context["applied"] = coins_context.get("applied", applied)
		context["handled"] = true
		return

	if code == "add_green_die":
		var green_context := {
			"main": main,
			"applied": applied
		}
		AbilityRegistry.apply("add_green_die", green_context)
		context["applied"] = green_context.get("applied", applied)
		context["handled"] = true
		return

	if code == "discard_hand_card_1":
		var discard_context := {
			"main": main,
			"applied": applied
		}
		AbilityRegistry.apply("discard_hand_card_1", discard_context)
		context["applied"] = discard_context.get("applied", applied)
		context["handled"] = true
		return

	if code == "flip_equipment":
		var flip_context := {
			"main": main,
			"applied": applied
		}
		AbilityRegistry.apply("flip_equipment", flip_context)
		context["applied"] = flip_context.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("fail_even_lose_3_coins_or_odd_lose_heart"):
		var even_odd_coins := {
			"main": main,
			"total": total,
			"applied": applied,
			"even_action": "lose_coins",
			"even_amount": 3,
			"odd_action": "lose_heart",
			"odd_amount": 1
		}
		AbilityRegistry.apply("fail_even_or_odd", even_odd_coins)
		context["applied"] = even_odd_coins.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("fail_even_discard_or_odd_lose_heart"):
		var even_odd_discard := {
			"main": main,
			"total": total,
			"applied": applied,
			"even_action": "discard_hand_card_1",
			"odd_action": "lose_heart",
			"odd_amount": 1
		}
		AbilityRegistry.apply("fail_even_or_odd", even_odd_discard)
		context["applied"] = even_odd_discard.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("fail_even_flip_or_odd_lose_heart"):
		var even_odd_flip := {
			"main": main,
			"total": total,
			"applied": applied,
			"even_action": "flip_equipment",
			"odd_action": "lose_heart",
			"odd_amount": 1
		}
		AbilityRegistry.apply("fail_even_or_odd", even_odd_flip)
		context["applied"] = even_odd_flip.get("applied", applied)
		context["handled"] = true
		return

	if code.begins_with("fail_even_poison_or_odd_lose_heart"):
		var even_odd_poison := {
			"main": main,
			"total": total,
			"applied": applied,
			"even_action": "add_green_die",
			"odd_action": "lose_heart",
			"odd_amount": 1
		}
		AbilityRegistry.apply("fail_even_or_odd", even_odd_poison)
		context["applied"] = even_odd_poison.get("applied", applied)
		context["handled"] = true
		return
