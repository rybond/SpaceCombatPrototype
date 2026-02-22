extends Node2D

const STAR_COLORS = [
	Color(1, 1, 1),
	Color(0.8, 0.85, 1.0),
	Color(0.6, 0.7, 1.0),
	Color(1.0, 0.95, 0.8),
]

var stars = []
var current_asteroid: Node = null

@export var asteroid_scene: PackedScene

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_generate_stars()
	spawn_asteroid()

func _generate_stars():
	stars.clear()
	var screen_size = get_viewport_rect().size
	var area = screen_size.x * screen_size.y
	var count = int(area / 8000.0)
	for i in range(count):
		stars.append({
			"pos": Vector2(randf() * screen_size.x, randf() * screen_size.y),
			"color": STAR_COLORS[randi() % STAR_COLORS.size()],
			"size": randf_range(0.5, 2.0)
		})
	queue_redraw()

func _on_viewport_size_changed():
	_generate_stars()

func _draw():
	for star in stars:
		draw_circle(star.pos, star.size, star.color)

func spawn_asteroid():
	if asteroid_scene == null:
		return
	var asteroid = asteroid_scene.instantiate()
	var screen_size = get_viewport_rect().size
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
