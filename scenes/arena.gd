extends Node2D

@export var asteroid_scene: PackedScene

var current_asteroid: Node = null

func _ready():
	spawn_asteroid()

func spawn_asteroid():
	if asteroid_scene == null:
		return
	
	var asteroid = asteroid_scene.instantiate()
	
	var screen_size = get_viewport_rect().size
	
	asteroid.position = Vector2(
		randf_range(100, screen_size.x - 100),
		randf_range(100, screen_size.y - 100)
	)
	
	add_child(asteroid)
	current_asteroid = asteroid
	
	asteroid.destroyed.connect(_on_asteroid_destroyed)

func _on_asteroid_destroyed():
	spawn_asteroid()
