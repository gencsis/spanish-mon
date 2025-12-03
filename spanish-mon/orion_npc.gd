extends StaticBody2D
class_name OrionNPC

@onready var area: Area2D = $Area2D
@onready var screen_dialogue: ScreenDialogue = get_node("/root/GameLevel/ScreenDialogue")
@onready var typing_choice: TypingChoice2D = $TypingChoice

var intro_dialogues := [
	"HELLO, I AM ORION!!!",
	"Haha, sorry for yelling. It's not too often that we get visitors here.",
	"I assume that you're the one that just crashed?",
	"I can help you with some basics about this world.",
	"This world revolves around typing.",
	"There will be some enemies along the way so always be prepared.",
	"Let me show you how typing battles work."
]

var post_tutorial_dialogues := [
	"Nice job in that battle!",
	"Now that you have finished, I must inform you of other things.",
	"There are worms that exist around the world that can heal you.",
	"You can either [eat] the worm to heal.",
	"Or [grab] the worm to place it in your inventory for later.",
	"You can use [z] to access your worms.",
	"Oh, also make sure to keep track of your hearts.",
	"Once you lose all 3 hearts, then it's game over for you.",
	"Good luck fixing your ship!"
]


func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)

	if typing_choice:
		typing_choice.choice_completed.connect(_on_talk_chosen)

	if screen_dialogue:
		screen_dialogue.hide_dialogue()


func _on_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if typing_choice:
		typing_choice.options = ["talk"]
		typing_choice.start_choices()


func _on_area_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if typing_choice:
		typing_choice.stop_choices()
	if screen_dialogue:
		screen_dialogue.hide_dialogue()


func _on_talk_chosen(index: int, word: String) -> void:
	if word.to_lower() != "talk":
		return

	if GlobalGameState.is_npc_defeated("orion"):
		await _play_post_tutorial_dialogue()
	else:
		await _play_intro_and_start_tutorial()


func _set_player_can_move(can_move: bool) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(can_move)


func _play_intro_and_start_tutorial() -> void:
	_set_player_can_move(false)
	if typing_choice:
		typing_choice.stop_choices()

	for line in intro_dialogues:
		if screen_dialogue:
			screen_dialogue.show_text(line)
		await get_tree().create_timer(1.6).timeout

	if screen_dialogue:
		screen_dialogue.hide_dialogue()

	_start_tutorial_battle()


func _play_post_tutorial_dialogue() -> void:
	_set_player_can_move(false)
	if typing_choice:
		typing_choice.stop_choices()

	for line in post_tutorial_dialogues:
		if screen_dialogue:
			screen_dialogue.show_text(line)
		await get_tree().create_timer(1.6).timeout

	if screen_dialogue:
		screen_dialogue.hide_dialogue()

	_set_player_can_move(true)


func _start_tutorial_battle() -> void:
	if not get_tree():
		return

	var player := get_tree().get_first_node_in_group("player")
	if player:
		GlobalGameState.save_player_position(player.global_position)

	GlobalGameState.set_battle_context(
		"orion",
		"The enemies you come across will have typing battles like these."
	)

	get_tree().change_scene_to_file("res://typing_battle.tscn")
