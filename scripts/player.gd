class_name Player
extends CharacterBody3D

@export var crosshair: Control

const SPEED = 5.0
const SPRINT_SPEED = 9.0
const JUMP_VELOCITY = 4.5

@export var paused = false

@export var dodge_frame_running = false
var starting_run = true
var stopping_run = false

@export var money = 0

var dodge_dir = Vector3.ZERO
var dodge_model_rot = Vector3.ZERO

var arm_bone_rot = [Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO]

enum States {
	IDLE,
	DODGING,
	SPRINTING,
}

var states = States.IDLE

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var health = 300
var phase_eng = 100

@onready var model = $player_wip
@onready var model_anim = $player_wip/AnimationPlayer
@onready var camera_target = $Camera/CameraTarget
@onready var moving_target = $"Camera/CameraTarget/spin/moving look at"
@onready var look_at = $"Camera/CameraTarget/spin/look at"
@onready var camera = $Camera
@onready var cam_node = $Camera/CameraTarget/SpringArm3D/Camera3D
@onready var gun_hunter = $"Camera/CameraTarget/gun hunter"
@onready var fps_label = $ui/fps
@onready var health_bar = $ui/health
@onready var phase_bar = $ui/phase # TODO: remove feature
@onready var hunter_l = $player_wip/hunter_rot/hunter_l
@onready var hunter_r = $player_wip/hunter_rot/hunter_r
@onready var left_hand_hunter = $"player_wip/Armature/Skeleton3D/hunter lhand ik"
@onready var right_hand_hunter = $"player_wip/Armature/Skeleton3D/hunter rhand ik"
@onready var skeleton = $player_wip/Armature/Skeleton3D
@onready var money_txt = $ui/money
@onready var interact_hand = $Camera/CameraTarget/interact
@onready var plus_money = $ui/crosshair/money
@onready var head_ik = $player_wip/Armature/Skeleton3D/headik

func state_machiene():
	if Input.is_action_pressed("sprint"):
		states = States.SPRINTING
	elif Input.is_action_just_pressed("dodge") or dodge_frame_running and velocity != Vector3.ZERO:
		states = States.DODGING
	else:
		states = States.IDLE

