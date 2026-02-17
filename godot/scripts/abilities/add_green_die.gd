extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	main.green_dice += 1
	main.dice_count = main.DICE_FLOW.get_total_dice(main)
	if not main.roll_pending_apply and not main.roll_in_progress:
		main.DICE_FLOW.clear_dice_preview(main)
		main.DICE_FLOW.spawn_dice_preview(main)
	var applied: Array = context.get("applied", [])
	if applied != null:
		applied.append("+1 dado verde")
		context["applied"] = applied
	context["handled"] = true
