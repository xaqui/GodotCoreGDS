extends Node

@export var data_controller : DataController

func _ready():
	data_controller.load_game()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_W:
			data_controller.save_game()
		elif event.pressed and event.keycode == KEY_S:
			data_controller.load_game()

