extends RefCounted
class_name CardTiming

static func is_card_activation_allowed_now(main: Node, card_data: Dictionary) -> bool:
	if main.phase_index != 1:
		return false
	if main.roll_in_progress:
		return false
	var action_window := get_current_card_action_window(main, card_data)
	if action_window.is_empty():
		return false
	var effects := get_effects_for_window(card_data, action_window)
	return not effects.is_empty()

static func get_current_card_action_window(main: Node, card_data: Dictionary) -> String:
	var windows := get_card_activation_windows(card_data)
	var battlefield: Node3D = main._get_battlefield_card()
	if battlefield == null:
		if windows.has("before_adventure") and main._get_top_adventure_card() != null:
			return "before_adventure"
		if windows.has("any_time"):
			return "any_time"
		if windows.has("on_play"):
			return "on_play"
		return ""
	if main.roll_pending_apply:
		if windows.has("after_roll"):
			return "after_roll"
		if windows.has("after_damage"):
			return "after_damage"
		if windows.has("any_time"):
			return "any_time"
		return ""
	if windows.has("before_adventure"):
		return "before_adventure"
	if windows.has("before_roll") or windows.has("next_roll"):
		return "before_roll"
	if windows.has("any_time"):
		return "any_time"
	if windows.has("on_play"):
		return "on_play"
	return ""

static func get_effects_for_window(card_data: Dictionary, action_window: String) -> Array:
	var out: Array = []
	var timed_effects: Array = card_data.get("timed_effects", [])
	if timed_effects.is_empty():
		return card_data.get("effects", []).duplicate()
	for entry in timed_effects:
		if not (entry is Dictionary):
			continue
		var data := entry as Dictionary
		var effect_name := str(data.get("effect", "")).strip_edges()
		var when := str(data.get("when", "")).strip_edges().to_lower()
		if effect_name.is_empty():
			continue
		var matches := (when == action_window)
		if action_window == "before_roll" and when == "next_roll":
			matches = true
		if not matches:
			continue
		if not out.has(effect_name):
			out.append(effect_name)
	return out

static func get_card_activation_windows(card_data: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var timed_effects: Array = card_data.get("timed_effects", [])
	for entry in timed_effects:
		if not (entry is Dictionary):
			continue
		var when := str((entry as Dictionary).get("when", "")).strip_edges().to_lower()
		if when.is_empty():
			continue
		if not out.has(when):
			out.append(when)
	if out.is_empty():
		out.append("after_roll")
	return out

static func show_card_timing_hint(main: Node, card_data: Dictionary) -> void:
	if main.hand_ui == null or not main.hand_ui.has_method("set_info"):
		return
	var name := str(card_data.get("name", "Carta"))
	var windows := get_card_activation_windows(card_data)
	var readable := " / ".join(windows)
	main.hand_ui.call("set_info", main._ui_text("%s: attivabile in %s." % [name, readable]))
