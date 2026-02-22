extends Area2D

signal destroyed

@export var min_speed: float = 50.0
@export var max_speed: float = 250.0
@export var min_rotation_speed: float = 0.5
@export var max_rotation_speed: float = 2.0

var velocity: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.0

@onready var health_component: HealthComponent = $HealthComponent

func _ready():
	area_entered.connect(_on_area_entered)
	health_component.died.connect(_on_died)
	var direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	var speed = randf_range(min_speed, max_speed)
	velocity = direction * speed
	rotation_speed = randf_range(min_rotation_speed, max_rotation_speed)
	if randf() > 0.5:
		rotation_speed *= -1.0

func _process(delta):
	position += velocity * delta
	rotation += rotation_speed * delta
	handle_screen_wrap()

func handle_screen_wrap():
	var screen_size = get_viewport_rect().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

func _on_area_entered(area):
	if area.is_in_group("projectile"):
		area.queue_free()
		health_component.take_damage(1)

func _on_died():
	destroyed.emit()
	queue_free()
