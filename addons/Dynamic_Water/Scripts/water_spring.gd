@tool
extends Node2D
class_name WaterSpring
@onready var area_2d: Area2D = %Area2D
@export_range(0.001,0.02) var motion_factor:float = 0.005
# Spring's current velocity
var velocity = 0
# Force being applied to the spring
var force = 0
# Current height of the spring
var height = 0
# Natural position of the spring
var target_height = 0
var index = 0

signal splash

func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)

# This function aplies the hooke's law force to the spring
# Hooke's law ---> F = -K * x
func water_update(spring_constant, dampening):
	# Update the height value based on our current position
	height = position.y
	# The spring current extension
	var x = height - target_height
	# Dampening force
	var loss  = -dampening * velocity
	# Hooke's law
	force = -spring_constant * x + loss
	# Apply the force to the velocity
	velocity += force
	# Make the spring move
	position.y += velocity
	
func initialize(x_position, id): 
	height = position.y
	target_height = position.y
	velocity = 0
	position.x = x_position
	index = id

func _on_area_2d_body_entered(body: Object) -> void:
	if body is CharacterBody2D:
		var character_body = body as CharacterBody2D
		var speed = -character_body.velocity.length() * motion_factor
		splash.emit(index, speed)
		

	
