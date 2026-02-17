extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var converted: bool = main.blue_dice > 0
	if converted:
		main.blue_dice = max(0, int(main.blue_dice) - 1)
		main.green_dice += 1
	else:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Nessun dado blu da convertire in dado veleno."))
	main.dice_count = main.DICE_FLOW.get_total_dice(main)
	if not main.roll_pending_apply and not main.roll_in_progress:
		main.DICE_FLOW.clear_dice_preview(main)
		main.DICE_FLOW.spawn_dice_preview(main)
	var applied: Array = context.get("applied", [])
	if applied != null:
		if converted:
			applied.append("1 dado blu diventa verde")
		else:
			applied.append("Nessuna conversione: non hai dadi blu")
		context["applied"] = applied
	context["handled"] = true
