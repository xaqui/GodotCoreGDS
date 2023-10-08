extends Node

@export var debug : bool
@export var tracks : Array[AudioTrack]

var audio_table = {}
var job_table = {}


# Godot Functions
func _ready():
	configure()
	
# Public Functions
func play_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	add_job(AudioJob.new(AudioJob.action.START, _type, _fade, delay_seconds))

func stop_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	add_job(AudioJob.new(AudioJob.action.STOP, _type, _fade, delay_seconds))

func restart_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	add_job(AudioJob.new(AudioJob.action.RESTART, _type, _fade, delay_seconds))

# Private Functions
func configure():
	audio_table = {}
	job_table = {}
	generate_audio_table()

func generate_audio_table():
	for track in tracks:
		for obj in track.audio:
			# Do not duplicate keys
			if(audio_table.has(obj.type)):
				log_warning(str("Trying to register the same AudioType twice: ",AudioType.type.keys()[obj.type]))
			else:
				audio_table[obj.type] = track
				log_msg(str("Registering audio  [",AudioType.type.keys()[obj.type],"] Success"))

func run_audio_job(_job : AudioJob):
	pass
	
func add_job(_job : AudioJob):
	pass
	
func remove_job(_job : AudioJob):
	pass

func remove_conflicting_jobs(_type : AudioType.type):
	pass
	
func get_audio_stream_from_audio_track(_type : AudioType.type, _track : AudioTrack):
	pass

func log_msg(msg):
	if(!debug): return
	print("[AudioController]: ",msg)
	
func log_warning(msg):
	if(!debug): return
	push_warning("[AudioController]: "+msg)
