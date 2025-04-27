extends Node
class_name ZombieRes

@export var try_up_val: float = 8
@export var asleep_col: CollisionShape3D
@export var awake_col: CollisionShape3D
@export var res_time_up: bool
@export var parent_zombie: Node

func try_awake_collision() -> bool:
	if $is_up.is_colliding():
		return false
	
	asleep_col.disabled = true
	awake_col.disabled = false
	res_time_up = true
	return true

func manage_coll(awake: bool, asleep: bool):
	awake_col.disabled = awake
	asleep_col.disabled = asleep

func set_awake_col(disable: bool):
	awake_col.disabled = disable

func set_asleep_col(disable: bool):
	asleep_col.disabled = disable

func _on_respawn_timer_timeout() -> void:
	if parent_zombie.spawn_counter != null:
		parent_zombie.spawn_counter += 1
	res_time_up = true
