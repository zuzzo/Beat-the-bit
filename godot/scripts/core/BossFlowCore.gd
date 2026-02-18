extends RefCounted
class_name BossFlowCore

static func reveal_boss_from_regno(main: Node) -> void:
	if main._get_blocking_adventure_card() != null:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("C'e gia un nemico in campo."))
		return
	var boss: Node3D = main._get_top_boss_card() as Node3D
	if boss == null:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Nessun boss disponibile."))
		return
	boss.set_meta("in_boss_stack", false)
	boss.set_meta("in_battlefield", true)
	boss.set_meta("adventure_blocking", true)
	main._set_card_hit_enabled(boss, false)
	var data: Dictionary = boss.get_meta("card_data", {})
	var hearts: int = int(data.get("hearts", 1))
	if hearts < 1:
		hearts = 1
	boss.set_meta("battlefield_hearts", hearts)
	main._spawn_battlefield_hearts(boss, hearts)
	if boss.has_method("set_face_up"):
		boss.call("set_face_up", true)
	if boss.has_method("flip_to_side"):
		var target: Vector3 = main._get_battlefield_target_pos()
		target.x -= (main.CARD_CENTER_X_OFFSET + main.BOSS_X_EXTRA)
		print("BOSS_POS:", target)
		main._debug_card_positions(boss, "BOSS")
		boss.call("flip_to_side", target)

static func claim_boss_to_hand_from_regno(main: Node) -> void:
	var boss: Node3D = main._get_top_boss_card() as Node3D
	if boss == null:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Nessun boss disponibile."))
		return
	var data: Dictionary = boss.get_meta("card_data", {})
	if data.is_empty():
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Boss non valido."))
		boss.queue_free()
		return
	await _animate_boss_claim_to_hand(main, boss, data)
	if main.hand_ui != null and main.hand_ui.has_method("set_info"):
		main.hand_ui.call("set_info", main._ui_text("Boss aggiunto alla mano."))

static func claim_boss_to_hand_from_stack(main: Node) -> void:
	var boss: Node3D = main._get_top_boss_card() as Node3D
	if boss == null:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Nessun boss disponibile."))
		return
	var data: Dictionary = boss.get_meta("card_data", {})
	if data.is_empty():
		boss.queue_free()
		return
	await _animate_boss_claim_to_hand(main, boss, data)

static func _animate_boss_claim_to_hand(main: Node, boss: Node3D, data: Dictionary) -> void:
	if boss == null or not is_instance_valid(boss):
		return
	boss.set_meta("in_boss_stack", false)
	var image_path := str(data.get("image", ""))
	if image_path.is_empty():
		image_path = main._find_boss_image(data)
	var reveal_card: Node3D = main.CARD_SCENE.instantiate()
	main.add_child(reveal_card)
	reveal_card.global_position = boss.global_position
	reveal_card.rotate_x(-PI / 2.0)
	main._set_card_pivot_right_edge(reveal_card)
	reveal_card.set_meta("flip_dir", 1.0)
	reveal_card.set_meta("flip_force_face_up", true)
	if image_path != "" and reveal_card.has_method("set_card_texture"):
		reveal_card.call("set_card_texture", image_path)
	if reveal_card.has_method("set_back_texture"):
		reveal_card.call("set_back_texture", main.BOSS_BACK)
	if reveal_card.has_method("set_face_up"):
		reveal_card.call("set_face_up", false)
	if reveal_card.has_method("set_sorting_offset"):
		reveal_card.call("set_sorting_offset", 999.0)
	var reveal_pos: Vector3 = main.boss_deck_pos + Vector3(1.6, 0.02, 0.0)
	if reveal_card.has_method("flip_to_side"):
		reveal_card.call("flip_to_side", reveal_pos)
		await main.get_tree().create_timer(1.25).timeout
	else:
		reveal_card.global_position = reveal_pos
		await main.get_tree().create_timer(0.2).timeout
	var hand_target: Vector3 = main._get_hand_collect_target()
	var move_tween := main.create_tween()
	move_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(reveal_card, "global_position", hand_target, 0.36)
	await move_tween.finished
	if is_instance_valid(reveal_card):
		reveal_card.queue_free()
	main.player_hand.append(data)
	if is_instance_valid(boss):
		boss.queue_free()
	main._refresh_hand_ui()

static func reveal_final_boss_from_regno(main: Node) -> void:
	if main.regno_final_boss_spawned:
		return
	if main._get_blocking_adventure_card() != null:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("C'e gia un nemico in campo."))
		return
	if CardDatabase.deck_boss_finale.is_empty():
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Boss finale non disponibile."))
		return
	var entry: Dictionary = CardDatabase.deck_boss_finale[0]
	var card: Node3D = main.CARD_SCENE.instantiate() as Node3D
	main.add_child(card)
	card.global_position = main._get_battlefield_target_pos()
	card.global_position.x -= (main.CARD_CENTER_X_OFFSET + main.BOSS_X_EXTRA)
	card.rotate_x(-PI / 2.0)
	card.set_meta("in_battlefield", true)
	card.set_meta("adventure_blocking", true)
	main._set_card_hit_enabled(card, false)
	card.set_meta("card_data", entry)
	var hearts: int = int(entry.get("hearts", 1))
	if hearts < 1:
		hearts = 1
	card.set_meta("battlefield_hearts", hearts)
	main._spawn_battlefield_hearts(card, hearts)
	var image_path := str(entry.get("image", ""))
	if image_path != "" and card.has_method("set_card_texture"):
		card.call_deferred("set_card_texture", image_path)
	if card.has_method("set_back_texture"):
		card.call_deferred("set_back_texture", main.BOSS_BACK)
	if card.has_method("set_face_up"):
		card.call_deferred("set_face_up", true)
	main.regno_final_boss_spawned = true
