extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var respawn_timer: Timer = $RespawnTimer

@export var thrust_force: float = 400.0
@export var rotation_speed: float = 3.0
@export var max_speed: float = 400.0
@export var drag: float = 1
@export var projectile_scene: PackedScene
@export var fire_cooldown: float = .05
@export var shot_damage: int = 1
@export var missile_scene: PackedScene

var can_fire := true
var can_fire_missile := true

func _ready():
	$FireCooldownTimer.wait_time = fire_cooldown
	$FireCooldownTimer.timeout.connect(_on_fire_cooldown_timeout)
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	$MissileCooldownTimer.timeout.connect(_on_missile_cooldown_timeout)

func _physics_process(_delta):
	apply_drag()
	limit_speed()
	move_and_slide()
	handle_screen_wrap()
	$Thruster.emitting = false

func apply_thrust(delta):
	var forward = Vector2.RIGHT.rotated(rotation)
	velocity += forward * thrust_force * delta
	$Thruster.emitting = true

func apply_rotation(direction: float, delta: float):
	rotation += direction * rotation_speed * delta

func try_fire():
	if can_fire:
		fire()

func try_fire_missile():
	if can_fire_missile:
		fire_missile()

func fire():
	if projectile_scene == null:
		return
	$gun2sound.play()
	can_fire = false
	var projectile = projectile_scene.instantiate()
	projectile.damage = shot_damage
	var forward = Vector2.RIGHT.rotated(rotation)
	projectile.direction = forward
	projectile.global_position = global_position + forward * 30
	get_tree().current_scene.add_child(projectile)
	$FireCooldownTimer.start()

func fire_missile():
	if missile_scene == null:
		return
	can_fire_missile = false
	var missile = missile_scene.instantiate()
	missile.shooter = self
	var forward = Vector2.RIGHT.rotated(rotation)
	missile.global_position = global_position + forward * 30
	missile.rotation = rotation
	get_tree().current_scene.add_child(missile)
	$MissileCooldownTimer.wait_time = missile.missile_cooldown
	$MissileCooldownTimer.start()

func _on_fire_cooldown_timeout():
	can_fire = true

func _on_missile_cooldown_timeout():
	can_fire_missile = true

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

func _on_died() -> void:
	$ExplosionSound.play()
	respawn_timer.start()
	visible = false
	set_physics_process(false)

func _on_respawn_timer_timeout() -> void:
	var screen_size = get_viewport_rect().size
	position = screen_size / 2
	rotation = 0.0
	velocity = Vector2.ZERO
	health_component.reset()
	visible = true
	set_physics_process(true)
	can_fire_missile = true
