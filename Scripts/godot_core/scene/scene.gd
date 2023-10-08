extends Node
class_name GameScene

signal scene_loaded

func _ready():
	self.tree_entered.connect(on_tree_entered)
	
func on_tree_entered():
	scene_loaded.emit(self)
