extends AsteroidBase

func _ready():
	max_health = 1
	min_speed = 150.0
	max_speed = 280.0
	min_spin = 1.0
	max_spin = 3.0
	num_children_min = 0
	num_children_max = 0
	linear_damp = 0.0
	child_scene = null
	super._ready()
