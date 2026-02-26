class_name AsteroidBase
extends RigidBody2D

signal destroyed

@export var max_health: int = 1
@export var min_speed: float = 50.0
@export var max_speed: float = 150.0
@export var min_spin: float = 0.5
@export var max_spin: float = 2.0
@export var child_scene: PackedScene
@export var num_children_min: int = 2
@export var num_children_max: int = 3

var current_health: int
var split_angle_spread: float = 0.6
var _dead: bool = false

@onready var screensize: Vector2 = get_viewport_rect().size

func _ready():
	current_health = max_health
	contact_monitor = true
	max_contacts_reported = 4
	linear_damp = 0.0
	angular_damp = 0.0  # NEW: Zero spin decay
	var direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	var speed = randf_range(min_speed, max_speed)
	linear_velocity = direction * speed
	var spin = randf_range(min_spin, max_spin)
	if randf() > 0.5:
		spin *= -1.0
	angular_velocity = spin
	$ExplosionSound.finished.connect($ExplosionSound.queue_free)

func _integrate_forces(state: PhysicsDirectBodyState2D):  # NEW/REPLACED: Safe wrap
	var xform = state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	state.transform = xform

# REMOVE _physics_process & handle_screen_wrap() entirely!

func take_damage(amount: int):
	if _dead:
		return
	current_health -= amount
	if current_health <= 0:
		_dead = true
		call_deferred("_do_die")

func _do_die():
	_spawn_children()
	destroyed.emit()
	var sound = $ExplosionSound
	sound.reparent(get_tree().root)
	sound.play()
	queue_free()

func _spawn_children():
	if child_scene == null:
		return
	var arena = get_parent()
	if arena == null:
		return
	var num_children = randi_range(num_children_min, num_children_max)
	for i in range(num_children):
		var child = child_scene.instantiate()
		var base_angle = linear_velocity.angle() if linear_velocity.length() > 0.1 else randf_range(0, TAU)
		var spread = randf_range(-split_angle_spread, split_angle_spread)
		var child_direction = Vector2.RIGHT.rotated(base_angle + spread)
		child.global_position = global_position
		arena.add_child(child)
		var child_speed = randf_range(child.min_speed, child.max_speed)
		child.linear_velocity = child_direction * child_speed
		arena.register_asteroid(child)
