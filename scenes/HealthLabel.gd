extends Label

func _on_health_component_health_changed(new_health: int, _max_health: int) -> void:
	text = "HP: " + str(new_health)
