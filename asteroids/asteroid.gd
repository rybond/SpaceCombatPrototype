extends Area2D

signal destroyed

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body):
	pass  # Not needed yet

func _on_area_entered(area):
	if area.is_in_group("projectile"):
		area.queue_free()
		destroyed.emit()
		queue_free()
