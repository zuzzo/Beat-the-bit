extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var total: int = int(context.get("total", 0))
	var applied: Array = context.get("applied", [])
	var even_action := str(context.get("even_action", "")).strip_edges()
	var odd_action := str(context.get("odd_action", "")).strip_edges()
	var even_amount: int = int(context.get("even_amount", 0))
	var odd_amount: int = int(context.get("odd_amount", 0))
	var chosen_action := even_action if total % 2 == 0 else odd_action
	var chosen_amount := even_amount if total % 2 == 0 else odd_amount
	if chosen_action.is_empty():
		context["handled"] = true
		return
	var action_context := {
		"main": main,
		"applied": applied
	}
	if chosen_amount > 0:
		action_context["amount"] = chosen_amount
	AbilityRegistry.apply(chosen_action, action_context)
	context["applied"] = action_context.get("applied", applied)
	context["handled"] = true
