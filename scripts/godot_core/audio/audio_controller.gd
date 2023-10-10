extends Node
class_name AudioController

@export var debug : bool
@export var tracks : Array[AudioTrack]

var audio_table = {}
var job_list = []


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
	job_list = []
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
	log_msg("RUN JOB")
	await get_tree().create_timer(_job.delay_seconds).timeout
	var track = audio_table[_job.audio_type]
	
	match(_job.audio_action):
		AudioJob.action.START:
			track.stream = get_audio_stream_from_audio_track(_job.audio_type, track)
			track.play()
			print(track)
		AudioJob.action.STOP:
			if(!_job.fade):
				track.stop()
		AudioJob.action.RESTART:
			track.stop()
			track.play()
			
	if(_job.fade):
		var initial_value = -80.0 if _job.audio_action == AudioJob.action.START || _job.audio_action == AudioJob.action.RESTART else 0.0
		var target_value = 0.0 if initial_value == -80.0 else -80.0
		var duration_seconds = 2.0
		var timer = 0.0
		print(initial_value)
		print(target_value)
		while(timer <= duration_seconds):
			track.volume_db = lerpf(initial_value,target_value, timer / duration_seconds)
			await get_tree().create_timer(0.01).timeout
			timer += 0.01
		if(_job.audio_action == AudioJob.action.STOP):
			track.stop()
	job_list.erase(_job.audio_type)
	log_msg(str("Job Count: ",job_list.size()))


func add_job(_job : AudioJob):
	remove_conflicting_jobs(_job.audio_type)
	run_audio_job(_job)
	job_list.append(_job.audio_type)
	log_msg(str("Starting job on [",AudioType.type.keys()[_job.audio_type],"] with the operation: ",AudioJob.action.keys()[_job.audio_action]))
	

func remove_job(_type : AudioType.type):
	if(!job_list.has(_type)):
		log_msg(str("Trying to remove a Job [",AudioType.type.keys()[_type],"] that is not running"))
		return
	job_list.erase(_type)
	log_msg(str("Removed job of type ",AudioType.type.keys()[_type]))
	

func remove_conflicting_jobs(_type : AudioType.type):
	# Same audio type
	if(job_list.has(_type)):
		log_msg(str("Removed conflicting job ",AudioType.type.keys()[_type]," - same audio type"))
	# Same audio source
	var conflicted_audio = AudioType.type.none
	for entry in job_list:
		var _audio_type = entry
		var _audio_track_in_use = audio_table[_audio_type]
		var _audio_tack_needed = audio_table[_type]
		if(_audio_tack_needed == _audio_track_in_use):
			# We have a conflict
			conflicted_audio |= _audio_type
	if(conflicted_audio != AudioType.type.none):
		remove_job(conflicted_audio)
		log_msg(str("Removed conflicting job ",AudioType.type.keys()[_type]," - same audio source"))
	
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
