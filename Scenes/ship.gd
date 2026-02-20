extends CharacterBody2D

@onready var ship: AnimatedSprite2D = $Ship
@onready var sail: AnimatedSprite2D = $Sail
@onready var initialposition:float = position.y
@onready var splash: AnimatedSprite2D = %splash

const SPEED:float = 300.0

@export_category("Buoyancy")
@export var amplitude: float = 10.0
@export var frequency: float = 0.5

@export_category("Splash Sprite")
@export_range(10,100) var min_velocity:float = 70.0

var elapsed_time: float = 0.0


func _physics_process(delta: float) -> void:
	elapsed_time += delta

	# Movimiento horizontal basado en la entrada del jugador
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		ship.flip_h = (velocity.x < 0.0)
		sail.flip_h = (velocity.x < 0.0)		
	else:		
		velocity.x = lerp(velocity.x,0.0, delta)
	
	splash.visible = (velocity.length() > min_velocity)
	splash.position.x = 20 if (velocity.x > 0.0) else -20		

	var buoyancy_offset = amplitude * sin(elapsed_time * frequency * TAU)
	position.y = initialposition + buoyancy_offset * delta; 

	move_and_slide()
