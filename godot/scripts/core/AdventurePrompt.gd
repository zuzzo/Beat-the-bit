extends RefCounted
class_name AdventurePrompt

static func show(main: Node, card: Node3D) -> void:
	if main.adventure_prompt_panel == null:
		return
	main.pending_adventure_card = card
	if main.adventure_prompt_label != null:
		main.adventure_prompt_label.text = main._ui_text("Vuoi intraprendere una nuova avventura?")
	main.adventure_prompt_panel.visible = true
	resize(main)
	update_position(main)

static func hide(main: Node) -> void:
	if main.adventure_prompt_panel != null:
		main.adventure_prompt_panel.visible = false
	main.pending_adventure_card = null

static func confirm(main: Node) -> void:
	if main.pending_adventure_card == null or not is_instance_valid(main.pending_adventure_card):
		hide(main)
		return
	main._confirm_adventure_prompt()

static func resize(main: Node) -> void:
	if main.adventure_prompt_panel == null:
		return
	main.adventure_prompt_panel.custom_minimum_size = Vector2.ZERO
	main.adventure_prompt_panel.reset_size()
	main.adventure_prompt_panel.custom_minimum_size = main.adventure_prompt_panel.get_combined_minimum_size()
	main.adventure_prompt_panel.reset_size()

static func update_position(main: Node) -> void:
	if main.adventure_prompt_panel == null or not main.adventure_prompt_panel.visible:
		return
	if main.pending_adventure_card == null or not is_instance_valid(main.pending_adventure_card):
		hide(main)
		return
	var screen_pos: Vector2 = main.camera.unproject_position(main.pending_adventure_card.global_position)
	var size: Vector2 = main.adventure_prompt_panel.size
	main.adventure_prompt_panel.position = screen_pos + Vector2(-size.x * 0.5, -size.y - 16.0)
