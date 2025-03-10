class_name BuyShells
extends Node3D

@onready var anim = $"../../AnimationPlayer"

@export var buy = false

func _process(delta: float) -> void:
	anim.play("spin")
	if buy:
		$"../../cha ching".play()
		buy = false
