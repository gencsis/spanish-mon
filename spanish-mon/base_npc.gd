extends StaticBody2D
class_name BaseNPC

@onready var area: Area2D = $Area2D
@onready var typing_choice: TypingChoice2D = $TypingChoice

var dialogue_system: Node = null

var player_near: bool = false
var has_talked: bool = false

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_area_body_entered)
		area.body_exited.connect(_on_area_body_exited)
	
	if typing_choice:
		typing_choice.choice_completed.connect(_on_choice_completed)
	
	dialogue_system = get_node_or_null("/root/GameLevel/ScreenDialogue")
	if not dialogue_system:
		dialogue_system = get_node_or_null("DialogueBubble")
	
	if dialogue_system and dialogue_system.has_method("hide_dialogue"):
		dialogue_system.hide_dialogue()
	elif dialogue_system and dialogue_system.has_method("hide_bubble"):
		dialogue_system.hide_bubble()
	
	_npc_ready()

func _npc_ready() -> void:
	pass

func _on_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_near = true
	_on_player_entered()

func _on_area_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	player_near = false
	has_talked = false
	
	if typing_choice:
		typing_choice.stop_choices()
	
	_hide_dialogue()
	_on_player_exited()

func _on_player_entered() -> void:
	if typing_choice and not has_talked:
		typing_choice.options = get_interaction_options()
		typing_choice.start_choices()

func _on_player_exited() -> void:
	pass

func get_interaction_options() -> Array[String]:
	return ["talk"]

func _on_choice_completed(index: int, word: String) -> void:
	has_talked = true
	_handle_interaction(word.to_lower())

func _handle_interaction(word: String) -> void:
	if word == "talk":
		_start_dialogue()

func _start_dialogue() -> void:
	pass

func _show_dialogue(text: String) -> void:
	if dialogue_system:
		if dialogue_system.has_method("show_text"):
			dialogue_system.show_text(text)
		elif dialogue_system.has_method("show_bubble"):
			dialogue_system.show_bubble(text)

func _hide_dialogue() -> void:
	if dialogue_system:
		if dialogue_system.has_method("hide_dialogue"):
			dialogue_system.hide_dialogue()
		elif dialogue_system.has_method("hide_bubble"):
			dialogue_system.hide_bubble()

func _set_player_can_move(can_move: bool) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(can_move)

func _save_player_position() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GlobalGameState.save_player_position(player.global_position)

func _start_battle(battle_scene: String, npc_name: String, sentence: String = "") -> void:
	_save_player_position()
	GlobalGameState.set_battle_context(npc_name, sentence)
	
	if get_tree():
		get_tree().change_scene_to_file(battle_scene)

func _play_dialogue_sequence(lines: Array, delay: float = 1.6) -> void:
	_set_player_can_move(false)
	
	if typing_choice:
		typing_choice.stop_choices()
	
	for line in lines:
		_show_dialogue(line)
		await get_tree().create_timer(delay).timeout
	
	_hide_dialogue()
