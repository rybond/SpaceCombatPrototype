extends AsteroidBase

func _ready():
	max_health = 4
	min_speed = 40.0  # Tune higher (60-100) if still "slow"
	max_speed = 80.0
	min_spin = 0.2
	max_spin = 0.8
	num_children_min = 2
	num_children_max = 3
	# REMOVED: linear_damp=0 (base handles); super first!
	super._ready()
