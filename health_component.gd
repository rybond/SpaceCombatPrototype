class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died()

@export var max_health: int = 100

var current_health: int = max_health

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return  # already dead, ignore further hits
	current_health -= amount
	current_health = max(current_health, 0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

func reset() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
