extends AsteroidBase

func _ready():
	max_health = 1
	min_speed = 40.0
	max_speed = 80.0
	min_spin = 0.2
	max_spin = 0.8
	num_children_min = 2
	num_children_max = 3
	super._ready()
