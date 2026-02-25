extends CharacterBody2D

@export var thrust_force: float = 400.0
@export var rotation_speed: float = 3.0
@export var max_speed: float = 400.0
@export var drag: float = .98
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = .15

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
