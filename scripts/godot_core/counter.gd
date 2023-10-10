extends Node


var counter : int = 0
@export var label : Label


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			counter+= 1

func _process(_delta):
	label.set_text(str(counter)) 

# Data Persistance Interface
func load_data(game_data : GameData):
	counter = game_data.data["counter"]

func save_data(game_data : GameData):
	game_data.data["counter"] = counter

