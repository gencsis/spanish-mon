extends StaticBody2D

@onready var typing_choice: TypingChoice2D = $TypingChoice
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	$AnimationPlayer.play("worm_wiggle")
	typing_choice.choice_completed.connect(_on_choice_completed)
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		typing_choice.start_choices()

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		typing_choice.stop_choices()


func get_animations():
	$AnimationPlayer.get_animation("worm_wiggle")


func _on_choice_completed(index: int, word: String) -> void:
	print("CHOICE COMPLETED: ", index," ", word)
	match word.to_lower():
		"grab":
			_add_worm_to_inventory()
		"eat":
			_eat_worm()

func _add_worm_to_inventory() -> void:
	var hud := get_tree().current_scene.get_node("HUD") as HUD
	if hud:
		var added: bool = hud.add_item_to_inventory("worm")
		if added:
			_delete_worm()
		else:
			push_warning("HUD not found")	

func _eat_worm() -> void:
	var hud = get_tree().current_scene.get_node("HUD") as HUD
	if hud != null:
		hud.increase_hearts(1)
	else:
		push_warning("HUD not found")
	queue_free()

func _delete_worm() -> void:
	queue_free()
	
	

	
