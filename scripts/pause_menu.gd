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
	print(m)
	if m != null:
		delete_map()
	add_map()

func _on_quit_pressed() -> void:
	get_tree().quit()

func add_map():
	m = map.instantiate()
	game.add_child(m)
	print(m)
	game.new_game_pressed = true

func delete_map():
	m.queue_free()
	m = null
