extends RefCounted
class_name BattlefieldWarning

static func create(main: Node) -> void:
	var prompt_layer := CanvasLayer.new()
	prompt_layer.layer = 11
	main.add_child(prompt_layer)
	main.battlefield_warning_panel = PanelContainer.new()
	main.battlefield_warning_panel.visible = false
	main.battlefield_warning_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	main.battlefield_warning_panel.z_index = 210
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.8)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(1, 1, 1, 0.35)
	main.battlefield_warning_panel.add_theme_stylebox_override("panel", panel_style)
	prompt_layer.add_child(main.battlefield_warning_panel)

	var content := VBoxContainer.new()
	content.anchor_left = 0.0
	content.anchor_right = 1.0
	content.anchor_top = 0.0
	content.anchor_bottom = 1.0
	content.offset_left = 16.0
	content.offset_right = -16.0
	content.offset_top = 12.0
	content.offset_bottom = -12.0
	content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.set("theme_override_constants/separation", 10)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	main.battlefield_warning_panel.add_child(content)

	main.battlefield_warning_label = Label.new()
	main.battlefield_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	main.battlefield_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.battlefield_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.battlefield_warning_label.custom_minimum_size = Vector2(460, 0)
	main.battlefield_warning_label.add_theme_font_override("font", main.UI_FONT)
	main.battlefield_warning_label.add_theme_font_size_override("font_size", main.PURCHASE_FONT_SIZE)
	main.battlefield_warning_label.add_theme_constant_override("font_spacing/space", 8)
	main.battlefield_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.battlefield_warning_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.battlefield_warning_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	content.add_child(main.battlefield_warning_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button_row.set("theme_override_constants/separation", 20)
	main.battlefield_warning_ok = Button.new()
	main.battlefield_warning_ok.text = main._ui_text("Ok")
	main.battlefield_warning_ok.add_theme_font_override("font", main.UI_FONT)
	main.battlefield_warning_ok.add_theme_font_size_override("font_size", main.PURCHASE_FONT_SIZE)
	main.battlefield_warning_ok.add_theme_constant_override("font_spacing/space", 8)
	main.battlefield_warning_ok.pressed.connect(func() -> void:
		hide(main)
	)
	button_row.add_child(main.battlefield_warning_ok)
	content.add_child(button_row)

	center(main)

static func show(main: Node) -> void:
	if main.battlefield_warning_panel == null:
		return
	main.battlefield_warning_label.text = main._ui_text("C'e un nemico nel campo di battaglia.\nSe passi al turno successivo i premi restano sul tavolo e non potrai riscattarli.")
	main.battlefield_warning_panel.visible = true
	center(main)

static func hide(main: Node) -> void:
	if main.battlefield_warning_panel == null:
		return
	main.battlefield_warning_panel.visible = false

static func center(main: Node) -> void:
	if main.battlefield_warning_panel == null:
		return
	main.battlefield_warning_panel.custom_minimum_size = Vector2.ZERO
	main.battlefield_warning_panel.reset_size()
	main.battlefield_warning_panel.custom_minimum_size = main.battlefield_warning_panel.get_combined_minimum_size()
	main.battlefield_warning_panel.reset_size()
	var view_size: Vector2 = main.get_viewport().get_visible_rect().size
	var size: Vector2 = main.battlefield_warning_panel.size
	main.battlefield_warning_panel.position = (view_size - size) * 0.5
