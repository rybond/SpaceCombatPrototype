extends Area2D

@export var speed: float = 900.0
@export var damage: int = 1          # ← now easy to change!

var direction: Vector2 = Vector2.ZERO

func _ready():
	$LifetimeTimer.timeout.connect(_on_lifetime_timeout)
	$LifetimeTimer.start()
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	var health_comp = body.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.take_damage(damage)
		queue_free()
	elif body is AsteroidBase:
		body.take_damage(damage)   # keeps asteroids working perfectly
		queue_free()

func _on_lifetime_timeout():
	queue_free()
