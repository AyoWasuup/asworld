extends Area3D
class_name ThrowZombieWalkTo

@export var id: int = 0

func _on_body_entered(body: Node3D) -> void:
	if body is ThrowZombie:
		if body.id == id:
			body.stop_walk = true
			queue_free()
