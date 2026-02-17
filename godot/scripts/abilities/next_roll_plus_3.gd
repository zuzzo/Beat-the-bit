extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	main.pending_chain_bonus += 3
	main._update_adventure_value_box()
	main._hide_outcome()
	context["handled"] = true
