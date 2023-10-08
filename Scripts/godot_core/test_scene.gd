extends Node

@export var scene_controller : SceneController

func _ready():
	scene_controller.scene_loaded.connect(on_scene_loaded)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_O:
			scene_controller.load_scene(SceneType.type.level_2, false, PageType.type.loading)
		elif event.pressed and event.keycode == KEY_L:
			scene_controller.load_scene(SceneType.type.level_1, false)

func on_scene_loaded(scene_type : SceneType.type):
	print(str("Scene [",SceneType.type.keys()[scene_type],"] loaded from test script!"))
