extends RefCounted
class_name CoreUI

static func create_music_toggle(main: Node, ui_layer: CanvasLayer) -> void:
	main.music_toggle_button = TextureButton.new()
	main.music_toggle_button.texture_normal = main.MUSIC_ON_ICON
	main.music_toggle_button.texture_pressed = main.MUSIC_ON_ICON
	main.music_toggle_button.texture_hover = main.MUSIC_ON_ICON
	main.music_toggle_button.toggle_mode = true
	main.music_toggle_button.button_pressed = true
	var size := Vector2(218, 197)
	if main.FIGHT_ICON != null:
		size = main.FIGHT_ICON.get_size()
	size *= 0.1
	main.music_toggle_button.ignore_texture_size = true
	main.music_toggle_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	main.music_toggle_button.custom_minimum_size = size
	main.music_toggle_button.size = size
	main.music_toggle_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	main.music_toggle_button.offset_right = -10.0
	main.music_toggle_button.offset_left = main.music_toggle_button.offset_right - size.x
	main.music_toggle_button.offset_top = 10.0
	main.music_toggle_button.offset_bottom = main.music_toggle_button.offset_top + size.y
	main.music_toggle_button.pressed.connect(main._toggle_music)
	ui_layer.add_child(main.music_toggle_button)

static func position_music_toggle(_main: Node) -> void:
	pass

static func create_coin_total_label(main: Node) -> void:
	main.coin_total_label = Label3D.new()
	main.coin_total_label.font = main.UI_FONT
	main.coin_total_label.font_size = 72
	main.coin_total_label.modulate = Color(1, 1, 1, 1)
	main.coin_total_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	main.coin_total_label.pixel_size = 0.01
	main.coin_total_label.text = "0"
	main.add_child(main.coin_total_label)
	position_coin_total_label(main)

static func position_coin_total_label(main: Node) -> void:
	if main.coin_total_label == null:
		return
	var coins := main.get_tree().get_nodes_in_group("coins")
	if coins.is_empty():
		main.coin_total_label.visible = false
		return
	var min_x := INF
	var max_x := -INF
	var min_z := INF
	var max_z := -INF
	var max_y := 0.0
	for node in coins:
		if not (node is Node3D):
			continue
		var pos := (node as Node3D).global_position
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
		max_y = max(max_y, pos.y)
	if min_x == INF:
		main.coin_total_label.visible = false
		return
	main.coin_total_label.visible = true
	var side_offset: float = 0.32
	var y_level: float = max_y * 0.25
	if y_level < 0.045:
		y_level = 0.045
	var center_z: float = (min_z + max_z) * 0.5
	main.coin_total_label.global_position = Vector3(max_x + side_offset, y_level, center_z)

static func update_coin_total_label(main: Node) -> void:
	if main.coin_total_label == null:
		return
	var count: int = main.get_tree().get_nodes_in_group("coins").size()
	if count <= 0:
		main.coin_total_label.visible = false
		return
	main.coin_total_label.visible = true
	main.coin_total_label.text = "%d" % count
	position_coin_total_label(main)

