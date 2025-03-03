extends Node3D

@export var t : Node3D
@export var tm : Node3D
@export var spin_t : Node3D
@export var hunter_gun_mod : Node3D
@export var camera : Node3D
@export var head_target : Node3D
@export var player_root : Player

@export var look_at_cam = true
@export var spin = false
@export var input_dir = Vector2.ZERO
@export var dodge_dir = Vector2.ZERO

func _process(delta):
	if spin:
		spin_t.rotation_degrees.y += 500 * delta
		print(rotation_degrees.y)
	else:
		spin_t.rotation_degrees.y = 0
	if look_at_cam:
		look_at(Vector3(t.global_position.x, global_position.y, t.global_position.z), Vector3.UP)
		hunter_gun_mod.rotation_degrees.x = -camera.rotation_degrees.x
		head_target.rotation_degrees.x = -camera.rotation_degrees.x / 20
		print(camera.rotation_degrees)
	elif input_dir != Vector2.ZERO:
		look_at(Vector3(tm.global_position.x, global_position.y, tm.global_position.z), Vector3.UP)
	elif player_root.dodge_frame_running:
		look_at(Vector3(tm.global_position.x, global_position.y, tm.global_position.z), Vector3.UP)
	rotation.y -= 185.25
