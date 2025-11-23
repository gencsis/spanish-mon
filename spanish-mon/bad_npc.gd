extends StaticBody2D

@onready var area: Area2D = $Area2D

@export_file("*.tscn") var battle_scene: String = "res://typing_battle.tscn"

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(battle_scene)
