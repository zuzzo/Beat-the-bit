extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	var effect_name := str(context.get("effect_name", "")).strip_edges()
	if main == null or effect_name.is_empty():
		return
	if effect_name == "next_roll_plus_3":
		var plus_context := {
			"main": main
		}
		AbilityRegistry.apply("next_roll_plus_3", plus_context)
		context["handled"] = true
		return
	if effect_name == "reveal_2_keep_1":
		var reveal_context := {
			"main": main
		}
		AbilityRegistry.apply("reveal_2_keep_1", reveal_context)
		context["handled"] = true
		return
