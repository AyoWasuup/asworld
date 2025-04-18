extends CharacterBody3D
class_name Birdman

enum State {
	THROWING,
	DASHING,
	PAIN,
	SPAWNING,
	DYING
}

var state = State.SPAWNING

@export var health = 500
@export var throw_rate = [0,0,0,1]
var current_tic = -1

var spears_thrown = 0

func _physics_process(delta: float) -> void:
	match state:
		State.SPAWNING:
			pass
		State.THROWING:
			pass
		State.DASHING:
			pass
		State.PAIN:
			pass
		State.DYING:
			pass

func finished_state():
	if current_tic == throw_rate.size() - 1:
		current_tic = 0
	else:
		current_tic += 1
	
	if health <= 0:
		state = State.DYING
	else:
		if spears_thrown == throw_rate[current_tic]:
			state = State.DASHING
		else:
			state = State.THROWING
