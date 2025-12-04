extends BaseNPC
class_name OrionNPC


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

func _npc_ready() -> void:
	pass

func _handle_interaction(word: String) -> void:
	if word == "talk":
		if GlobalGameState.is_npc_defeated("orion"):
			await _play_post_tutorial_dialogue()
		else:
			await _play_intro_and_start_tutorial()

func _play_intro_and_start_tutorial() -> void:
	await _play_dialogue_sequence(intro_dialogues, 1.6)
	_start_tutorial_battle()

func _play_post_tutorial_dialogue() -> void:
	await _play_dialogue_sequence(post_tutorial_dialogues, 1.6)
	_set_player_can_move(true)

func _start_tutorial_battle() -> void:
	_start_battle(
		"res://typing_battle.tscn",
		"orion",
		"The enemies you come across will have typing battles like these."
	)
