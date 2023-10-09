extends Object
class_name AudioJob
enum action {
	START,
	STOP,
	RESTART
}

var audio_action : action
var audio_type : AudioType.type
var fade : bool
var delay_seconds : int

func _init(_audio_action : action, _audio_type : AudioType.type, _fade : bool = false, _delay_seconds : int = 0):
	audio_action = _audio_action
	audio_type = _audio_type
	fade = _fade
	delay_seconds = _delay_seconds
