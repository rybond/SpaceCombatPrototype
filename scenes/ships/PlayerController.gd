extends Node

enum ControlType {
	HUMAN,
	CYBORG
}

@export var control_type: ControlType = ControlType.HUMAN
@export var target_ship: CharacterBody2D

@export var thrust_action: String = "ui_up"
@export var rotate_left_action: String = "ui_left"
@export var rotate_right_action: String = "ui_right"
@export var fire_action: String = "fire"

var ship: CharacterBody2D = null
var ai_fire_cooldown := 0.0   # NEW: stops robot spam

func _ready():
	ship = get_parent()

func _physics_process(delta):
	if ship == null:
		return
	
	if control_type == ControlType.HUMAN:
		if Input.is_action_pressed(rotate_left_action):
			ship.apply_rotation(-1.0, delta)
		if Input.is_action_pressed(rotate_right_action):
			ship.apply_rotation(1.0, delta)
		if Input.is_action_pressed(thrust_action):
			ship.apply_thrust(delta)
		if Input.is_action_pressed(fire_action):
			ship.try_fire()
	
	elif control_type == ControlType.CYBORG and target_ship != null:
		var to_target = target_ship.global_position - ship.global_position
		var angle_to = ship.transform.x.angle_to(to_target)
		
		# Turn toward target (a bit slower)
		if angle_to > 0.12:
			ship.apply_rotation(1.0, delta)
		elif angle_to < -0.12:
			ship.apply_rotation(-1.0, delta)
		
		# Gentle thrust
		ship.apply_thrust(delta * 0.65)
		
		# Shoot MUCH less often (fair rate)
		ai_fire_cooldown -= delta
		if ai_fire_cooldown <= 0 and abs(angle_to) < 0.22:
			ship.try_fire()
			ai_fire_cooldown = 0.25   # ~4 shots per second max
