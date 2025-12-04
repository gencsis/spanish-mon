extends BaseNPC
class_name ShipNPC


var has_all_pieces: bool = false

func _npc_ready() -> void:
	GlobalGameState.all_pieces_collected.connect(_on_all_pieces_collected)
	
	if GlobalGameState.ship_pieces_collected >= GlobalGameState.TOTAL_SHIP_PIECES:
		has_all_pieces = true

func _on_all_pieces_collected() -> void:
	has_all_pieces = true
	
	if player_near:
		_show_dialogue("You got all the parts! Now go to your ship and type [fix] then [escape]!")

func get_interaction_options() -> Array[String]:
	if has_all_pieces:
		return ["fix", "inspect"]
	else:
		return ["inspect"]

func _on_player_entered() -> void:
	if has_all_pieces:
		if typing_choice:
			typing_choice.options = ["fix", "inspect"]
			typing_choice.start_choices()
		_show_dialogue("Type [fix] to repair your ship, or [inspect] to examine it.")
	else:
		var pieces_left = GlobalGameState.TOTAL_SHIP_PIECES - GlobalGameState.ship_pieces_collected
		_show_dialogue("Your ship is badly damaged. You need %d more piece(s) to repair it." % pieces_left)

func _handle_interaction(word: String) -> void:
	match word:
		"fix":
			if has_all_pieces:
				_start_repair_sequence()
		"inspect":
			_show_inspection_message()

func _show_inspection_message() -> void:
	if has_all_pieces:
		_show_dialogue("All the pieces are here. Type [fix] to begin repairs!")
	else:
		var pieces_left = GlobalGameState.TOTAL_SHIP_PIECES - GlobalGameState.ship_pieces_collected
		_show_dialogue("The ship needs %d more piece(s). Keep exploring!" % pieces_left)

func _start_repair_sequence() -> void:
	_set_player_can_move(false)
	
	if typing_choice:
		typing_choice.stop_choices()
	
	_show_dialogue("You begin installing the ship pieces...")
	await get_tree().create_timer(2.0).timeout
	
	_show_dialogue("The hull is repaired! The engine is fixed!")
	await get_tree().create_timer(2.0).timeout
	
	_show_dialogue("Your ship is ready! Type [escape] to launch!")
	
	if typing_choice:
		typing_choice.options = ["escape"]
		typing_choice.choice_completed.disconnect(_on_choice_completed)
		typing_choice.choice_completed.connect(_on_escape_typed)
		typing_choice.start_choices()
	
	_set_player_can_move(true)

func _on_escape_typed(index: int, word: String) -> void:
	if word.to_lower() == "escape":
		_set_player_can_move(false)
		
		_show_dialogue("Launching in 3... 2... 1...")
		await get_tree().create_timer(2.0).timeout
		
		if get_tree():
			get_tree().change_scene_to_file("res://Scenes/end_menu.tscn")
