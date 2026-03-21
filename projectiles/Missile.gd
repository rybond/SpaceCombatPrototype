extends Area2D

@export var damage: int = 5
@export var launch_speed: float = 200.0
@export var missile_cooldown: float = 2.0
@export var acceleration: float = 80.0
@export var turn_rate: float = 2.8
@export var smart_tracking: bool = true
@export var lifetime: float = 4.0

var shooter: Node = null
var _current_speed: float = 0.0

func _ready() -> void:
	_current_speed = launch_speed
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	_current_speed += acceleration * delta

	var target := _find_target()
	if target != null:
		var to_target: Vector2 = target.global_position - global_position
		var angle_diff: float = transform.x.angle_to(to_target)
		var steer: float = clamp(angle_diff, -turn_rate * delta, turn_rate * delta)
		rotation += steer

	position += transform.x * _current_speed * delta
	_handle_screen_wrap()

func _find_target() -> Node2D:
	var best: Node2D = null
	var best_dist := INF

	for node in get_tree().get_nodes_in_group("ships"):
		if node == shooter or not node is Node2D or not node.visible:
			continue
		var d: float = global_position.distance_to(node.global_position)
		if d < best_dist:
			best_dist = d
			best = node

	if not smart_tracking:
		for node in get_tree().get_nodes_in_group("asteroids"):
			if not node is Node2D:
				continue
			var d: float = global_position.distance_to(node.global_position)
			if d < best_dist:
				best_dist = d
				best = node

	return best

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return
	var health_comp = body.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.take_damage(damage)
		queue_free()
	elif body is AsteroidBase:
		body.take_damage(damage)
		queue_free()

func _handle_screen_wrap() -> void:
	var screen_size := get_viewport_rect().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y
