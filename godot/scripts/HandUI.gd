extends Control

var _hand_bar: HBoxContainer
var _money_label: Label
var _token_label: Label
var _left_panel: PanelContainer
var _right_panel: PanelContainer
var _left_title: Label
var _right_title: Label
var _phase_label: Label
var _turn_label: Label
var _hearts_label: Label
var _cards_label: Label
var _gold_label: Label
var _next_phase_button: Button
var _phase_index := 0
var _turn_index := 1
var _current_hearts := 0
var _max_hearts := 0
var _current_cards := 0
var _max_cards := 0
var _gold := 0
const UI_FONT := preload("res://assets/Font/ARCADECLASSIC.TTF")
const PLAYER_PANEL_FONT_SIZE := 32
var _base_anchor_top := 0.7
var _hover_anchor_top := 0.6
var _dragging_card: Dictionary
var _drag_preview: TextureRect
var _drag_preview_size := Vector2.ZERO
var _hover_overlay: Control
var _hover_preview: TextureRect

signal request_place_equipment(card: Dictionary, screen_pos: Vector2)
signal phase_changed(phase_index: int, turn_index: int)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_right = 0.0
	offset_top = 0.0
	offset_bottom = 0.0
	clip_contents = true
	_create_hand_bar()
	_create_hover_overlay()
	_refresh_player_info()

func _process(_delta: float) -> void:
	if _drag_preview == null:
		return
	var mouse_pos := get_viewport().get_mouse_position()
	_drag_preview.position = mouse_pos - (_drag_preview_size * 0.5)

func _input(event: InputEvent) -> void:
	if _dragging_card.is_empty():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finish_drag()

func populate(hand_cards: Array, card_height: float) -> void:
	if _hand_bar == null:
		return
	for child in _hand_bar.get_children():
		child.queue_free()
	clip_contents = true
	for i in hand_cards.size():
		var card: Dictionary = hand_cards[i]
		var image_path := str(card.get("image", ""))
		var full_size := Vector2(card_height * 0.7, card_height * 2.0)
		var preview_size := Vector2(full_size.x, full_size.y * 0.5)
		var available_width := size.x - (_left_panel.offset_right - _left_panel.offset_left) - (-_right_panel.offset_left)
		var needed_width := preview_size.x * hand_cards.size()
		var overlap := 0.0
		if available_width > 0 and needed_width > available_width:
			overlap = clamp((needed_width - available_width) / max(hand_cards.size() - 1, 1), 0.0, preview_size.x * 0.6)
		var panel := PanelContainer.new()
		panel.custom_minimum_size = preview_size
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.clip_contents = true
		panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		panel.size_flags_vertical = Control.SIZE_SHRINK_END
		panel.z_index = 0
		_hand_bar.set("theme_override_constants/separation", -int(overlap))

		var empty_style := StyleBoxFlat.new()
		empty_style.bg_color = Color(0, 0, 0, 0)
		empty_style.border_width_top = 0
		empty_style.border_width_bottom = 0
		empty_style.border_width_left = 0
		empty_style.border_width_right = 0
		panel.add_theme_stylebox_override("panel", empty_style)

		var tex_rect := TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		tex_rect.set_anchors_preset(Control.PRESET_TOP_LEFT)
		tex_rect.size = full_size
		tex_rect.position = Vector2.ZERO
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if image_path != "":
			tex_rect.texture = load(image_path)
		panel.add_child(tex_rect)

		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0, 0, 0, 0)
		hover_style.border_width_top = 0
		hover_style.border_width_bottom = 0
		hover_style.border_width_left = 0
		hover_style.border_width_right = 0

		panel.mouse_entered.connect(func() -> void:
			panel.add_theme_stylebox_override("panel", hover_style)
			panel.clip_contents = false
			clip_contents = false
			tex_rect.visible = false
			_show_hover_preview(tex_rect.texture, full_size * 1.5, panel)
		)
		panel.mouse_exited.connect(func() -> void:
			panel.add_theme_stylebox_override("panel", empty_style)
			panel.clip_contents = true
			clip_contents = true
			tex_rect.visible = true
			_hide_hover_preview()
		)
		panel.gui_input.connect(func(event: InputEvent) -> void:
			_handle_panel_input(event, card, full_size, tex_rect)
		)
		_hand_bar.add_child(panel)

func set_money(value: int) -> void:
	if _money_label != null:
		_money_label.text = "Monete: %d" % value

