extends Node3D
class_name Pillar

@onready var coll = $Cylinder/StaticBody3D/CollisionShape3D2
@export var player_collision = false

func _ready() -> void:
	coll.disabled = player_collision
