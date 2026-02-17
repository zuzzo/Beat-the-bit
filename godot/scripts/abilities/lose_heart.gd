extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var amount: int = max(1, int(context.get("amount", 1)))
	main._apply_player_heart_loss(amount)
	var applied: Array = context.get("applied", [])
	applied.append("-%d cuore" % amount)
	context["applied"] = applied
	context["handled"] = true
