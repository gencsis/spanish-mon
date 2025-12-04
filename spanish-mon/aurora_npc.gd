extends BaseNPC
class_name AuroraNPC


func _npc_ready() -> void:
	pass

func _handle_interaction(word: String) -> void:
	if word == "talk":
		if GlobalGameState.has_piece_one:
			_show_already_beaten_message()
		else:
			_show_dialogue_then_battle()

func _show_already_beaten_message() -> void:
	_show_dialogue("Woah! You're pretty fast!! You can take your piece back! It was fun racing you!")
	_set_player_can_move(true)

func _show_dialogue_then_battle() -> void:
	_set_player_can_move(false)
	
	_show_dialogue("Your ship is broken? And you need the piece next to me to fix it?")
	await get_tree().create_timer(2.0).timeout
	
	_show_dialogue("HMM. I'll let you get it. IF YOU'RE FAST ENOUGH!!!")
	await get_tree().create_timer(1.5).timeout
	
	_start_battle(
		"res://typing_battle.tscn",
		"aurora",
		"For some crazy reason, the medic didn't consider a lack of milk for my cereal as an emergency."
	)
