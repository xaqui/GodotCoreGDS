extends Object
class_name GameData

var data : Dictionary

func _init(_data):
	data = _data
	if(!validate_data()):
		data = initialize_with_defaults()
		
func validate_data() -> bool:
	if(!data.has("counter")):
		return false
	# Check for valid data entries here
	# ...
	return true
	

func initialize_with_defaults() -> Dictionary:
	var intialized_data = {}
	intialized_data["counter"] = 0
	# Custom data to save goes here
	# ...
	return intialized_data
