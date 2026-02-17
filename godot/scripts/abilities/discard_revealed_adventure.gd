extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var battlefield: Node3D = main._get_battlefield_card()
	if battlefield != null:
		var data: Dictionary = battlefield.get_meta("card_data", {})
		var ctype := str(data.get("type", "")).strip_edges().to_lower()
		main._move_adventure_to_discard(battlefield)
		if ctype != "concatenamento":
			main._cleanup_chain_cards_after_victory()
		context["handled"] = true
		return
	var top: Node3D = main._get_top_adventure_card()
	if top == null:
		context["handled"] = true
		return
	top.set_meta("in_adventure_stack", false)
	main._move_adventure_to_discard(top)
	context["handled"] = true
