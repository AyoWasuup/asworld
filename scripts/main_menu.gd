extends Node3D

func _process(delta: float) -> void:
	#$player_spin.play("spin")
	$player_wip/AnimationPlayer.play("idle")
