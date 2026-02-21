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
	
	# Pick a random edge (0=top, 1=bottom, 2=left, 3=right)
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO
	
	match edge:
		0: spawn_pos = Vector2(randf_range(0, screen_size.x), 0)
		1: spawn_pos = Vector2(randf_range(0, screen_size.x), screen_size.y)
		2: spawn_pos = Vector2(0, randf_range(0, screen_size.y))
		3: spawn_pos = Vector2(screen_size.x, randf_range(0, screen_size.y))
	
	asteroid.position = spawn_pos
	add_child(asteroid)
	current_asteroid = asteroid
	asteroid.destroyed.connect(_on_asteroid_destroyed)

func _on_asteroid_destroyed():
	spawn_asteroid()
