extends Object
class_name  FileDataHandler

var data_dir_path : String
var data_filename : String
var use_encryption : bool
var debug : bool
var encryption_codeword = "godot"

func _init(_data_dir_path : String, _data_filename : String, _use_encryption : bool, _debug : bool):
	data_dir_path = _data_dir_path
	data_filename = _data_filename
	use_encryption = _use_encryption
	debug = _debug

# Public Functions
func load_data() -> GameData:
	var full_path = data_dir_path+"/"+data_filename
	var data_to_load = ""
	var loaded_data = {}
	
	if not FileAccess.file_exists(full_path):
		return null
	var file := FileAccess.open(full_path, FileAccess.READ_WRITE)
	if(file == null):
		log_error(error_string(FileAccess.get_open_error()))
		return null
	
	data_to_load = file.get_buffer(file.get_length())
	file.close()
	
	if(use_encryption):
		data_to_load = encrypt_decrypt(data_to_load)
	data_to_load = data_to_load.get_string_from_ascii()

	var json = JSON.new()
	var error = json.parse(data_to_load)
	if error == OK:
		loaded_data = json.data
	else:
		log_error(str("JSON Parse Error: ", json.get_error_message(), " in ", data_to_load, " at line ", json.get_error_line()))
		return null
	var return_data = GameData.new(loaded_data)
	if(!return_data.validate_data()):
		return null
	return GameData.new(loaded_data)


func save_data(game_data : GameData):
	var full_path = data_dir_path+"/"+data_filename
	
	if not DirAccess.dir_exists_absolute(data_dir_path):
		log_msg(str("Directory [",data_dir_path,"] does not exist. Creating."))
		DirAccess.make_dir_absolute(data_dir_path)
		
	var data_to_write = JSON.stringify(game_data.data)
	if(use_encryption):
		data_to_write = encrypt_decrypt(data_to_write.to_ascii_buffer())
	
	var file := FileAccess.open(full_path, FileAccess.WRITE_READ)
	if(file == null):
		log_error(error_string(FileAccess.get_open_error()))
		
	if(use_encryption):
		file.store_buffer(data_to_write)
	else:
		file.store_string(data_to_write)
	file.close()

# Private Functions
## XOR encryption
func encrypt_decrypt(data : PackedByteArray) -> PackedByteArray:
	var modified_data = []
	for i in range(data.size()):
		modified_data.append(data[i] ^ encryption_codeword.unicode_at(i%encryption_codeword.length()))
	return PackedByteArray(modified_data)

func log_msg(msg):
	if(debug):
		print("[FileDataHandler]: ",msg)

func log_error(msg):
	if(debug):
		push_error("[FileDataHandler]: "+msg)
