extends "res://scripts/abilities/AbilityBase.gd"

func apply(context: Dictionary) -> void:
	var deck: Array = context.get("deck_treasures", [])
	var hand: Array = context.get("hand", [])
	var matches: Array[int] = []
	for i in deck.size():
		var card: Dictionary = deck[i]
		if str(card.get("group", "")) == "vaso_di_coccio":
			matches.append(i)
	if matches.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var pick_index := matches[rng.randi_range(0, matches.size() - 1)]
	var picked_card: Dictionary = deck[pick_index]
	hand.append(picked_card)
	deck.remove_at(pick_index)
	context["hand"] = hand
	context["deck_treasures"] = deck
