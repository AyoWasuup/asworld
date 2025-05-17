extends Control
class_name Pause

@onready var game = $"../.."
@onready var map = preload("res://crt_test.tscn")
<<<<<<< HEAD
@onready var boss_map = preload("res://boss_island.tscn")
=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
@export var m: Node

@onready var main_vbox = $VBoxContainer
@onready var main_sprite = $Sprite2D
@onready var options_vbox = $options
@onready var options_bg = $"options background"
@onready var howtoplay = $"how to play"
<<<<<<< HEAD
@onready var level_select = $"level select"
=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe

var path = "res://scripts/save_file.json"

enum ShowMode {
	Main,
	Options,
<<<<<<< HEAD
	HowToPlay,
	LevelSelect,
=======
	HowToPlay
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
}

@export var showstate = ShowMode.Main

func _ready() -> void:
	var json = JSON.new()
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not FileAccess.file_exists(path):
		print("Save file not found. Creating a new one...")
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file:
			GlobalVar.settings = { "mouse_sens": 1.5 }  # Default settings
			file.store_string(JSON.stringify(GlobalVar.settings))
			file.close()
		else:
			print("Error: Could not create save file.")
	else:
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			var result = json.parse(text)
			if result == OK:
				GlobalVar.settings = json.get_data()
			else:
				print("Failed to parse JSON:", json.get_error_message())
		else:
			print("Error: Could not open save file for reading.")


<<<<<<< HEAD

=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
func _process(delta: float) -> void:
	match showstate:
		ShowMode.Main:
			main_vbox.show()
			main_sprite.show()
			options_bg.hide()
			options_vbox.hide()
			howtoplay.hide()
<<<<<<< HEAD
			level_select.hide()
=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
		ShowMode.Options:
			main_vbox.hide()
			main_sprite.hide()
			options_bg.show()
			options_vbox.show()
			howtoplay.hide()
<<<<<<< HEAD
			level_select.hide()
=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
			
			GlobalVar.settings.mouse_sens = $"options/Mouse Sens".value
			var file = FileAccess.open(path, FileAccess.WRITE)
			file.store_line(JSON.stringify(GlobalVar.settings))
		ShowMode.HowToPlay:
			main_vbox.hide()
			main_sprite.hide()
			options_bg.hide()
			options_vbox.hide()
			howtoplay.show()
<<<<<<< HEAD
			level_select.hide()
		ShowMode.LevelSelect:
			main_vbox.hide()
			main_sprite.hide()
			options_bg.hide()
			options_vbox.hide()
			howtoplay.hide()
			level_select.show()

func _on_new_game_pressed() -> void:
	showstate = ShowMode.LevelSelect
=======

func _on_new_game_pressed() -> void:
	if not top_level:
		top_level = true
	
	print("Mouse click detected on UI")
	print(m)
	if m != null:
		delete_map()
	add_map()
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe

func _on_quit_pressed() -> void:
	get_tree().quit()

<<<<<<< HEAD
func add_map(map_ind1: int, map_ind2: int):
	match map_ind2:
		1:
			m = map.instantiate()
		2:
			m = boss_map.instantiate()
=======
func add_map():
	m = map.instantiate()
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
	game.add_child(m)
	print(m)
	game.new_game_pressed = true

func delete_map():
	m.queue_free()
	m = null

func _on_options_pressed() -> void:
	showstate = ShowMode.Options


func _on_controls_pressed() -> void:
	showstate = ShowMode.HowToPlay


func _on_reset_pressed() -> void:
	$"options/Mouse Sens".value = 1.5


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_back_to_menu_pressed() -> void:
	showstate = ShowMode.Main
<<<<<<< HEAD

func _on__pressed() -> void:
	if not top_level:
		top_level = true
	
	print("Mouse click detected on UI")
	print(m)
	if m != null:
		delete_map()
	add_map(1, 1)


func _on_back_pressed() -> void:
	showstate = ShowMode.Main


func _on_boss_pressed() -> void:
	if not top_level:
		top_level = true
	
	print("Mouse click detected on UI")
	print(m)
	if m != null:
		delete_map()
	add_map(1, 2)
=======
>>>>>>> d69bb4954b2b23f6261a7cd43007bc2d0cb3fbfe
