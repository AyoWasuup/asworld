class_name Zombie
extends CharacterBody3D

@export var player: Player
@export var area_node : Node3D
@export var speed: float = 9
@export var accel = 10.0
@export var hit = false
@export var just_died = true
@export var pre_spawn = true
@export var spawn_counter = 0
@export var bone_s : PackedScene

@export var health = 0

@onready var nav_agent = $NavigationAgent3D
var nav_loaded: bool = false

@onready var anim = $zombie_wip/AnimationPlayer
@onready var attack_detect = $"attack range"
@onready var attack_time = $"attack time"
@onready var attack_hit_time = $"attack hit time"
@onready var skeleton = $zombie_wip/Armature/Skeleton3D
@onready var is_up = $respawn_system/is_up
@onready var asleep_time = $"respawn_system/respawn timer"
@onready var asleep_col = $asleep_collision
@onready var awake_col = $awake_collision
@onready var attack_sfx_time = $"attack sfx time"
@onready var bone_spawn = $"bone axis/bone spawn"
@onready var bone_rot = $"bone axis"

enum States {
	CHASING,
	ATTACKING,
	DEAD,
	RESPAWNING
}

var state = States.RESPAWNING

var rng = RandomNumberGenerator.new()

var is_map_ready = false
var already_hit = false
var already_played = false
var dead = false

var res_time_up = true

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	attack_time.wait_time = 2.333 / 1.4
	attack_hit_time.wait_time = 0.9 / 1.4
	attack_sfx_time.wait_time = 0.7 / 1.4

func state_machiene():
	if health <= 0:
		if res_time_up:
			state = States.RESPAWNING
			return
		
		state = States.DEAD
	elif is_player_in_range() or not attack_time.is_stopped():
		state = States.ATTACKING
	else:
		state = States.CHASING

func _physics_process(delta: float) -> void:
	var get_map = NavigationServer3D.map_get_iteration_id(get_world_3d().get_navigation_map())
	if get_map == 0:
		return
	
	if pre_spawn:
		asleep_col.disabled = true
		awake_col.disabled = true
		return
	
	state_machiene()
	
	match state:
		States.CHASING:
			anim.play("zombie run", -1, 1.2)
			dead = false
			res_time_up = false
			var direction = Vector3.ZERO
			if player.global_position == null:
				print("global pos is null")
				return
			nav_agent.target_position = player.global_position
			
			direction = nav_agent.get_next_path_position() - global_position
			direction = direction.normalized()
			
			var play_sound = rng.randi_range(0, 2600.0)
			print(play_sound)
			if play_sound == 1:
				$"idle sfx".play()
			if play_sound == 2:
				$"idle sfx2".play()
			
			velocity = velocity.lerp(direction * speed, accel * delta)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
		States.DEAD:
			anim.stop()
			if !dead:
				GlobalVar.zombies_knocked += 1
				dead = true
			if asleep_time.is_stopped():
				asleep_time.start()
			asleep_col.disabled = false
			awake_col.disabled = true
			velocity.x = 0
			velocity.z = 0
			print(asleep_time.time_left)
			if not is_on_floor():
				velocity.y -= gravity * delta * 10
				print("falling")
		States.RESPAWNING:
			asleep_col.disabled = false
			awake_col.disabled = true
			if not try_awake_collision():
				velocity.y = 8 * delta
				anim.play("zombie scream")
			if spawn_counter != 0:
				$scream.play()
		States.ATTACKING:
			dead = false
			anim.play("zombie punch", -1, 1.4)
			res_time_up = false
			if attack_time.is_stopped():
				attack_time.start()
			if attack_hit_time.is_stopped() and not already_hit:
				attack_hit_time.start()
			if attack_sfx_time.is_stopped() and not already_played:
				attack_sfx_time.start()
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
			velocity = Vector3.ZERO
			print(attack_sfx_time.time_left)
			if not is_on_floor():
				velocity.y -= gravity * delta * 10
				print("falling")
	print(str(state) + str(pre_spawn))
	
	bone_rot.look_at(player.global_position, Vector3.UP)
	
	if not is_on_floor() and state != States.RESPAWNING:
		velocity.y -= gravity * delta * 10
		print("falling")
	
	move_and_slide()
	
	if hit:
		$zombie_wip/Armature/Skeleton3D/HumanMale/blood.emitting = true
		hit = false

func is_player_in_range() -> bool:
	if attack_detect.is_colliding():
		var collision = attack_detect.get_collider()
		if collision == player:
			return true
	
	return false

func is_body_in_range() -> bool:
	if attack_detect.is_colliding():
			return true
	
	return false

func try_awake_collision() -> bool:
	if is_up.is_colliding():
		return false
	
	asleep_col.disabled = true
	awake_col.disabled = false
	health = 300
	res_time_up = true
	return true

func _on_attack_time_timeout() -> void:
	already_hit = false
	already_played = false

func _on_attack_hit_time_timeout() -> void:
	
	
	if is_player_in_range():
		player.health -= 30
		player.got_hit_func()
	already_hit = true
	
	if is_body_in_range():
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

func _on_attack_sfx_time_timeout() -> void:
	$"swing sfx".play()
	already_played = true

func _on_respawn_timer_timeout() -> void:
	spawn_counter += 1
	res_time_up = true