func set_tokens(value: int) -> void:
	if _token_label != null:
		_token_label.text = "Token: %d" % value

func set_phase(phase_index: int, turn_index: int) -> void:
	_phase_index = clamp(phase_index, 0, 2)
	_turn_index = max(turn_index, 1)
	_refresh_player_info()
	phase_changed.emit(_phase_index, _turn_index)

func set_hearts(current: int, maximum: int) -> void:
	_current_hearts = max(current, 0)
	_max_hearts = max(maximum, 0)
	_refresh_player_info()

func set_cards(current: int, maximum: int) -> void:
	_current_cards = max(current, 0)
	_max_cards = max(maximum, 0)
	_refresh_player_info()

func set_gold(value: int) -> void:
	_gold = max(value, 0)
	_refresh_player_info()

func _refresh_player_info() -> void:
	var phase_names := ["Organizzazione", "Avventura", "Recupero"]
	if _phase_label != null:
		_phase_label.text = "  Fase di gioco: %s" % phase_names[_phase_index]
	if _turn_label != null:
		_turn_label.text = "  Turno: %d" % _turn_index
	if _hearts_label != null:
		_hearts_label.text = "  Cuori: %d/%d" % [_current_hearts, _max_hearts]
	if _cards_label != null:
		_cards_label.text = "  Carte: %d/%d" % [_current_cards, _max_cards]
	if _gold_label != null:
		_gold_label.text = "  Oro: %d" % _gold

func _apply_ui_font(control: Control) -> void:
	if control == null:
		return
	control.add_theme_font_override("font", UI_FONT)

func _apply_player_panel_font(control: Control) -> void:
	_apply_ui_font(control)
	control.add_theme_font_size_override("font_size", PLAYER_PANEL_FONT_SIZE)

func _advance_phase() -> void:
	_phase_index = (_phase_index + 1) % 3
	if _phase_index == 0:
		_turn_index += 1
	_refresh_player_info()
	phase_changed.emit(_phase_index, _turn_index)

func _handle_panel_input(event: InputEvent, card: Dictionary, full_size: Vector2, tex_rect: TextureRect) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(card, full_size, tex_rect)

func _start_drag(card: Dictionary, full_size: Vector2, tex_rect: TextureRect) -> void:
	_dragging_card = card
	_drag_preview_size = full_size
	if _drag_preview != null:
		_drag_preview.queue_free()
	_drag_preview = TextureRect.new()
	_drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_drag_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_drag_preview.size = full_size
	_drag_preview.z_index = 200
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.texture = tex_rect.texture
	add_child(_drag_preview)
	_drag_preview.position = get_viewport().get_mouse_position() - (_drag_preview_size * 0.5)

func _finish_drag() -> void:
	var screen_pos := get_viewport().get_mouse_position()
	if _drag_preview != null:
		_drag_preview.queue_free()
	_drag_preview = null
	_drag_preview_size = Vector2.ZERO
	request_place_equipment.emit(_dragging_card, screen_pos)
	_dragging_card = {}

