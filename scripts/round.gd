class_name RoundSys
extends Timer

@export var level_node: Node
@export var round = 1
var player_ui_node: RoundLabel

func _ready() -> void:
	for c in level_node.get_children():
		if c is Player:
			for pc in c.get_children():
				if pc is Control:
					for pcc in pc.get_children():
						if pcc is RoundLabel:
							player_ui_node = pcc

func _on_timeout() -> void:
	round += 1
	player_ui_node.text = str(round)
