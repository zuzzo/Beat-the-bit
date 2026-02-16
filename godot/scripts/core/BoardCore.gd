extends RefCounted
class_name BoardCore

static func get_top_treasure_card(main: Node) -> Node3D:
	var top_card: Node3D = null
	var top_index := -1
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_stack"):
			continue
		if not child.get_meta("in_treasure_stack", false):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
			top_card = child
	return top_card

static func get_top_adventure_card(main: Node) -> Node3D:
	var top_card: Node3D = null
	var top_index := -1
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_adventure_stack"):
			continue
		if not child.get_meta("in_adventure_stack", false):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
			top_card = child
	return top_card

static func get_top_boss_card(main: Node) -> Node3D:
	var top_card: Node3D = null
	var top_index := -1
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_boss_stack"):
			continue
		if not child.get_meta("in_boss_stack", false):
			continue
		var idx: int = int(child.get_meta("stack_index", -1))
		if idx > top_index:
			top_index = idx
			top_card = child
	return top_card

static func get_top_market_card(main: Node) -> Node3D:
	var top_card: Node3D = null
	var top_y := -INF
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_market"):
			continue
		if not child.get_meta("in_treasure_market", false):
			continue
		var y := (child as Node3D).global_position.y
		if y > top_y:
			top_y = y
			top_card = child
	return top_card

static func get_battlefield_card(main: Node) -> Node3D:
	# Prefer the active blocking card (monster/boss/curse) over chain helpers.
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_battlefield"):
			continue
		if not child.get_meta("in_battlefield", false):
			continue
		if child.has_meta("adventure_blocking") and child.get_meta("adventure_blocking", false):
			return child
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_battlefield"):
			continue
		if not child.get_meta("in_battlefield", false):
			continue
		return child
	return null

static func get_blocking_adventure_card(main: Node) -> Node3D:
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("adventure_blocking"):
			continue
		if not child.get_meta("adventure_blocking", false):
			continue
		return child
	return null

static func reposition_stack(main: Node, meta_key: String, base_pos: Vector3) -> void:
	var cards: Array = []
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta(meta_key):
			continue
		if not child.get_meta(meta_key, false):
			continue
		cards.append(child)
	cards.sort_custom(func(a, b):
		var a_idx := int(a.get_meta("stack_index", -1))
		var b_idx := int(b.get_meta("stack_index", -1))
		return a_idx < b_idx
	)
	for card in cards:
		var idx: int = int(card.get_meta("stack_index", 0))
		var pos := base_pos + Vector3(0.0, idx * main.REVEALED_Y_STEP, 0.0)
		card.global_position = pos

static func reposition_market_stack(main: Node) -> void:
	var cards: Array = []
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("in_treasure_market"):
			continue
		if not child.get_meta("in_treasure_market", false):
			continue
		cards.append(child)
	if cards.is_empty():
		return
	cards.sort_custom(func(a, b):
		if a == null or b == null:
			return false
		var a_idx := int(a.get_meta("market_index", -1))
		var b_idx := int(b.get_meta("market_index", -1))
		if a_idx == -1 or b_idx == -1:
			return (a as Node3D).global_position.y < (b as Node3D).global_position.y
		return a_idx < b_idx
	)
	for i in cards.size():
		var card: Node3D = cards[i]
		if card == null:
			continue
		if int(card.get_meta("market_index", -1)) < 0:
			card.set_meta("market_index", i)
		var pos: Vector3 = main.treasure_reveal_pos + Vector3(0.0, i * main.TREASURE_REVEALED_Y_STEP, 0.0)
		if card.has_meta("sold_from_hand") and bool(card.get_meta("sold_from_hand", false)):
			pos.x -= float(main.CARD_HIT_HALF_SIZE.x) * 2.0
		card.global_position = pos
		card.rotation = Vector3(-PI / 2.0, 0.0, 0.0)

static func reposition_adventure_discard_stack(main: Node) -> void:
	var cards: Array = []
	for child in main.get_children():
		if not (child is Node3D):
			continue
		if not child.has_meta("adventure_discard_index"):
			continue
		cards.append(child)
	if cards.is_empty():
		return
	cards.sort_custom(func(a, b):
		if a == null or b == null:
			return false
		var a_idx := int(a.get_meta("adventure_discard_index", -1))
		var b_idx := int(b.get_meta("adventure_discard_index", -1))
		return a_idx < b_idx
	)
	for i in cards.size():
		var card: Node3D = cards[i]
		card.global_position = main.adventure_discard_pos + Vector3(0.0, i * main.REVEALED_Y_STEP, 0.0)

static func move_adventure_to_discard(main: Node, card: Node3D) -> void:
	if card == null or not is_instance_valid(card):
		return
	card.set_meta("in_battlefield", false)
	card.set_meta("adventure_blocking", false)
	card.set_meta("in_mission_side", false)
	card.set_meta("in_event_row", false)
	card.set_meta("in_adventure_discard", true)
	card.set_meta("adventure_discard_index", main.discarded_adventure_count)
	main.discarded_adventure_count += 1
	card.global_position = main.adventure_discard_pos + Vector3(0.0, (main.discarded_adventure_count - 1) * main.REVEALED_Y_STEP, 0.0)

static func update_treasure_stack_position(main: Node, new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, main.treasure_deck_pos.y, new_pos.z)
	main.treasure_deck_pos = base
	main.treasure_reveal_pos = main.treasure_deck_pos + main.TREASURE_REVEAL_OFFSET
	reposition_stack(main, "in_treasure_stack", main.treasure_deck_pos)
	reposition_market_stack(main)

static func update_adventure_stack_position(main: Node, new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, main.adventure_deck_pos.y, new_pos.z)
	main.adventure_deck_pos = base
	main.adventure_reveal_pos = main.adventure_deck_pos + main.ADVENTURE_REVEAL_OFFSET
	main.adventure_discard_pos = main.adventure_deck_pos + main.ADVENTURE_DISCARD_OFFSET
	reposition_stack(main, "in_adventure_stack", main.adventure_deck_pos)
	reposition_adventure_discard_stack(main)

static func update_boss_stack_position(main: Node, new_pos: Vector3) -> void:
	var base := Vector3(new_pos.x, main.boss_deck_pos.y, new_pos.z)
	main.boss_deck_pos = base + main.BOSS_STACK_OFFSET
	reposition_stack(main, "in_boss_stack", main.boss_deck_pos)
