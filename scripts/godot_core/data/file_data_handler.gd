extends Object
class_name  FileDataHandler

var data_dir_path : String
var data_filename : String
var use_encryption : bool
var encryption_codeword = "godot"

func _init(_data_dir_path : String, _data_filename : String, _use_encryption : bool):
	data_dir_path = _data_dir_path
	data_filename = _data_filename
	use_encryption = _use_encryption

# Public Functions
func load_data() -> GameData:
	var full_path = data_dir_path+"/"+data_filename
	var file := FileAccess.open(full_path, FileAccess.WRITE)
	var data_to_
	if(use_encryption):
		data_to_load = encrypt_decrypt(data_to_load)
	file.close()
	
	var json = JSON.new()
	var error = json.parse(data_to_load)
	if error == OK:
		loaded_data = json.data
	else:
		log_error(str("JSON Parse Error: ", json.get_error_message(), " in ", data_to_load, " at line ", json.get_error_line()))
	return loaded_data

func save_data() -> GameData:
	var full_path = data_dir_path+"/"+data_filename

# Private Functions
func encrypt_decrypt(data : String) -> String:
	var modified_data = ""
	for i in range(data.length()):
		modified_data += str(char(data.unicode_at(i) ^ encryption_codeword.unicode_at(i%encryption_codeword.length())))
	return modified_data
#modifiedData += (char) (data[i] ^ encryptionCodeWord[i % encryptionCodeWord.Length]);


func log_error(msg):
	push_error("[FileDataHandler]: "+msg)