func _create_hand_bar() -> void:
	_left_panel = PanelContainer.new()
	_left_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	_left_panel.anchor_left = 0.0
	_left_panel.anchor_right = 0.0
	_left_panel.anchor_top = _base_anchor_top
	_left_panel.anchor_bottom = 1.0
	_left_panel.offset_left = 0.0
	_left_panel.offset_right = 648.0
	_left_panel.offset_top = 0.0
	_left_panel.offset_bottom = 0.0
	_left_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	_left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_panel.size_flags_stretch_ratio = 0.0
	var left_style := StyleBoxFlat.new()
	left_style.bg_color = Color(0, 0, 0, 0.2)
	left_style.border_width_top = 1
	left_style.border_width_bottom = 1
	left_style.border_width_left = 1
	left_style.border_width_right = 1
	left_style.border_color = Color(1, 1, 1, 0.25)
	_left_panel.add_theme_stylebox_override("panel", left_style)
	var left_content := VBoxContainer.new()
	left_content.mouse_filter = Control.MOUSE_FILTER_PASS
	left_content.anchor_left = 0.0
	left_content.anchor_right = 1.0
	left_content.anchor_top = 0.0
	left_content.anchor_bottom = 1.0
	left_content.offset_left = 36.0
	left_content.offset_right = -20.0
	left_content.offset_top = 16.0
	left_content.offset_bottom = -16.0
	left_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_content.set("theme_override_constants/separation", 2)

	_left_title = Label.new()
	_left_title.text = "Giocatore"
	_left_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_ui_font(_left_title)
	_left_title.add_theme_font_size_override("font_size", 30)
	left_content.add_child(_left_title)

	_phase_label = Label.new()
	_turn_label = Label.new()
	_hearts_label = Label.new()
	_cards_label = Label.new()
	_gold_label = Label.new()
	_phase_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hearts_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gold_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hearts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_cards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	left_content.add_child(_phase_label)
	left_content.add_child(_turn_label)
	left_content.add_child(_hearts_label)
	left_content.add_child(_cards_label)
	left_content.add_child(_gold_label)
	_apply_ui_font(_phase_label)
	_apply_player_panel_font(_turn_label)
	_apply_player_panel_font(_hearts_label)
	_apply_player_panel_font(_cards_label)
	_apply_player_panel_font(_gold_label)

	left_content.add_spacer(true)

	_next_phase_button = Button.new()
	_next_phase_button.text = "Fase successiva"
	_next_phase_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_next_phase_button.pressed.connect(_advance_phase)
	_apply_player_panel_font(_next_phase_button)
	left_content.add_child(_next_phase_button)

	_left_panel.add_child(left_content)
	add_child(_left_panel)

	_hand_bar = HBoxContainer.new()
	_hand_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	_hand_bar.anchor_left = 0.0
	_hand_bar.anchor_right = 1.0
	_hand_bar.anchor_top = _base_anchor_top
	_hand_bar.anchor_bottom = 1.0
	_hand_bar.offset_left = 668.0
	_hand_bar.offset_right = -668.0
	_hand_bar.offset_top = 0.0
	_hand_bar.offset_bottom = 0.0
	_hand_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hand_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_hand_bar.size_flags_stretch_ratio = 1.0
	_hand_bar.alignment = BoxContainer.ALIGNMENT_BEGIN
	_hand_bar.set("theme_override_constants/separation", 0)
	add_child(_hand_bar)

	_right_panel = PanelContainer.new()
	_right_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	_right_panel.anchor_left = 1.0
	_right_panel.anchor_right = 1.0
	_right_panel.anchor_top = _base_anchor_top
	_right_panel.anchor_bottom = 1.0
	_right_panel.offset_left = -648.0
	_right_panel.offset_right = 0.0
	_right_panel.offset_top = 0.0
	_right_panel.offset_bottom = 0.0
	_right_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	_right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right_panel.size_flags_stretch_ratio = 0.0
	var right_style := StyleBoxFlat.new()
	right_style.bg_color = Color(0, 0, 0, 0.2)
	right_style.border_width_top = 1
	right_style.border_width_bottom = 1
	right_style.border_width_left = 1
	right_style.border_width_right = 1
	right_style.border_color = Color(1, 1, 1, 0.25)
	_right_panel.add_theme_stylebox_override("panel", right_style)
	_right_title = Label.new()
	_right_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_right_title.text = "Info"
	_right_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_right_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_right_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_right_title.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_ui_font(_right_title)
	_right_title.add_theme_font_size_override("font_size", 30)
	_right_panel.add_child(_right_title)
	add_child(_right_panel)

func _create_hover_overlay() -> void:
	_hover_overlay = Control.new()
	_hover_overlay.anchor_left = 0.0
	_hover_overlay.anchor_right = 1.0
	_hover_overlay.anchor_top = 0.0
	_hover_overlay.anchor_bottom = 1.0
	_hover_overlay.offset_left = 0.0
	_hover_overlay.offset_right = 0.0
	_hover_overlay.offset_top = 0.0
	_hover_overlay.offset_bottom = 0.0
	_hover_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hover_overlay.z_index = 200
	add_child(_hover_overlay)

func _show_hover_preview(texture: Texture2D, size: Vector2, panel: Control) -> void:
	_hide_hover_preview()
	if texture == null or _hover_overlay == null:
		return
	_hover_preview = TextureRect.new()
	_hover_preview.texture = texture
	_hover_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hover_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_hover_preview.size = size
	_hover_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hover_overlay.add_child(_hover_preview)
	var view_h := get_viewport().get_visible_rect().size.y
	var desired_global_y := view_h - size.y + 200.0
	var panel_global := panel.get_global_rect().position
	_hover_preview.position = Vector2(panel_global.x, desired_global_y)

func _hide_hover_preview() -> void:
	if _hover_preview != null:
		_hover_preview.queue_free()
	_hover_preview = null
