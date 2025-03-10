extends Node3D
class_name Hunter

@export var shoot_input = false
@export var can_shoot_v = true
@export var ammo = 60
@export var ammo_text: RichTextLabel

@export var is_left = false
@export var right_hunter: Hunter

var anim_playing = false

@onready var anim = $AnimationPlayer2
@onready var sfx = $shoot_sfx
@onready var shoot_fx = $Cylinder/shoot

func _ready():
	if is_left and right_hunter == null:
		print("SELECT CORRECT is_left AND right_hunter VAR")

func _physics_process(delta: float) -> void:
	if shoot_input and is_left:
		match can_shoot():
			-1:
				anim_playing = true
				shoot_fx.emitting = true
				anim.play("aaaa")
				sfx.play()
				ammo -= 1
			1:
				right_hunter.anim_playing = true
				right_hunter.shoot_fx.emitting = true
				right_hunter.anim.play("aaaa")
				right_hunter.sfx.play()
				ammo -= 1

func _process(delta: float) -> void:
	if is_left:
		ammo_text.text = "ammo: " + str(ammo)

func can_shoot() -> int:
	if ammo != 0:
		if not anim_playing:
			return -1
		if not right_hunter.anim_playing:
			return 1
	return 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_playing = false
