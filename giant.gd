extends CharacterBody3D
class_name Giant

@export var player: Player
@export var speed: float = 9
@export var accel = 10.0
@export var pre_spawn = true

@onready var nav_agent = $NavigationAgent3D
var nav_loaded: bool = false

func _physics_process(delta: float) -> void:
	if pre_spawn:
		$CollisionShape3D.disabled = true
		return
	else:
		$CollisionShape3D.disabled = false
	
	$giant/AnimationPlayer.play("running")
	var direction = Vector3.ZERO
	if player.global_position == null:
		print("global pos is null")
		return
	nav_agent.target_position = player.global_position
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
