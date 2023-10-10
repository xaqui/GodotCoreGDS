extends Node
class_name DataController

const DATA_PATH = "user://saves";
const SAVE_FILENAME = "data.sav"
var use_encryption : bool
var game_data : GameData
var file_handler : FileDataHandler

@export var debug : bool

func _ready():
	configure()

# Public Functions
func new_game():
	game_data = GameData.new({})
	log_msg("Created new Game Data.")

func load_game():
	game_data = file_handler.load_data()
	# If no data can be loaded, initialize to new game
	if(game_data == null):
		log_warning("No save data was found. Initializing to defaults.")
		new_game()
	# Push the loaded data to the other scripts
	get_tree().call_group("data_persistance_objects","load_data",game_data)
	log_msg("Loaded Game Gata.")
	log_msg(game_data.data)

func save_game():
	# Pass the data to other scripts so they can update it
	get_tree().call_group("data_persistance_objects","save_data",game_data)
	file_handler.save_data(game_data)
	log_msg("Saved Game Data.")

# Private Functions
func configure():
	file_handler = FileDataHandler.new(DATA_PATH,SAVE_FILENAME, false, debug)

func log_msg(msg):
	if(!debug): return
	print("[DataController]: ",msg)

func log_warning(msg):
	if(!debug): return
	push_warning("[DataController]: "+msg)
