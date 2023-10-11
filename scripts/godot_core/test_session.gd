extends Node


@export var session_controller : SessionController


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			print(str("FPS: ",session_controller.fps))
			print(str("Session duration in seconds: ",session_controller.get_session_duration_seconds()))
