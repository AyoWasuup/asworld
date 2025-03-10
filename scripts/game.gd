extends Node

var paused = false

@export var new_game_pressed = false

enum GameState {
	Menu,
	Game,
	Dead
}

var state = GameState.Menu

@onready var menu = $"main menu"
@onready var menu_ui = $"main menu/Control"
@onready var pause = $CanvasLayer/Pause
@onready var world_env = $WorldEnvironment

func state_machiene():
	if new_game_pressed:
		state = GameState.Game
		pause_menu_logic()
		world_env.environment = load("res://town_otd.tres")
		new_game_pressed = false

func _process(delta: float) -> void:
	state_machiene()
	
	if Input.is_action_just_pressed("pause"):
		pause_menu_logic()
	
	if state == GameState.Game:
		menu.hide()
		menu_ui.hide()

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
