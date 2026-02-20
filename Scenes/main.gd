extends Node2D

var stone = preload("res://Scenes/stone.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():		
		var s = stone.instantiate()
		s._initialize(get_global_mouse_position())		
		get_tree().current_scene.add_child(s)
