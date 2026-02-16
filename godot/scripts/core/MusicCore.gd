extends RefCounted
class_name MusicCore

static func play_music(main: Node, music_track: AudioStream, battle_track: AudioStream) -> void:
	if music_track == null:
		return
	main.music_player = AudioStreamPlayer.new()
	main.music_player.stream = music_track
	main.music_player.volume_db = -28.0
	main.music_player.bus = "Master"
	main.add_child(main.music_player)
	main.music_player.play()
	main.battle_music_player = AudioStreamPlayer.new()
	main.battle_music_player.stream = battle_track
	main.battle_music_player.volume_db = -80.0
	main.battle_music_player.bus = "Master"
	main.add_child(main.battle_music_player)
	update_phase_music(main, true)

static func update_phase_music(main: Node, immediate: bool = false) -> void:
	if not main.music_enabled:
		return
	var to_battle: bool = (main.phase_index == 1)
	crossfade_music(main, to_battle, immediate)

static func crossfade_music(main: Node, to_battle: bool, immediate: bool = false) -> void:
	if main.music_player == null or main.battle_music_player == null:
		return
	if main.music_fade_tween != null and main.music_fade_tween.is_valid():
		main.music_fade_tween.kill()
	if main.music_delay_timer != null:
		main.music_delay_timer.stop()
	var target_db := -28.0
	var muted_db := -80.0
	if to_battle:
		if immediate:
			if not main.battle_music_player.playing:
				main.battle_music_player.play()
			if not main.music_player.playing:
				main.music_player.play()
			main.battle_music_player.volume_db = target_db
			main.music_player.volume_db = muted_db
			main.music_player.stop()
			return
		if main.music_delay_timer == null:
			main.music_delay_timer = Timer.new()
			main.music_delay_timer.one_shot = true
			main.add_child(main.music_delay_timer)
		var timeout_cb := Callable(main, "_on_battle_music_delay_timeout")
		if not main.music_delay_timer.timeout.is_connected(timeout_cb):
			main.music_delay_timer.timeout.connect(timeout_cb)
		main.music_delay_timer.wait_time = 3.0
		main.music_delay_timer.start()
	else:
		if not main.music_player.playing:
			main.music_player.play()
		if not main.battle_music_player.playing:
			main.battle_music_player.play()
		if immediate:
			main.music_player.volume_db = target_db
			main.battle_music_player.volume_db = muted_db
			main.battle_music_player.stop()
			return
		main.music_fade_tween = main.create_tween()
		main.music_fade_tween.set_parallel(true)
		main.music_fade_tween.tween_property(main.music_player, "volume_db", target_db, 0.8)
		main.music_fade_tween.tween_property(main.battle_music_player, "volume_db", muted_db, 0.8)
		main.music_fade_tween.chain().tween_callback(func() -> void:
			if main.battle_music_player != null:
				main.battle_music_player.stop()
		)

static func toggle_music(main: Node, icon_on: Texture2D, icon_off: Texture2D) -> void:
	if main.music_toggle_button == null:
		return
	main.music_enabled = main.music_toggle_button.button_pressed
	if main.music_enabled:
		main.music_toggle_button.texture_normal = icon_on
		main.music_toggle_button.texture_pressed = icon_on
		main.music_toggle_button.texture_hover = icon_on
		update_phase_music(main)
	else:
		main.music_toggle_button.texture_normal = icon_off
		main.music_toggle_button.texture_pressed = icon_off
		main.music_toggle_button.texture_hover = icon_off
		if main.music_fade_tween != null and main.music_fade_tween.is_valid():
			main.music_fade_tween.kill()
		if main.music_player != null:
			main.music_player.stop()
		if main.battle_music_player != null:
			main.battle_music_player.stop()
