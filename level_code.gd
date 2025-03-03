class_name LevelInst
extends Node

@export var zombie_node_tree: Array[Node3D]
@export var round_node: Timer
@export var level_node: Node3D
var round = 1
var start_done = false

var player_ui_node: RoundLabel

func get_player_ui_node():
	for c in level_node.get_children():
		if c is Player:
			for pc in c.get_children():
				if pc is Control:
					for pcc in pc.get_children():
						if pcc is RoundLabel:
							player_ui_node = pcc

func _process(delta: float) -> void:
	if round_node == null or level_node == null:
		return
	elif not start_done:
		update_round()
		start_done = true
	
	if player_ui_node == null:
		get_player_ui_node()

func update_round():
	var arr_round = round - 1
	zombie_node_tree[arr_round].show()
	print(zombie_node_tree[arr_round])
	print("shown")
	for node in zombie_node_tree[arr_round].get_children():
		print(zombie_node_tree[arr_round])
		print('iter...')
		if node is Zombie:
			print("respawning")
			node.pre_spawn = false
			print(node.state)

func _on_round_timeout() -> void:
	round += 1
	if round - 1 < zombie_node_tree.size():
		update_round()
	player_ui_node.text = str(round)
