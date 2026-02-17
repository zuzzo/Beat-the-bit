extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var main: Node = context.get("main", null)
	var code: String = str(context.get("code", "")).strip_edges()
	if main == null or code.is_empty():
		return
	if not code.begins_with("fail_") or code.find("_hearts_") <= 0:
		return
	var applied: Array = context.get("applied", [])
	var battlefield_hearts: int = int(context.get("battlefield_hearts", -1))
	var split_idx := code.find("_hearts_")
	var head := code.substr(0, split_idx)
	var tail := code.substr(split_idx + len("_hearts_"))
	var required_hearts := int(head.get_slice("_", 1))
	if required_hearts <= 0:
		context["handled"] = true
		return
	if battlefield_hearts != required_hearts:
		context["handled"] = true
		return
	var end_turn := false
	if tail.ends_with("_end_turn"):
		end_turn = true
		tail = tail.substr(0, tail.length() - len("_end_turn"))
	var parts := tail.split("_and_")
	for part_any in parts:
		var part := str(part_any).strip_edges()
		if part.is_empty():
			continue
		if part == "flip_equipment":
			var flip_ctx := {
				"main": main,
				"applied": applied
			}
			AbilityRegistry.apply("flip_equipment", flip_ctx)
			continue
		if part.begins_with("lose_heart"):
			var loss := 1
			if part.begins_with("lose_heart_"):
				loss = max(1, int(part.get_slice("_", 2)))
			var heart_ctx := {
				"main": main,
				"amount": loss,
				"applied": applied
			}
			AbilityRegistry.apply("lose_heart", heart_ctx)
			continue
		if part == "discard_hand_card_1":
			var discard_ctx := {
				"main": main,
				"applied": applied
			}
			AbilityRegistry.apply("discard_hand_card_1", discard_ctx)
			continue
	if end_turn:
		main._force_end_turn_from_failure()
		applied.append("fine turno")
	context["applied"] = applied
	context["handled"] = true
