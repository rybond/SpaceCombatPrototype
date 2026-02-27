extends CharacterBody2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var respawn_timer: Timer = $RespawnTimer
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
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)

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
	$ExplosionSound.play()
	respawn_timer.start()
	visible = false
	set_physics_process(false)  # stop thrust/rotation while dead
	# Next step: 2-3s delay + respawn at center
func _on_respawn_timer_timeout() -> void:
	var screen_size = get_viewport_rect().size
	position = screen_size / 2
	rotation = 0.0
	velocity = Vector2.ZERO
	health_component.current_health = health_component.max_health
	visible = true
	set_physics_process(true)
