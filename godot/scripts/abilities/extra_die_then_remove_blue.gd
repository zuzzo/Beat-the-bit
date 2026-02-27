extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	if main == null:
		return
	var card: Node3D = context.get("card", null)
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("sacrifice_used", true)
	main.pending_adventure_sacrifice_slot_card = card
	main.pending_adventure_sacrifice_sequence_active = true
	main.pending_adventure_sacrifice_remove_after_roll_count = 0
	main.pending_adventure_sacrifice_remove_choice_count = 1
	main.dice_count = main.DICE_FLOW.get_total_dice(main)
	main._show_drop_half_prompt(main.pending_adventure_sacrifice_remove_choice_count, "sacrifice_remove")
	if main.hand_ui != null and main.hand_ui.has_method("set_info"):
		main.hand_ui.call("set_info", main._ui_text("Approccio alternativo attivo: rimuovi 1 dado e occupa lo slot della carta."))
	context["handled"] = true
