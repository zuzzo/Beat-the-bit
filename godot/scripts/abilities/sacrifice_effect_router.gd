extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	var card: Node3D = context.get("card", null)
	var effect: String = str(context.get("effect_code", "")).strip_edges().to_lower()
	if main == null:
		return
	if effect.is_empty():
		context["handled"] = true
		return
	if effect == "extra_die_then_remove_blue":
		var sacrifice_context := {
			"main": main,
			"card": card
		}
		AbilityRegistry.apply("extra_die_then_remove_blue", sacrifice_context)
		context["handled"] = bool(sacrifice_context.get("handled", false))
		return
