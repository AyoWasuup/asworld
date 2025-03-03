extends Control
class_name Pause

@onready var game = $"../.."
@onready var map = preload("res://crt_test.tscn")
@export var m: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_new_game_pressed() -> void:
	if not top_level:
		top_level = true
	
	print("Mouse click detected on UI")
	if m != null:
		m.queue_free()
		m = null
	m = map.instantiate()
	game.add_child(m)
	print(m)
	game.new_game_pressed = true
