extends Node

## Dictionary that contains relations between scene type and scene path for loading.
## Key must be a valid SceneType.type and Value must be a valid Scene path.
## For example: Assuming SceneType.type.level_1 exists [codeblock] "level_1":"res://scenes/level_1.tscn"[/codeblock]
@export var scene_dict = {}
@export var debug : bool
@export var menu : PageController

var target_scene : SceneType.type
var loading_page : PageType.type
var scene_load_delegate : String # Name of the delegate function that will be called on scene load completion
var scene_is_loading : bool

func current_scene(): return get_tree().get_current_scene()

# Godot Functions
func _ready():
	check_page_controller_integrity()
	log_msg(str("Current Scene: ",current_scene().get_name()))
	log_msg(str("Current Scene Path: ",current_scene().get_path()))
	
# Public Functions
func load_scene(_scene : SceneType.type, _delegate : String = "", reload : bool = false, _loading_page : PageType.type = PageType.type.none):
	if(_loading_page != PageType.type.none && menu != null):
		log_warning("Error loading page: invalid set of parameters - Trying to set up a loading screen but Menu is invalid.")
		return
	if(!scene_can_be_loaded(_scene, reload)):
		log_warning(str("Tried to load scene [",_scene,"] but it cannot be loaded."))
		return
	# Initialization
	scene_is_loading = true
	target_scene = _scene
	loading_page = _loading_page
	scene_load_delegate = _delegate
	var loaded = await wait_for_page_load()
	if(loaded):
		var target_scene_path = scene_type_to_path(target_scene)
		call_deferred("deferred_go_to_scene", target_scene_path)
	
# Private Functions
func deferred_go_to_scene(path):
	get_tree().current_scene.free()
	
	ResourceLoader.load_threaded_request(path)
	var loaded = await wait_for_scene_load(path)
	if(loaded):
		log_msg("[DEBUG] Wait for scene load complete.")

func wait_for_scene_load(path):
	var load_progress = []
	while(ResourceLoader.load_threaded_get_status(path, load_progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS):
		log_msg("Loading..." + load_progress[0])
	var finish_status = ResourceLoader.load_threaded_get_status(path)
	if(finish_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE):
		log_warning(str("Scene: ",path," : INVALID RESOURCE "))
		return true
	elif(finish_status == ResourceLoader.THREAD_LOAD_FAILED):
		log_warning(str("Scene: ",path," : LOAD FAILED "))
		return true
	log_msg(str("Scene ",path," : Resource loaded successfully!"))
	var loaded_scene = ResourceLoader.load_threaded_get(path)
	if(loaded_scene == null):
		log_warning(str("Scene: ",path," : LOAD FAILED. Resource was null!"))
		return true
	var instance = loaded_scene.instantiate()
	instance.scene_loaded.connect(on_scene_loaded)
	get_tree().root.add_child(instance, true)
	get_tree().current_scene = instance # To make it compatible with the SceneTree.change_scene() API.
	return true

func on_scene_loaded(_scene : Node):
	if(target_scene == SceneType.type.none): return # Scene was loaded by a System other than SceneController, don't respond to that
	var scene_type = scene_path_to_type(_scene.get_path())
	if(target_scene != scene_type): return
	
	if(scene_load_delegate != null):
		call(scene_load_delegate)
		
	if(loading_page == PageType.type.none):
		# Hard coded wait for fade out animation duration of loading page
		await get_tree().create_timer(1).timeout 
		menu.turn_page_off(loading_page)
	scene_is_loading = false
	
func wait_for_page_load():
	if(loading_page != PageType.type.none):
		menu.turn_page_on(loading_page)
		while(!menu.page_is_on(loading_page)):
			await get_tree().create_timer(0.01).timeout
	return true

func scene_can_be_loaded(_scene : SceneType.type, reload : bool) -> bool:
	var target_scene_path = scene_type_to_path(_scene) 
	if(target_scene_path == ""):
		log_warning(str("The scene you are trying to load [",SceneType.type.keys()[_scene],"] is not valid."))
		return false
	elif(current_scene().get_path() == target_scene_path && !reload):
		log_msg(str("You are trying to load a scene [",SceneType.type.keys()[_scene],"] which is already active. This specific scene is set to NOT be reloaded."))
		return false
	elif(scene_is_loading):
		log_warning(str("Unable to load scene [",SceneType.type.keys()[_scene],"]. Another scene [",SceneType.type.keys()[target_scene],"] is already loading."))
		return false
	return true

func scene_type_to_path(_scene : SceneType.type):
	var scene_path = scene_dict[SceneType.type.keys()[_scene]]
	if(scene_path == null):
		log_warning(str("The scene you are trying to load [",SceneType.type.keys()[_scene],"] doesn't have a valid associated path."))
		return ""
	return scene_path
	
func scene_path_to_type(_path : String) -> SceneType.type:
	var scene_type = scene_dict.find_key(_path)
	if(scene_type == null):
		log_warning(str("[",_path,"] doesn't have a valid associated Scene Type."))
		return SceneType.type.none
	return scene_type



func check_page_controller_integrity():
	if(menu == null):
		log_warning("Page Controller reference is missing.")

func log_msg(msg):
	if(!debug): return
	print("[SceneController]: ",msg)
	
func log_warning(msg):
	if(!debug): return
	push_warning("[SceneController]: "+msg)
