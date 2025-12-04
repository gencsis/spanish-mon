extends BaseNPC
class_name ZenithNPC


func _npc_ready() -> void:
	pass

func _handle_interaction(word: String) -> void:
	if word == "talk":
		if GlobalGameState.has_piece_three:
			_show_already_beaten_message()
		else:
			_show_dialogue_then_battle()

func _show_already_beaten_message() -> void:
	_show_dialogue("WOW, you're good. That was fun! Good luck fixing your ship.")
	_set_player_can_move(true)

func _show_dialogue_then_battle() -> void:
	_set_player_can_move(false)
	
	_show_dialogue("You want this piece of metal here?")
	await get_tree().create_timer(1.5).timeout
	
	_show_dialogue("Hmmm... I'll only let you take it if you beat me in a dance battle!!")
	await get_tree().create_timer(2.0).timeout
	
	_start_battle(
		"res://arrow_battle.tscn",
		"zenith",
		""
	)
