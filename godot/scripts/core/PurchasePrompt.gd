extends RefCounted
class_name PurchasePrompt

static func show(main: Node, card: Node3D, require_gold: bool = true) -> bool:
	if main.purchase_panel == null:
		return false
	if card == null or not is_instance_valid(card):
		return false
	var card_data: Dictionary = card.get_meta("card_data", {})
	if card_data.is_empty():
		return false
	var cost := int(card_data.get("cost", 0))
	if cost <= 0:
		return false
	if require_gold and main.player_gold < cost:
		return false
	main.purchase_card = card
	main.purchase_label.text = main._ui_text("Vuoi aggiungerla alla tua mano per il prezzo di %d monete?" % cost)
	main.purchase_panel.visible = true
	resize(main)
	update_position(main)
	return true

static func hide(main: Node) -> void:
	if main.purchase_panel != null:
		main.purchase_panel.visible = false
	main.purchase_card = null

static func update_position(main: Node) -> void:
	if main.purchase_panel == null or not main.purchase_panel.visible:
		return
	if main.purchase_card == null or not is_instance_valid(main.purchase_card):
		hide(main)
		return
	var screen_pos: Vector2 = main.camera.unproject_position(main.purchase_card.global_position)
	var size: Vector2 = main.purchase_panel.size
	main.purchase_panel.position = screen_pos + Vector2(-size.x * 0.5, -size.y - 16.0)

static func resize(main: Node) -> void:
	if main.purchase_panel == null:
		return
	main.purchase_panel.custom_minimum_size = Vector2.ZERO
	main.purchase_panel.reset_size()
	main.purchase_panel.custom_minimum_size = main.purchase_panel.get_combined_minimum_size()
	main.purchase_panel.reset_size()

static func confirm(main: Node) -> void:
	var from_discard := false
	if main.purchase_card != null and is_instance_valid(main.purchase_card):
		from_discard = bool(main.purchase_card.get_meta("in_treasure_discard", false))
	var phase_ok: bool = (main.phase_index == 0) or (from_discard and main.phase_index == 1)
	if not phase_ok:
		hide(main)
		return
	if main.purchase_card == null or not is_instance_valid(main.purchase_card):
		hide(main)
		return
	var card_data: Dictionary = main.purchase_card.get_meta("card_data", {})
	var cost := int(card_data.get("cost", 0))
	if cost <= 0 or main.player_gold < cost:
		hide(main)
		return
	main.player_gold -= cost
	main.player_hand.append(card_data)
	if bool(main.purchase_card.get_meta("in_treasure_market", false)) and main.revealed_treasure_count > 0:
		main.revealed_treasure_count -= 1
	main.purchase_card.queue_free()
	main._refresh_hand_ui()
	if main.hand_ui != null and main.hand_ui.has_method("set_gold"):
		main.hand_ui.call("set_gold", main.player_gold)
	hide(main)
