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
	await get_tree().create_timer(_job.delay_seconds).timeout
	
	var track = audio_table[_job.audio_type]
	
	match(_job.action):
		AudioJob.action.START:
			track.stream = get_audio_stream_from_audio_track(_job.audio_type, track)
			track.play()
		AudioJob.action.STOP:
			if(!_job.fade):
				track.stop()
		AudioJob.action.RESTART:
			track.stop()
			track.play()
			
	if(_job.fade):
		var initial_value = -80.0 if _job.audio_action == AudioJob.action.START || _job.audio_action == AudioJob.action.RESTART else 0.0
		var target_value = 0.0 if initial_value == 80.0 else -80
		var duration_seconds = 2.0
		var timer = 0.0
		while(timer <= duration_seconds):
			track.volume_db = lerpf(initial_value,target_value, timer / duration_seconds)
			timer += get_process_delta_time()
		if(_job.audio_action == AudioJob.action.STOP):
			track.stop()
	job_table.remove(_job.audio_type)
	log_msg(str("Job Count: ",job_table.size()))
	
	
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
