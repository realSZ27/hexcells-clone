extends Node2D

@onready var root := $"../.."
@onready var touch := $".."

func _input(event: InputEvent) -> void:
	if event is not InputEventScreenTouch or !event.pressed:
		return
		
	root.call("_handle_tile_left_click")
	touch.visible = false
