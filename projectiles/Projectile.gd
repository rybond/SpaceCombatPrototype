extends Area2D

@export var speed: float = 900.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	$LifetimeTimer.timeout.connect(_on_lifetime_timeout)
	$LifetimeTimer.start()
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body is AsteroidBase:
		body.take_damage(1)
		queue_free()

func _on_lifetime_timeout():
	queue_free()
