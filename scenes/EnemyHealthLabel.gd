extends Label

func _on_health_component_health_changed(current: int, maximum: int):
	text = "HP: " + str(current)
