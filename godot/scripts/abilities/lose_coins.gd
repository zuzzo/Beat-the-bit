extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var amount: int = max(0, int(context.get("amount", 0)))
	if amount <= 0:
		context["handled"] = true
		return
	main._apply_coin_penalty(amount)
	var applied: Array = context.get("applied", [])
	applied.append("-%d monete" % amount)
	context["applied"] = applied
	context["handled"] = true
