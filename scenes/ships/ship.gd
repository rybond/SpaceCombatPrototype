extends CharacterBody2D
@onready var health_component: HealthComponent = $HealthComponent
@export var thrust_force: float = 400.0
@export var rotation_speed: float = 3.0
@export var max_speed: float = 400.0
@export var drag: float = 1
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = .05


var can_fire := true

func _ready():
	$FireCooldownTimer.wait_time = fire_cooldown
	$FireCooldownTimer.timeout.connect(_on_fire_cooldown_timeout)

func _physics_process(_delta):
	apply_drag()
	limit_speed()
	move_and_slide()
	handle_screen_wrap()
	$Thruster.emitting = Input.is_action_pressed("ui_up")
	# Asteroid collision damage (proportional to impact speed)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body and body.is_in_group("asteroids"):
			var relative_velocity = velocity - body.linear_velocity  # FIXED for RigidBody2D
			var impact_speed = relative_velocity.length()
			var damage = int(impact_speed / 10)
			damage = clamp(damage, 5, 50)
			break  # only one hit per frame


func apply_thrust(delta):
	var forward = Vector2.RIGHT.rotated(rotation)
	velocity += forward * thrust_force * delta

func apply_rotation(direction: float, delta: float):
	rotation += direction * rotation_speed * delta

func try_fire():
	if can_fire:
		fire()

func fire():
	if projectile_scene == null:
		return
	$gun2sound.play()   # ← NEW LINE
	can_fire = false
	var projectile = projectile_scene.instantiate()
	var forward = Vector2.RIGHT.rotated(rotation)
	projectile.direction = forward
	projectile.global_position = global_position + forward * 30
	get_tree().current_scene.add_child(projectile)
	$FireCooldownTimer.start()

func _on_fire_cooldown_timeout():
	can_fire = true

func apply_drag():
	velocity *= drag

func limit_speed():
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

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

@warning_ignore("unused_parameter")

func _on_health_changed(new_health: int, _max_health: int) -> void:
	get_parent().get_node("HealthLabel").text = "HP: " + str(new_health)

func _on_died() -> void:
	# TODO: jumbo explosion + 2–3s delay → respawn
	pass
