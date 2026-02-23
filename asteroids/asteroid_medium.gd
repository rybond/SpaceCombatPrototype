extends AsteroidBase

func _ready():
	max_health = 2
	min_speed = 100.0
	max_speed = 180.0
	min_spin = 0.6
	max_spin = 1.8
	num_children_min = 2
	num_children_max = 3
	linear_damp = 0.0
	super._ready()
