extends Node

@export var page_controller : PageController

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_U:
			page_controller.turn_page_on(Page_Type.type.loading)
		elif event.pressed and event.keycode == KEY_J:
			page_controller.turn_page_off(Page_Type.type.loading)
		elif event.pressed and event.keycode == KEY_M:
			page_controller.turn_page_off(Page_Type.type.loading, Page_Type.type.menu)
		elif event.pressed and event.keycode == KEY_I:
			page_controller.turn_page_off(Page_Type.type.loading, Page_Type.type.menu, true)
		elif event.pressed and event.keycode == KEY_K:
			# turn off the first completely, then turn on the other
			page_controller.turn_page_off(Page_Type.type.loading, Page_Type.type.test, false)
		elif event.pressed and event.keycode == KEY_COMMA:
			# cross-fade
			page_controller.turn_page_off(Page_Type.type.loading, Page_Type.type.test, true)
