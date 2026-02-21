extends CharacterBody2D

@export var thrust_force: float = 800.0
@export var rotation_speed: float = 3.0
@export var max_speed: float = 600.0
@export var drag: float = 0.98
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 0.25

var can_fire := true

func _ready():
	$FireCooldownTimer.wait_time = fire_cooldown
	$FireCooldownTimer.timeout.connect(_on_fire_cooldown_timeout)

func _physics_process(delta):
	handle_rotation(delta)
	handle_thrust(delta)
	handle_fire()
	apply_drag()
	limit_speed()
	move_and_slide()
	handle_screen_wrap()

func handle_rotation(delta):
	var rotation_input = 0.0
	if Input.is_action_pressed("ui_left"):
		rotation_input -= 1.0
	if Input.is_action_pressed("ui_right"):
		rotation_input += 1.0
	rotation += rotation_input * rotation_speed * delta

func handle_thrust(delta):
	if Input.is_action_pressed("ui_up"):
		var forward = Vector2.RIGHT.rotated(rotation)
		velocity += forward * thrust_force * delta

func handle_fire():
	if Input.is_action_pressed("fire") and can_fire:
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
