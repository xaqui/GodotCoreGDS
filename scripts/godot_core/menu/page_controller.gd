extends Node
class_name PageController

@export var debug : bool
@export var entry_page : PageType.type
@export var pages : Array[UI_Page]

var page_dict

# Godot Functions
func _ready():
	page_dict = {}
	register_all_pages()
	if(entry_page == PageType.type.none):
		turn_page_on(entry_page)

# Public Functions
func turn_page_on(_type : PageType.type):
	if(_type == PageType.type.none): return
	if(!page_exists(_type)):
		log_warning(str("Trying to turn on page not registered: ",PageType.type.keys()[_type]))
		return
	var _page = get_page(_type)
	_page.visible = true
	_page.animate(true)
	log_msg(str("Turned Page on: ", PageType.type.keys()[_type]))

func turn_page_off(_off : PageType.type, _on = PageType.type.none, wait_for_exit = false):
	if(_off == PageType.type.none): return
	if(!page_exists(_off)):
		log_warning(str("Trying to turn off page not registered: ",PageType.type.keys()[_off]))
		return
	var _off_page = get_page(_off)
	if(_off_page.visible):
		_off_page.animate(false)
			
	if(_on != PageType.type.none):
		if(wait_for_exit):
			var _on_page = get_page(_on)
			var exited = await wait_for_page_exit(_on_page,_off_page)
			if(exited):
				log_msg(str("Page exit finished. Went from ",PageType.type.keys()[_off_page.type]," to ",PageType.type.keys()[_on_page.type]))
		else:
			turn_page_on(_on)

func page_is_on(_type : PageType.type):
	if(!page_exists(_type)):
		log_warning(str("You are trying to detect if a page is on [",PageType.type.keys()[_type],"], but it has not been registered."))
		return
	return get_page(_type).is_on

# Private Functions
func wait_for_page_exit(_on : UI_Page, _off : UI_Page):
	var exited = false
	while(!exited):
		exited = _off.target_state == UI_Page.FLAG_NONE
		await get_tree().create_timer(0.01).timeout
	turn_page_on(_on.type)
	return exited

func register_all_pages():
	for page in pages:
		register_page(page)
	
func register_page(_page : UI_Page):
	if(page_exists(_page.type)):
		log_msg(str("Trying to register a page [",PageType.type.keys()[_page.type],"] that has already been registered: ",_page.get_name()))
		return
	page_dict[_page.type] = _page
	log_msg(str("Registered new page successfully: ",PageType.type.keys()[_page.type]))

func get_page(_type : PageType.type):
	if(!page_exists(_type)):
		log_msg(str("Trying to get a page that has not been registered: ",PageType.type.keys()[_type]))
		return null
	return page_dict[_type]

func page_exists(_type : PageType.type) -> bool:
	return page_dict.has(_type)

func log_msg(msg):
	if(!debug): return
	print("[PageController]: ",msg)
	
func log_warning(msg):
	if(!debug): return
	push_warning("[PageController]: "+msg)
