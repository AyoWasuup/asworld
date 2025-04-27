extends Node
class_name Global

var settings = {
	mouse_sens = 1.5,
	volume = 75
}

var zombies_knocked = 0

var frame_counter := 0
var update_frequency := 2

func _process(_delta):
	frame_counter = (frame_counter + 1) % update_frequency
