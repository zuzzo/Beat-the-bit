extends RefCounted
class_name PhaseVisualsCore

static func update_phase_lighting(main: Node, phase_index: int, color_org: Color, color_adv: Color, color_rec: Color) -> void:
	if main.main_light == null:
		return
	var target := color_org
	if phase_index == 1:
		target = color_adv
	elif phase_index == 2:
		target = color_rec
	if main.light_tween != null and main.light_tween.is_valid():
		main.light_tween.kill()
	main.light_tween = main.create_tween()
	main.light_tween.tween_property(main.main_light, "light_color", target, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
