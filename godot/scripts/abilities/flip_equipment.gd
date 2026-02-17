extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	if main._flip_one_equipped_card():
		var applied: Array = context.get("applied", [])
		applied.append("gira 1 equip")
		context["applied"] = applied
	context["handled"] = true
