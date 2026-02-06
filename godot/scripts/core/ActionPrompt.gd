extends RefCounted
class_name ActionPrompt

static func show(main: Node, card_data: Dictionary, is_magic: bool, source_card: Node3D = null) -> void:
	var action_window := CardTiming.get_current_card_action_window(main, card_data)
	var effects := CardTiming.get_effects_for_window(card_data, action_window)
	if effects.has("after_roll_set_one_die_to_1") and main.roll_pending_apply:
		if main.hand_ui != null and main.hand_ui.has_method("set_info"):
			main.hand_ui.call("set_info", main._ui_text("Seleziona 1 dado da impostare a 1 e poi conferma."))
	var name := str(card_data.get("name", "Carta"))
	if main.action_prompt_label != null:
		main.action_prompt_label.text = main._ui_text("Vuoi usare %s?" % name)
	main.action_prompt_panel.visible = true
	center(main)
	main.pending_action_card_data = card_data
	main.pending_action_is_magic = is_magic
	main.pending_action_source_card = source_card

static func hide(main: Node) -> void:
	if main.action_prompt_panel != null:
		main.action_prompt_panel.visible = false
	main.pending_action_card_data = {}
	main.pending_action_is_magic = false
	main.pending_action_source_card = null

static func center(main: Node) -> void:
	if main.action_prompt_panel == null:
		return
	main.action_prompt_panel.custom_minimum_size = Vector2.ZERO
	main.action_prompt_panel.reset_size()
	main.action_prompt_panel.custom_minimum_size = main.action_prompt_panel.get_combined_minimum_size()
	main.action_prompt_panel.reset_size()
	var view_size: Vector2 = main.get_viewport().get_visible_rect().size
	var size: Vector2 = main.action_prompt_panel.size
	main.action_prompt_panel.position = (view_size - size) * 0.5

static func confirm(main: Node) -> void:
	if main.pending_action_card_data.is_empty():
		hide(main)
		return
	var action_window := CardTiming.get_current_card_action_window(main, main.pending_action_card_data)
	var effects := CardTiming.get_effects_for_window(main.pending_action_card_data, action_window)
	if effects.is_empty():
		hide(main)
		return
	if not main._validate_roll_selection_for_effects(effects):
		hide(main)
		return
	main._use_card_effects(main.pending_action_card_data, effects, action_window)
	if not main.pending_action_is_magic and main.pending_action_source_card != null and is_instance_valid(main.pending_action_source_card):
		if effects.has("return_to_hand"):
			main._force_return_equipped_to_hand(main.pending_action_source_card)
	if main.pending_action_is_magic:
		if not effects.has("return_to_hand"):
			main.player_hand.erase(main.pending_action_card_data)
			main._refresh_hand_ui()
	hide(main)
