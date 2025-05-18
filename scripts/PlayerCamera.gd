extends Node3D

@export var camera_target : Node3D
@export var pitch_max = 50
@export var pitch_min = -50
var yaw = float()
var pitch = float()
var yaw_sensitivity = .002
var pitch_sensitivity = .002

var yaw_sensitivity_c = .102
var pitch_sensitivity_c = .051

const DEADZONE = 0.5

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != 0:
		yaw += -event.relative.x * yaw_sensitivity * GlobalVar.settings.mouse_sens
		pitch += -event.relative.y * pitch_sensitivity * GlobalVar.settings.mouse_sens

func joystick_input():
	var input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	yaw += -input.x * yaw_sensitivity_c
	pitch += -input.y * pitch_sensitivity_c
	
	print("joystick input:" + str(input))

func _process(delta):
	joystick_input()
	
	camera_target.rotation.y = lerpf(camera_target.rotation.y, yaw, delta*10)
	camera_target.rotation.x = lerpf(camera_target.rotation.x, pitch, delta*10)
	
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
