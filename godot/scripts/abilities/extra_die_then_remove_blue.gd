extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var card: Node3D = context.get("card", null)
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("sacrifice_used", true)
	main.blue_dice += 1
	main.pending_adventure_sacrifice_sequence_active = true
	main.pending_adventure_sacrifice_remove_after_roll_count += 1
	main.pending_adventure_sacrifice_remove_choice_count = 0
	main.dice_count = main.DICE_FLOW.get_total_dice(main)
	if not main.roll_pending_apply and not main.roll_in_progress:
		main.DICE_FLOW.clear_dice_preview(main)
		main.DICE_FLOW.spawn_dice_preview(main)
	if main.hand_ui != null and main.hand_ui.has_method("set_info"):
		main.hand_ui.call("set_info", main._ui_text("Approccio alternativo: +1 dado per questo scontro, poi rimuovi 1 dado a scelta."))
	context["handled"] = true
