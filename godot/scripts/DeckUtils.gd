extends Node

static func shuffle_deck(deck: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(deck.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp: Variant = deck[i]
		deck[i] = deck[j]
		deck[j] = temp

static func recycle_discard_if_empty(deck: Array, discard: Array) -> void:
	if deck.is_empty() and not discard.is_empty():
		deck.append_array(discard)
		discard.clear()
		shuffle_deck(deck)

static func draw_until_group(deck: Array, discard: Array, group: String) -> Variant:
	# Draw cards until a matching group is found. Discard all reveals.
	# Assumes each card has a "group" field (Dictionary or Object with group).
	var safety := 0
	while safety < 512:
		recycle_discard_if_empty(deck, discard)
		if deck.is_empty():
			return null
		var card: Variant = deck.pop_back()
		discard.append(card)
		var card_group := ""
		if card is Dictionary:
			card_group = str(card.get("group", ""))
		elif card.has_method("get"):
			card_group = str(card.get("group"))
		if card_group == group:
			return card
		safety += 1
	return null