func _physics_process(delta):
	state_machiene()
	
	if paused:
		return
	
	var input_dir = Input.get_vector("strafe_l", "strafe_r", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	rotate_camera_z(input_dir.x)
	
	match states:
		States.IDLE:
			model.look_at_cam = true
			dodge_frame_running = false
			dodge_dir = Vector3.ZERO
			crosshair.show()
			hunter_l.show()
			hunter_r.show()
			left_hand_hunter.start(false)
			right_hand_hunter.start(false)
			head_ik.start()
			
			if Input.is_action_pressed("ads"):
				cam_node.fov = lerpf(cam_node.fov, 40, delta*20)
			else:
				cam_node.fov = lerpf(75, 40, delta * 10)
			
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		States.SPRINTING:
			model.look_at_cam = false
			dodge_frame_running = false
			dodge_dir = Vector3.ZERO
			crosshair.hide()
			hunter_l.hide()
			hunter_r.hide()
			left_hand_hunter.stop()
			right_hand_hunter.stop()
			if direction:
				velocity.x = direction.x * SPRINT_SPEED
				velocity.z = direction.z * SPRINT_SPEED
				
				var input_dir_vec3 = Vector3(input_dir.x, 0, input_dir.y)
				moving_target.position = input_dir_vec3 * -look_at.position.z
			else:
				velocity.x = move_toward(velocity.x, 0, SPRINT_SPEED)
				velocity.z = move_toward(velocity.z, 0, SPRINT_SPEED)
		States.DODGING:
			crosshair.hide()
			hunter_l.hide()
			hunter_r.hide()
			head_ik.stop()
			cam_node.fov = lerpf(75, 40, delta * 10)
			dodge_frame_running = true
			model.look_at_cam = false
			left_hand_hunter.stop()
			right_hand_hunter.stop()
			if dodge_dir == Vector3.ZERO:
				dodge_dir = direction
			velocity.x = dodge_dir.x * SPRINT_SPEED
			velocity.z = dodge_dir.z * SPRINT_SPEED
			moving_target.position = dodge_dir * -look_at.position.z
	
	velocity = velocity.rotated(Vector3.UP, camera_target.rotation.y)
	model.input_dir = input_dir.rotated(camera_target.rotation.y)
	
	var vec2_dodge = Vector2(dodge_dir.x, dodge_dir.z)
	model.dodge_dir = vec2_dodge.rotated(camera_target.rotation.y)
	
	if Input.is_action_just_pressed("boom"):
		velocity.y = velocity.y * 5
		velocity.x = velocity.x * 20
		velocity.z = velocity.z * 20
		
		if is_on_floor():
			velocity.y -= velocity.y * 2
	else:
		if not is_on_floor() or not is_on_wall():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0
	
	var can_jump = is_on_floor() or is_on_wall()
	
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		states = States.SPRINTING
	elif Input.is_action_just_pressed("dodge") or dodge_frame_running:
		states = States.DODGING
	
	move_and_slide()
	
	if velocity.x != 0 or velocity.z != 0:
		if starting_run:
			model_anim.play("to run")
		elif states == States.DODGING:
			model_anim.play("roll")
		else:
			model_anim.play("running")
		stopping_run = true
	else:
		if stopping_run:
			model_anim.play("to idle")
		else:
			model_anim.play("idle")
		starting_run = true
	
	if Input.is_action_just_pressed("shoot1") and states == States.IDLE and hunter_l.can_shoot_v:
		hunter_l.shoot_input = true
		for gun in gun_hunter.get_children():
			if gun.is_colliding():
				var collision = gun.get_collider()
				if collision.is_in_group("enemy"):
					var after_dmg_health = collision.health - 30
					
					if after_dmg_health <= 0 and collision.health > 0:
						money += 10
						plus_money.show()
						$ui/money_idc_timer.start()
					
					collision.health -= 30
					collision.hit = true
	else:
		hunter_l.shoot_input = false
	
	if interact_hand.is_colliding():
		var coll = interact_hand.get_collider()
		if coll is BuyShells and money >= 50:
			$ui/crosshair/interact.show()
		
		if Input.is_action_just_pressed("interact"):
			if coll is BuyShells and money >= 50:
				hunter_l.ammo += 20
				money -= 50
				coll.buy = true
	else:
		$ui/crosshair/interact.hide()
	
	
	
	#fix_sholder_glitch()

func _process(delta):
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	health_bar.value = health
	phase_bar.value = phase_eng
	money_txt.text = str(money) + "\\|"

func got_hit_func():
	$ui/hurt_anim.play("hurt")
	$ui/hurt_sound.play()

func rotate_camera_z(x_move):
	var rot_degrees = 1
	if x_move > 0:
		camera.rotation_degrees.z = rot_degrees
	elif x_move < 0:
		camera.rotation_degrees.z = -rot_degrees
	else:
		camera.rotation_degrees.z = 0

func fix_sholder_glitch():
	var running = false
	for c in skeleton.get_children():
		if c is SkeletonIK3D:
			if c.active:
				running = true
	print(running)
	if not running:
		var rep = 0
		for b in skeleton.get_children():
			if b is BoneAttachment3D:
				arm_bone_rot[rep] = b.rotation_degrees
				rep += 1
	else:
		var rep = 0
		for b in skeleton.get_children():
			if b is BoneAttachment3D:
				b.rotation_degrees = arm_bone_rot[rep]
				print(b.rotation_degrees)
			rep += 1

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "to run" and starting_run:
		starting_run = false
	if anim_name == "to idle" and stopping_run:
		stopping_run = false
	dodge_frame_running = false


func _on_money_idc_timer_timeout() -> void:
	plus_money.hide()
