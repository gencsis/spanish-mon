extends Node2D

# mock for Player used for collision 

var velocity: Vector2 = Vector2.ZERO
var health: int = 10

signal damaged(amount)
signal died

func _init():
	add_to_group("player")

func take_damage(amount: int):
	health -= amount
	emit_signal("damaged", amount)
	if health <= 0:
		emit_signal("died")
