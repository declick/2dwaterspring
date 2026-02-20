@tool
extends Node2D

@export_category("Physics")
## Elasticity factor: controls how quickly the spring returns to its original position after being stretched or compressed.
@export var k: float = 0.015
## Damping factor: reduces the speed of the spring's movement over time to prevent it from oscillating indefinitely.
@export var d: float = 0.03
## Spread factor: determines how much a spring's movement affects adjacent springs.
@export var spread: float = 0.5

@export_category("Visuals")
## Total width of the water system
@export var width: int = 300:
	set(value):
		width = value
		update_editor()
## Number of springs: specifies how many springs are in the entire system.
@export var spring_number: int = 7:
	set(value):
		spring_number = value
		update_editor()
## Water depth: controls the total height of the water body in the simulation.
@export var _depth: int = 5:
	set(value):
		_depth = value
		update_editor()

@onready var water_spring = preload("res://addons/Dynamic_Water/Scenes/water_spring.tscn")
@onready var water_polygon: Polygon2D = %Water_Polygon
@onready var water_border: SmoothPath = %Water_Border

var springs: Array[WaterSpring] = []
var passes: int = 8
var target_height: float = 0
var bottom: float = 0
var effective_spread: float
var _script_ready:bool

func _ready() -> void:
	target_height = 0
	bottom = target_height + _depth	
	initialize_springs()
	if Engine.is_editor_hint():
		update_visuals()
	_script_ready = true

func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		calculate_springs()
		update_visuals()

func initialize_springs() -> void:
	clear_springs()
	var springs_gap = float(width) / max(1, (spring_number - 1))	
	for i in range(spring_number):
		var x_position = springs_gap * i
		var w: WaterSpring = water_spring.instantiate()
		add_child(w)
		springs.append(w)
		w.initialize(x_position, i)
		w.splash.connect(splash)

func clear_springs() -> void:
	for spring in springs:
		if spring:
			spring.queue_free()
	springs.clear()

func calculate_springs() -> void:
	effective_spread = spread / 1000.0
	for spring in springs:
		spring.water_update(k, d)

	for i in range(springs.size()):
		var left_neighbor = i - 1
		if left_neighbor >= 0:
			var left_delta = effective_spread * (springs[i].height - springs[left_neighbor].height)
			springs[i].velocity -= left_delta
			springs[left_neighbor].velocity += left_delta

		var right_neighbor = i + 1
		if right_neighbor < springs.size():
			var right_delta = effective_spread * (springs[i].height - springs[right_neighbor].height)
			springs[i].velocity -= right_delta
			springs[right_neighbor].velocity += right_delta

func update_editor() -> void:
	if !_script_ready:
		return
	bottom = target_height + _depth	
	initialize_springs()
	update_visuals()

func update_visuals() -> void:
	new_border()
	draw_water_body()

func new_border() -> void:
	if water_border.curve:
		water_border.curve.clear_points()
	var curve = Curve2D.new()
	for spring in springs:
		curve.add_point(spring.position)
	water_border.curve = curve
	water_border.smooth()
	water_border.queue_redraw()

func draw_water_body() -> void:
	var water_polygon_points = []
	var curve = water_border.curve
	if curve:
		water_polygon_points = Array(curve.get_baked_points()).duplicate()

	if water_polygon_points.size() > 0:
		var last_point = water_polygon_points[water_polygon_points.size() - 1]
		var first_point = water_polygon_points[0]
		water_polygon_points.append(Vector2(last_point.x, bottom))
		water_polygon_points.append(Vector2(first_point.x, bottom))

	water_polygon.polygon = PackedVector2Array(water_polygon_points)

func splash(index: int, speed: float) -> void:
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed
