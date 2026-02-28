extends RefCounted
class_name GoldenAxeDeckSpawn

static func spawn_treasure_cards(main: Node) -> void:
	var treasures: Array = []
	var set_id: String = DeckRegistry.get_card_set(GameConfig.selected_deck_id)
	for entry in CardDatabase.deck_treasures:
		if str(entry.get("set", "")) != set_id:
			continue
		treasures.append(entry)
	main.DECK_UTILS.shuffle_deck(treasures)

	var stack_step: float = main.REVEALED_Y_STEP
	for i in treasures.size():
		var card: Node3D = main.CARD_SCENE.instantiate()
		card.color = Color(0.2, 0.2, 0.4, 1.0)
		main.add_child(card)
		card.global_position = main.treasure_deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_treasure_stack", true)
		card.set_meta("card_data", treasures[i])
		card.set_meta("in_treasure_market", false)
		card.set_meta("stack_index", i)
		var image_path := str(treasures[i].get("image", ""))
		if card.has_method("set_texture_flip_x"):
			card.call_deferred("set_texture_flip_x", true)
		if not image_path.is_empty() and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", main.TREASURE_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

static func spawn_adventure_cards(main: Node) -> void:
	var adventures: Array = []
	var set_id: String = DeckRegistry.get_card_set(GameConfig.selected_deck_id)
	for entry in CardDatabase.deck_adventure:
		if str(entry.get("set", "")) != set_id:
			continue
		adventures.append(entry)
	main.DECK_UTILS.shuffle_deck(adventures)

	var stack_step: float = main.REVEALED_Y_STEP
	for i in adventures.size():
		var card: Node3D = main.CARD_SCENE.instantiate()
		card.color = Color(0.35, 0.15, 0.15, 1.0)
		main.add_child(card)
		card.global_position = main.adventure_deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_adventure_stack", true)
		card.set_meta("card_data", adventures[i])
		card.set_meta("stack_index", i)
		var image_path: String = main._get_adventure_image_path(adventures[i])
		if card.has_method("set_texture_flip_x"):
			card.call_deferred("set_texture_flip_x", true)
		if image_path != "" and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", main.ADVENTURE_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

static func spawn_boss_cards(main: Node) -> void:
	var bosses: Array = []
	var set_id: String = DeckRegistry.get_card_set(GameConfig.selected_deck_id)
	for entry in CardDatabase.deck_boss:
		if str(entry.get("set", "")) != set_id:
			continue
		bosses.append(entry)
	main.DECK_UTILS.shuffle_deck(bosses)

	var stack_step: float = main.REVEALED_Y_STEP
	var deck_pos: Vector3 = main.boss_deck_pos
	for i in bosses.size():
		var card: Node3D = main.CARD_SCENE.instantiate()
		card.color = Color(0.3, 0.2, 0.2, 1.0)
		main.add_child(card)
		card.global_position = deck_pos + Vector3(0.0, i * stack_step, 0.0)
		card.rotate_x(-PI / 2.0)
		card.rotate_y(deg_to_rad(randf_range(-1.0, 1.0)))
		card.rotate_z(deg_to_rad(randf_range(-0.6, 0.6)))
		card.set_meta("in_boss_stack", true)
		card.set_meta("card_data", bosses[i])
		card.set_meta("stack_index", i)
		var image_path := str(bosses[i].get("image", ""))
		if image_path.is_empty():
			image_path = main._find_boss_image(bosses[i])
		if image_path != "" and card.has_method("set_card_texture"):
			card.call_deferred("set_card_texture", image_path)
		if card.has_method("set_back_texture"):
			card.call_deferred("set_back_texture", main.BOSS_BACK)
		if card.has_method("set_face_up"):
			card.call_deferred("set_face_up", false)
		if card.has_method("set_sorting_offset"):
			card.call_deferred("set_sorting_offset", i)

static func spawn_character_card(main: Node) -> void:
	var card: Node3D = main.CARD_SCENE.instantiate()
	main.add_child(card)
	card.global_position = main.character_pos
	card.rotate_x(-PI / 2.0)
	var front_texture: String = main.CHARACTER_FRONT
	if main.active_character_id == "character_sir_arthur_b":
		front_texture = main.CHARACTER_FRONT_B
	if card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", front_texture)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", main.CHARACTER_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	main.character_card = card
	main._init_character_stats()
	main._spawn_character_hearts(card)
	main._spawn_equipment_slots(card)
