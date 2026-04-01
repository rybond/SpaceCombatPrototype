extends Node

enum ControlType {
	HUMAN,
	CYBORG
}

enum Difficulty {
	ROOKIE,
	CAPTAIN,
	ACE
}

@export var control_type: ControlType = ControlType.HUMAN
@export var target_ship: CharacterBody2D
@export var difficulty: Difficulty = Difficulty.CAPTAIN

@export var thrust_action: String = "ui_up"
@export var rotate_left_action: String = "ui_left"
@export var rotate_right_action: String = "ui_right"
@export var fire_action: String = "fire"
@export var fire_secondary_action: String = "fire_secondary"

var ship: CharacterBody2D = null
var ai_fire_cooldown := 0.0
var ai_missile_cooldown := 0.0
var decision_timer := 0.0
var desired_turn_sign := 0.0
var desired_thrust := false
var _projectile_speed: float = 900.0

func _ready():
	ship = get_parent()
	_cache_projectile_speed()

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
		if Input.is_action_just_pressed(fire_secondary_action):
			ship.try_fire_missile()
	
	elif control_type == ControlType.CYBORG and target_ship != null:
		var cfg = _get_difficulty_config()
		
		# Cooldown always counts down in real time
		ai_fire_cooldown -= delta
		ai_missile_cooldown -= delta
		
		
		# Decision tick: only update intent at intervals
		decision_timer -= delta
		if decision_timer <= 0.0:
			decision_timer = cfg.decision_interval
			
			# Choose aim point: raw position for Rookie, simple leading for Captain/Ace
			var target_pos: Vector2 = target_ship.global_position
			var aim_pos: Vector2 = target_pos
			
			if difficulty != Difficulty.ROOKIE:
				var target_velocity := target_ship.velocity if "velocity" in target_ship else Vector2.ZERO
				if _projectile_speed > 0.0 and target_velocity.length() > 0.1:
					var to_target := target_pos - ship.global_position
					var distance := to_target.length()
					var time_to_hit := distance / _projectile_speed
					aim_pos = target_pos + target_velocity * time_to_hit
			
			var to_aim := aim_pos - ship.global_position
			var angle_to := ship.transform.x.angle_to(to_aim)
			
			# Ideal decisions based on angle and engagement
			var ideal_turn_sign := 0.0
			if angle_to > cfg.turn_threshold:
				ideal_turn_sign = 1.0
			elif angle_to < -cfg.turn_threshold:
				ideal_turn_sign = -1.0
			
			# Apply asteroid avoidance steering bias
			var avoid_turn := _get_avoidance_turn_sign(cfg)
			if avoid_turn != 0.0:
				var combined := ideal_turn_sign + avoid_turn
				if combined > 0.25:
					ideal_turn_sign = 1.0
				elif combined < -0.25:
					ideal_turn_sign = -1.0
				else:
					ideal_turn_sign = 0.0
			
			var ideal_thrust := true
			
			# Apply difficulty-scaled error and hesitation
			if randf() < cfg.idle_tick_chance:
				desired_turn_sign = 0.0
				desired_thrust = false
			else:
				desired_turn_sign = ideal_turn_sign
				desired_thrust = ideal_thrust
				
				if randf() < cfg.turn_error_chance:
					# Flip or clear turn direction
					if desired_turn_sign != 0.0:
						desired_turn_sign = -desired_turn_sign
					else:
						desired_turn_sign = 0.0
				
				if randf() < cfg.thrust_error_chance:
					desired_thrust = not desired_thrust
			
			# Update firing intent on tick as well
			var abs_angle: float = abs(angle_to)
			if ai_fire_cooldown <= 0.0 and abs_angle < cfg.fire_aim_tolerance:
				# Add small per-difficulty trigger hesitation (none for Ace)
				var hesitate := false
				if difficulty == Difficulty.ROOKIE and randf() < 0.5:
					hesitate = true
				elif difficulty == Difficulty.CAPTAIN and randf() < 0.2:
					hesitate = true
				if not hesitate:
					ship.try_fire()
					ai_fire_cooldown = cfg.fire_cooldown
				if ai_missile_cooldown <= 0.0 and abs_angle < cfg.fire_aim_tolerance * 2.0:
					ship.try_fire_missile()
					ai_missile_cooldown = 2.5
		
		# Execute stored decisions each frame
		if desired_turn_sign > 0.0:
			ship.apply_rotation(1.0, delta)
		elif desired_turn_sign < 0.0:
			ship.apply_rotation(-1.0, delta)
		
		if desired_thrust:
			ship.apply_thrust(delta * cfg.thrust_scale)


func _get_difficulty_config():
	match difficulty:
		Difficulty.ROOKIE:
			return {
				"turn_threshold": 0.24,
				"fire_aim_tolerance": 0.38,
				"thrust_scale": 0.38,
				"fire_cooldown": 0.60,
				"decision_interval": 0.32,
				"turn_error_chance": 0.22,
				"thrust_error_chance": 0.28,
				"idle_tick_chance": 0.18,
				"avoid_radius": 140.0,
				"avoid_weight": 0.6,
			}
		Difficulty.ACE:
			return {
				"turn_threshold": 0.06,
				"fire_aim_tolerance": 0.145,
				"thrust_scale": 1.0,
				"fire_cooldown": 0.13,
				"decision_interval": 0.065,
				"turn_error_chance": 0.012,
				"thrust_error_chance": 0.012,
				"idle_tick_chance": 0.0,
				"avoid_radius": 220.0,
				"avoid_weight": 1.4,
			}
		_:
			# CAPTAIN (baseline, similar to prior behavior)
			return {
				"turn_threshold": 0.11,
				"fire_aim_tolerance": 0.22,
				"thrust_scale": 0.70,
				"fire_cooldown": 0.23,
				"decision_interval": 0.15,
				"turn_error_chance": 0.07,
				"thrust_error_chance": 0.07,
				"idle_tick_chance": 0.0,
				"avoid_radius": 180.0,
				"avoid_weight": 1.0,
			}


func _cache_projectile_speed() -> void:
	if ship == null:
		return
	if "projectile_scene" in ship and ship.projectile_scene:
		var proj = ship.projectile_scene.instantiate()
		if "speed" in proj:
			_projectile_speed = proj.speed
		proj.queue_free()


func _get_avoidance_turn_sign(cfg) -> float:
	if ship == null:
		return 0.0
	if not get_tree():
		return 0.0
	
	var forward: Vector2 = ship.transform.x.normalized()
	var right: Vector2 = ship.transform.y.normalized()
	var radius: float = cfg.avoid_radius
	var weight: float = cfg.avoid_weight
	var closest_dist := INF
	var best_sign := 0.0
	
	for node in get_tree().get_nodes_in_group("asteroids"):
		if not node is Node2D:
			continue
		var dir: Vector2 = node.global_position - ship.global_position
		var dist := dir.length()
		if dist <= 0.0 or dist > radius:
			continue
		dir /= dist
		
		var ahead := forward.dot(dir)
		if ahead <= 0.0:
			continue
		
		if dist < closest_dist:
			closest_dist = dist
			var side := right.dot(dir)
			if abs(side) < 0.01:
				best_sign = 0.0
			elif side > 0.0:
				best_sign = -1.0
			else:
				best_sign = 1.0
	
	if best_sign == 0.0:
		return 0.0
	
	var strength: float = clamp((radius - closest_dist) / radius, 0.0, 1.0)
	return best_sign * strength * weight
