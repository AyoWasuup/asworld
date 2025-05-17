extends CharacterBody3D

@export var health = 300
@export var hit = false
@onready var health_sign = $Label3D

func _process(delta):
	health_sign.text = str(health)
