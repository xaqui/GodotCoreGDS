extends Node
class_name AudioController

@export var debug : bool
@export var tracks : Array[AudioTrack]

var audio_table = {}

enum action {
	START,
	STOP,
	RESTART
}

# Godot Functions
func _ready():
	configure()
	
# Public Functions
func play_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	run_audio_job(action.START, _type, _fade, delay_seconds)

func stop_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	run_audio_job(action.STOP, _type, _fade, delay_seconds)

func restart_audio(_type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	run_audio_job(action.RESTART, _type, _fade, delay_seconds)

# Private Functions
func configure():
	audio_table = {}
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

func run_audio_job(job_action : action, _type : AudioType.type, _fade : bool = false, delay_seconds : int = 0):
	log_msg(str("Audio Job ",action.keys()[job_action]," ",AudioType.type.keys()[_type]," started. Delay = ",delay_seconds," Fade: ","yes" if _fade else "no"))
	await get_tree().create_timer(delay_seconds).timeout
	var track = audio_table[_type]
	
	match(job_action):
		action.START:
			track.stream = get_audio_stream_from_audio_track(_type, track)
			track.play()
		action.STOP:
			if(!_fade):
				track.stop()
		action.RESTART:
			track.stop()
			track.play()
			
	if(_fade):
		var initial_value = -40.0 if job_action == action.START || job_action == action.RESTART else 0.0
		var target_value = 0.0 if initial_value == -40.0 else -40.0
		var duration_seconds = 2.0
		var timer = 0.0
		while(timer <= duration_seconds):
			track.volume_db = lerpf(initial_value,target_value, timer / duration_seconds)
			await get_tree().create_timer(0.01).timeout
			timer += 0.01
		if(job_action == action.STOP):
			track.stop()
	log_msg(str("Audio Job ",action.keys()[job_action]," ",AudioType.type.keys()[_type]," ended."))

func get_audio_stream_from_audio_track(_type : AudioType.type, _track : AudioTrack) -> AudioStream:
	for audio_obj in _track.audio:
		if(audio_obj.type == _type):
			return audio_obj.audio_stream
	return null

func log_msg(msg):
	if(!debug): return
	print("[AudioController]: ",msg)
	
func log_warning(msg):
	if(!debug): return
	push_warning("[AudioController]: "+msg)
