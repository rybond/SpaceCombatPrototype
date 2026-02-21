extends Node

@export var thrust_action: String = "ui_up"
@export var rotate_left_action: String = "ui_left"
@export var rotate_right_action: String = "ui_right"
@export var fire_action: String = "fire"

var ship: CharacterBody2D = null

func _ready():
	ship = get_parent()

func _physics_process(delta):
	if ship == null:
		return
	if Input.is_action_pressed(rotate_left_action):
		ship.apply_rotation(-1.0, delta)
	if Input.is_action_pressed(rotate_right_action):
		ship.apply_rotation(1.0, delta)
	if Input.is_action_pressed(thrust_action):
		ship.apply_thrust(delta)
	if Input.is_action_pressed(fire_action):
		ship.try_fire()
