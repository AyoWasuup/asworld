extends CharacterBody3D
class_name ThrowZombie

@onready var bone_rot = $"bone axis"
@onready var zombie_res = $ZombieRes
@onready var bone_spawn = $"bone axis/bone spawn"
@onready var nav_agent = $NavigationAgent3D
@onready var run_to = $"run to"
@onready var run_to_ray = $"run to/RayCast3D"

@export var player: Player
@export var bone_s : PackedScene
@export var walk_to_s : PackedScene
@export var health = 300

@export var speed: float = 9
@export var accel = 10.0

@export var id: int = 0

var shots_fire = 3
var area_colliding = false
var can_fire = false
var found_place = false
var fin_anim = true
var target_pos = Vector3.ZERO
var stop_walk = false
var has_walk_to = false

enum States {
	WALK,
	ATTACKING,
	DEAD,
	RESPAWNING
}

var state = States.ATTACKING

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func state_machiene():
	if health <= 0:
		if zombie_res.res_time_up:
			state = States.RESPAWNING
			return
		
		state = States.DEAD
	elif stop_walk:
		state = States.ATTACKING
	else:
		state = States.WALK

func _physics_process(delta: float) -> void:
	var get_map = NavigationServer3D.map_get_iteration_id(get_world_3d().get_navigation_map())
	if get_map == 0:
		print("get map == 0")
		return
	
	bone_rot.look_at(player.global_position, Vector3.UP)
	
	state_machiene()
	
	print("run to shots fire: " + str(shots_fire))
	print("run to state: " + str(state))
	
	if velocity.x != 0 or velocity.z != 0:
		can_fire = false
	else:
		can_fire = true
	
	match state:
		States.ATTACKING:
			$zombie_wip/AnimationPlayer.play("zombie punch")
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			if $throw_timer.is_stopped():
				$throw_timer.start()
			
			print("run to aaaaaaaaa: " + str($throw_timer.time_left))
			velocity = Vector3.ZERO
			
			if shots_fire == 0:
				stop_walk = false
		States.WALK:
			var direction = Vector3.ZERO
			
			if not has_walk_to:
				while not found_place:
					run_to_ray_pro()
					
					if area_colliding:
						run_to_ray_pro()
					
					print("run to area: " + str(area_colliding))
					
					found_place = true
					print("run to pro " + str(run_to.global_position))
			
			look_at(Vector3(target_pos.x, global_position.y, target_pos.z), Vector3.UP)
			nav_agent.target_position = target_pos
			
			direction = nav_agent.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction * speed, accel * delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

func run_to_ray_pro():
	var diffrence = 0
	var rand_x: float
	var rand_z: float
	
	while diffrence < 8:
		rand_x = randf_range(-10, 10)
		print("run to x")
		rand_z = randf_range(-10, 10)
		print("run to z")
		
		diffrence = rand_x + rand_z
	
	var walk_to = walk_to_s.instantiate()
	get_tree().root.add_child(walk_to)
	
	walk_to.global_position = Vector3(
		global_position.x + rand_x, 
		global_position.y, 
		global_position.z + rand_z)
	
	walk_to.id = id
	target_pos = walk_to.global_position

func bone():
	if not can_fire:
		return
	
	var bone = bone_s.instantiate()
	bone.position = bone_spawn.global_position
	bone.transform = bone_spawn.global_transform
	bone.transform.basis.y = bone_spawn.global_transform.basis.y
	
	print(
		  str(transform.basis.x) + " <- x zombie" 
		+ str(transform.basis.y) + " <- y zombie" 
		+ str(transform.basis.z) + " <- z zombie"
	)
	
	print(
		  str(transform.basis.x) + " <- x bone" 
		+ str(transform.basis.y) + " <- y bone" 
		+ str(transform.basis.z) + " <- z bone"
		)
	
	get_tree().root.add_child(bone)
	
	print("rot: " + str(bone.rotation_degrees))
	
	fin_anim = false
	can_fire = false


func _on_navigation_agent_3d_navigation_finished() -> void:
	shots_fire = 3


func _on_throw_timer_timeout() -> void:
	bone()
	shots_fire -= 1