static func create_adventure_value_box(main: Node, ui_layer: CanvasLayer) -> void:
	main.adventure_value_panel = PanelContainer.new()
	main.adventure_value_panel.visible = false
	main.adventure_value_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	main.adventure_value_panel.z_index = 300
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.08, 0.16, 0.86)
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_color = Color(0.78, 0.90, 1.0, 0.65)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	main.adventure_value_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(main.adventure_value_panel)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set("theme_override_constants/separation", 14)
	main.adventure_value_panel.add_child(row)

	var value_style := StyleBoxFlat.new()
	value_style.bg_color = Color(0.1, 0.2, 0.4, 0.85)
	value_style.border_width_top = 2
	value_style.border_width_bottom = 2
	value_style.border_width_left = 2
	value_style.border_width_right = 2
	value_style.border_color = Color(1, 1, 1, 0.5)

	var monster_panel := PanelContainer.new()
	monster_panel.add_theme_stylebox_override("panel", value_style)
	row.add_child(monster_panel)
	main.adventure_value_label = Label.new()
	main.adventure_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.adventure_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.adventure_value_label.add_theme_font_override("font", main.UI_FONT)
	main.adventure_value_label.add_theme_font_size_override("font_size", 38)
	main.adventure_value_label.add_theme_constant_override("font_spacing/space", 8)
	main.adventure_value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.adventure_value_label.text = main._ui_text("Mostro: -")
	main.adventure_value_label.custom_minimum_size = Vector2(360, 64)
	monster_panel.add_child(main.adventure_value_label)

	main.compare_button = Button.new()
	if main.fight_icon != null:
		main.compare_button.icon = main.fight_icon
	main.compare_button.text = ""
	main.compare_button.expand_icon = true
	main.compare_button.tooltip_text = main._ui_text("Confronta")
	main.compare_button.custom_minimum_size = Vector2(64, 64)
	main.compare_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main.compare_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	main.compare_button.mouse_filter = Control.MOUSE_FILTER_STOP
	main.compare_button.focus_mode = Control.FOCUS_NONE
	main.compare_button.disabled = true
	main.compare_button.pressed.connect(main._on_compare_pressed)
	row.add_child(main.compare_button)

	main.player_value_panel = PanelContainer.new()
	main.player_value_panel.add_theme_stylebox_override("panel", value_style)
	main.player_value_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(main.player_value_panel)
	var player_box := VBoxContainer.new()
	player_box.alignment = BoxContainer.ALIGNMENT_CENTER
	player_box.set("theme_override_constants/separation", 8)
	main.player_value_panel.add_child(player_box)
	main.player_value_label = Label.new()
	main.player_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.player_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.player_value_label.add_theme_font_override("font", main.UI_FONT)
	main.player_value_label.add_theme_font_size_override("font_size", 38)
	main.player_value_label.add_theme_constant_override("font_spacing/space", 8)
	main.player_value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main.player_value_label.text = main._ui_text("Tuo tiro: -")
	main.player_value_label.custom_minimum_size = Vector2(420, 64)
	player_box.add_child(main.player_value_label)
	main.player_dice_buttons_row = HBoxContainer.new()
	main.player_dice_buttons_row.alignment = BoxContainer.ALIGNMENT_CENTER
	main.player_dice_buttons_row.set("theme_override_constants/separation", 6)
	main.player_dice_buttons_row.mouse_filter = Control.MOUSE_FILTER_PASS
	player_box.add_child(main.player_dice_buttons_row)
	center_adventure_value_box(main)

static func center_adventure_value_box(main: Node) -> void:
	if main.adventure_value_panel == null:
		return
	main.adventure_value_panel.custom_minimum_size = Vector2.ZERO
	main.adventure_value_panel.reset_size()
	main.adventure_value_panel.custom_minimum_size = main.adventure_value_panel.get_combined_minimum_size()
	main.adventure_value_panel.reset_size()
	var view_size: Vector2 = main.get_viewport().get_visible_rect().size
	var size: Vector2 = main.adventure_value_panel.size
	main.adventure_value_panel.position = Vector2((view_size.x - size.x) * 0.5, 12.0)

static func create_outcome_banner(main: Node, ui_layer: CanvasLayer) -> void:
	main.outcome_panel = PanelContainer.new()
	main.outcome_panel.visible = false
	main.outcome_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.outcome_panel.z_index = 500
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.85)
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_color = Color(1, 1, 1, 0.6)
	main.outcome_panel.add_theme_stylebox_override("panel", panel_style)
	ui_layer.add_child(main.outcome_panel)

	main.outcome_label = Label.new()
	main.outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main.outcome_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main.outcome_label.add_theme_font_override("font", main.UI_FONT)
	main.outcome_label.add_theme_font_size_override("font_size", 96)
	main.outcome_label.add_theme_constant_override("font_spacing/space", 10)
	main.outcome_label.text = ""
	main.outcome_label.custom_minimum_size = Vector2(900, 180)
	main.outcome_panel.add_child(main.outcome_label)

	center_outcome_banner(main)

static func center_outcome_banner(main: Node) -> void:
	if main.outcome_panel == null:
		return
	main.outcome_panel.custom_minimum_size = Vector2.ZERO
	main.outcome_panel.reset_size()
	main.outcome_panel.custom_minimum_size = main.outcome_panel.get_combined_minimum_size()
	main.outcome_panel.reset_size()
	var view_size: Vector2 = main.get_viewport().get_visible_rect().size
	var size: Vector2 = main.outcome_panel.size
	main.outcome_panel.position = Vector2((view_size.x - size.x) * 0.5, 260.0)
