extends CharacterBody3D
class_name Birdman

enum State {
	THROWING,
	DASHING,
	PAIN,
	SPAWNING,
	DYING,
}

var state = State.DASHING

var start_pos = Vector3.ZERO
var target_pos = Vector3.ZERO
var seen_target = false
var hit_ground = false

@onready var los = $"line of sight"

@export var player: Player

@export var throw_rate = [0,0,0,1]
@export var health = 500
@export var speed = 2000



var current_tic = -1

var spears_thrown = 0

func _ready() -> void:
	start_pos = global_position

func _physics_process(delta: float) -> void:
	match state:
		State.SPAWNING:
			pass
		State.THROWING:
			pass
		State.DASHING:
			if not seen_target and los_valid():
				if not hit_ground:
					target_pos = player.global_position
				else:
					target_pos = Vector3(
						-start_pos.x, start_pos.y, -start_pos.z
					)
				
				look_at(target_pos)
				seen_target = true
			else:
				if global_position == target_pos or is_on_floor():
					if hit_ground:
						pass
					else:
						hit_ground = true
						seen_target = false
				
				var direction = (transform.basis * Vector3(0, 0, 1)).normalized()
				velocity = -(direction * speed * delta)
				print("vel: " + str(velocity))
		State.PAIN:
			pass
		State.DYING:
			pass
	
	move_and_slide()

func los_valid() -> bool:
	if los.is_colliding():
		var c = los.get_collider()
		if c is not Player:
			return false
	
	return true

func finished_state():
	if current_tic == throw_rate.size() - 1:
		current_tic = 0
	else:
		current_tic += 1
	
	if health <= 0:
		state = State.DYING
	else:
		if throw_rate[current_tic] == 1:
			state = State.DASHING
		else:
			state = State.THROWING
