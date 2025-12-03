extends StaticBody2D
class_name AuroraNPC

@onready var area: Area2D = $Area2D
@onready var screen_dialogue: CanvasLayer = get_node("/root/GameLevel/ScreenDialogue")
@onready var typing_choice: TypingChoice2D = $TypingChoice

var has_talked: bool = false

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	
	if typing_choice:
		typing_choice.choice_completed.connect(_on_talk_chosen)
	
	if screen_dialogue:
		screen_dialogue.hide_dialogue()

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not has_talked:
		if typing_choice:
			typing_choice.options = ["talk"]
			typing_choice.start_choices()

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if typing_choice:
			typing_choice.stop_choices()
		if screen_dialogue:
			screen_dialogue.hide_dialogue()
		has_talked = false

func _on_talk_chosen(index: int, word: String) -> void:
	if word.to_lower() == "talk":
		has_talked = true
		
		if GlobalGameState.has_piece_three:
			_show_already_beaten_message()
		else:
			_show_dialogue_then_battle()

func _show_already_beaten_message() -> void:
	if screen_dialogue:
		screen_dialogue.show_text("Woah! You're pretty fast!! You can take your piece back! It was fun racing you!")
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)

func _show_dialogue_then_battle() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	if screen_dialogue:
		screen_dialogue.show_text("Your ship is broken? And you need the piece next to me to fix it?")
	await get_tree().create_timer(2.0).timeout
	
	if screen_dialogue:
		screen_dialogue.show_text("HMM. I'll let you get it. IF YOU'RE FAST ENOUGH!!!")
	await get_tree().create_timer(1.5).timeout
	
	#GlobalGameState.collect_ship_piece("piece_three")
	
	call_deferred("_start_battle")

func _start_battle() -> void:
	if get_tree():
		GlobalGameState.set_battle_context("aurora", "For some crazy reason, the medic didn't consider a lack of milk for my cereal as a proper emergency.")
		get_tree().change_scene_to_file("res://typing_battle.tscn")
