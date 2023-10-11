extends Node
class_name SessionController

@export var debug : bool

var session_start_time_seconds : float
var fps : float :
	get:
		return Engine.get_frames_per_second()
		
func _ready():
	configure()

func configure():
	start_session()
	log_msg(str("Started Session. Session Start time : ",Time.get_datetime_string_from_unix_time(round(session_start_time_seconds))))

func start_session():
	session_start_time_seconds = unix_time_seconds()

func get_session_duration_seconds() -> float:
	var duration_seconds = unix_time_seconds() - session_start_time_seconds
	log_msg(str("Session Duration: ",Time.get_time_dict_from_unix_time(round(duration_seconds))))
	return duration_seconds

func unix_time_seconds() -> float:
	return Time.get_unix_time_from_system()


func log_msg(msg):
	if(!debug): return
	print("[SessionController]: ",msg)

func log_warning(msg):
	if(!debug): return
	push_warning("[SessionController]: "+msg)
