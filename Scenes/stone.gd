extends CharacterBody2D

var gravity = 3

var max_speed = 450

func _physics_process(_delta: float) -> void:
	velocity.y += gravity
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	move_and_slide()
	
func _initialize(pos): 
	global_position = pos
	
	
