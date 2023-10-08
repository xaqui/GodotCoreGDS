extends Control
class_name UI_Page


const FLAG_ON = "On"
const FLAG_OFF = "Off"
const FLAG_NONE = "None"

@export var debug : bool
@export var type : PageType.type
@export var use_animation : bool

var target_state : String

var animation_player : AnimationPlayer;
var is_on : bool

# Godot Functions
func _ready():
	check_animator_integrity()

# Public Functions
func animate(_on : bool):
	if(use_animation):
		if(_on):
			animation_player.play("fadeIn")
		else:
			animation_player.play("fadeOut")
		var ended = await wait_for_animation_end(_on)
		if(ended):
			log_msg(str("Animation finished"))
	else:
		if(!_on):
			visible = false
			is_on = false
		else:
			is_on = true

# Private Functions
func wait_for_animation_end(_on : bool):
	var is_playing = true
	while is_playing:
		is_playing = animation_player.current_animation == ""
		await get_tree().create_timer(1).timeout
	target_state = FLAG_NONE
	
	log_msg(str("Page [",PageType.type.keys()[type],"] finished transitioning to ", "on" if(_on) else "off"))
	
	if(!_on):
		is_on = false
		visible = false
	else:
		is_on = true
	return true

func check_animator_integrity():
	if(use_animation):
		for child in get_children():
			if(child.is_class("AnimationPlayer")):
				animation_player = child
		if(animation_player == null):
			log_warning(str("Using animation for page [",PageType.type.keys()[type],"] but Animator component is missing."))

func log_msg(msg):
	if(!debug): return
	print("[Page]: ",msg)
	
func log_warning(msg):
	if(!debug): return
	push_warning("[Page]: "+msg)
