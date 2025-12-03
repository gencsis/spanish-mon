extends StaticBody2D
class_name OrionNPC

@onready var area: Area2D = $Area2D
@onready var screen_dialogue: CanvasLayer = get_node("/root/GameLevel/ScreenDialogue")
@onready var typing_choice: TypingChoice2D = $TypingChoice

var has_started: bool = false

var dialogues = [
	"HELLO, I AM ORION!!!",
	"Haha, sorry for yelling. It's not too often that we get visitors here.",
	"I assume that you're the one that just crashed?",
	"I can help you with some basics about this world.",
	"This world revolves around typing.", 
	"There will be some enemies along the way so always be prepared.",
	"I'll give you a tutorial before I let you go!"
]

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	
	if typing_choice:
		typing_choice.choice_completed.connect(_on_talk_chosen)
	
	if screen_dialogue:
		screen_dialogue.hide_dialogue()

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not has_started:
		if typing_choice:
			typing_choice.options = ["talk"]
			typing_choice.start_choices()

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if typing_choice:
			typing_choice.stop_choices()
		if screen_dialogue:
			screen_dialogue.hide_dialogue()

func _on_talk_chosen(index: int, word: String) -> void:
	if word.to_lower() == "talk":
		has_started = true
		_show_all_dialogue()

func _show_all_dialogue() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	for dialogue in dialogues:
		if screen_dialogue:
			screen_dialogue.show_text(dialogue)
		await get_tree().create_timer(1.5).timeout
	
	call_deferred("_start_tutorial_battle")

func _start_tutorial_battle() -> void:
	if get_tree():
		GlobalGameState.set_battle_context("orion", "The enemies you come across will have typing battles like these.")
		get_tree().change_scene_to_file("res://typing_battle.tscn")
