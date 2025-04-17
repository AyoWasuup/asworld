extends Node

var paused = false

@export var new_game_pressed = false

enum GameState {
	Menu,
	Game,
	Dead,
}

var state = GameState.Menu
var player = null

var lasted_until = 0
var highest = 0
var zombies_knocked = 0

@onready var menu = $"main menu"
@onready var menu_player_model = $"main menu/player_wip"
@onready var menu_ui = $"main menu/Control"
@onready var dead_ui = $"main menu/Death"
@onready var pause = $CanvasLayer/Pause
@onready var world_env = $WorldEnvironment

const SAVE_PATH = "user://highscore_asworld-prealpha-0.2dev.cfg"

func state_machiene():
	
	var alive = false
	if find_player():
		if find_player().health <= 0:
			alive = false
			print("player health: " + str(find_player().health))
		else:
			alive = true
	
	if new_game_pressed or alive:
		state = GameState.Game
		if new_game_pressed:
			pause_menu_logic()
			world_env.environment = load("res://town_otd.tres")
			new_game_pressed = false
	elif state != GameState.Menu:
		state = GameState.Dead
		world_env.environment = load("res://main_menu.tres")
		if pause.m != null:
			lasted_until = pause.m.round
			if lasted_until > get_highest():
				highest_updated()
			zombies_knocked = GlobalVar.zombies_knocked
			GlobalVar.zombies_knocked = 0
			pause.delete_map()

func _ready() -> void:
	highest = get_highest()

func _process(delta: float) -> void:
	state_machiene()
	print("pause state: " + str(pause.showstate))
	
	if Input.is_action_just_pressed("pause"):
		if pause.showstate != pause.ShowMode.Main:
			pause.showstate = pause.ShowMode.Main
		else:
			pause_menu_logic()
	
	match state:
		GameState.Game:
			menu.hide()
			menu_player_model.hide()
			menu_ui.hide()
			dead_ui.hide()
		GameState.Menu:
			menu.show()
			menu_player_model.show()
			menu_ui.show()
			dead_ui.hide()
		GameState.Dead:
			menu.show()
			menu_player_model.hide()
			menu_ui.hide()
			dead_ui.show()
			$"main menu/Death/lasted_until".text = str(lasted_until)
			$"main menu/Death/highest".text = str(get_highest())
			$"main menu/Death/zombies_knocked".text = str(zombies_knocked)
	print("state = " + str(state))

func pause_menu_logic():
	print(find_player())
	if paused:
		$CanvasLayer/Pause.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		var children = []
		get_all_children(self, children)
		for i in children:
			i.set_physics_process(true)
			i.set_process(true)
			i.set_process_input(true)
	else:
		$CanvasLayer/Pause.show()
		Engine.time_scale = 0.000001
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#if find_player() != null:
		#	find_player().set_physics_process(false)
		var children = []
		get_all_children(self, children)
		for i in children:
			if i is not Pause and i != self:
				i.set_physics_process(false)
				i.set_process(false)
				i.set_process_input(false)
		
		$CanvasLayer/Pause.set_process(true)
		$CanvasLayer/Pause.set_process_input(true)
		$CanvasLayer/Pause.set_process_unhandled_input(true)
		$CanvasLayer/Pause.set_process_internal(true)
	
	paused = !paused

func find_player() -> Player:
	for w in get_children():
		if w is LevelInst:
			for i in w.get_children():
				for c in i.get_children():
					if c is Player:
						return c
	
	return null

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func highest_updated():
	highest = lasted_until
	var config = ConfigFile.new()
	config.set_value("game_data", "highest_score", highest)
	config.save(SAVE_PATH)
	print("Score saved:", highest)

func get_highest() -> int:
	var config = ConfigFile.new()
	var a = 0
	if config.load(SAVE_PATH) == OK:
		a = config.get_value("game_data", "highest_score", 0)
		print("Score loaded:", a)
	else:
		print("No save file found, starting fresh.")
	return a
