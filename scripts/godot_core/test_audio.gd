extends Node

@export var audio_controller : AudioController

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_T:
			audio_controller.play_audio(AudioType.type.ST_01, true)
		elif event.pressed and event.keycode == KEY_G:
			audio_controller.stop_audio(AudioType.type.ST_01, true)
			audio_controller.play_audio(AudioType.type.ST_02, true,3)
		elif event.pressed and event.keycode == KEY_B:
			audio_controller.restart_audio(AudioType.type.ST_01, true)
		elif event.pressed and event.keycode == KEY_Y:
			audio_controller.play_audio(AudioType.type.SFX_01)
		elif event.pressed and event.keycode == KEY_H:
			audio_controller.stop_audio(AudioType.type.SFX_01)
		elif event.pressed and event.keycode == KEY_N:
			audio_controller.restart_audio(AudioType.type.SFX_01)
