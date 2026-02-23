extends AsteroidBase

func _ready():
	max_health = 3
	min_speed = 70.0
	max_speed = 130.0
	min_spin = 0.4
	max_spin = 1.2
	num_children_min = 2
	num_children_max = 3
	linear_damp = 0.0
	super._ready()
