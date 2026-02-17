extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	if main._discard_one_card_for_penalty():
		var applied: Array = context.get("applied", [])
		applied.append("scarta 1 carta")
		context["applied"] = applied
	context["handled"] = true
