extends Node2D

const STAR_COLORS = [
	Color(1, 1, 1),
	Color(0.8, 0.85, 1.0),
	Color(0.6, 0.7, 1.0),
	Color(1.0, 0.95, 0.8),
]

var stars = []
var active_asteroids: int = 0

@export var jumbo_scene: PackedScene
@export var initial_jumbo_count: int = 5

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_generate_stars()
	spawn_initial_wave()

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

func spawn_initial_wave():
	for i in range(initial_jumbo_count):
		spawn_jumbo()

func spawn_jumbo():
	if jumbo_scene == null:
		return
	var asteroid = jumbo_scene.instantiate()
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
	register_asteroid(asteroid)

# Called by arena (for initial/respawn) AND by asteroid_base.gd (for split children)
func register_asteroid(asteroid: Node):
	active_asteroids += 1
	asteroid.destroyed.connect(_on_asteroid_destroyed)

func _on_asteroid_destroyed():
	active_asteroids -= 1
	if active_asteroids <= 0:
		await get_tree().create_timer(1.5).timeout
		spawn_jumbo()
