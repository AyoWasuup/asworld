class_name BoneProjct
extends RigidBody3D

const SPEED = 5.0
@export var dir_y : float
@onready var anim = $AnimationPlayer

var on_top = false

func _ready() -> void:
	$split_time.start()

func _physics_process(delta: float) -> void:
	anim.play("spin")
	apply_impulse(-transform.basis.z * SPEED, -transform.basis.z)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var direction := (global_transform.basis * Vector3(0, 0, 1)).normalized()
	#apply_central_force(direction * -SPEED)

func _on_split_time_timeout() -> void:
	on_top = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health -= 30
		body.got_hit_func()
		queue_free()
	
	if body is BoneProjct:
		return
	elif body is Zombie:
		return
	
	if body is not BoneProjct or body is not Zombie:
		print("bone died to: " + str(body))
		queue_free()


func _on_alive_time_timeout() -> void:
	queue_free()
