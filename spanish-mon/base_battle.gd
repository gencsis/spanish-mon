extends Control
class_name BaseBattle

# Base class for all battle types (typing, unscramble, arrow)
# Handles common functionality: hearts, health, scene transitions, audio

var heart_icons: Array[TextureRect] = []

var sfx_loseHeart: Node
var sfx_winBattle: Node
var sfx_loseBattle: Node

const FULL_HEART = preload("res://Assets/UI/hearts_one1.png")
const EMPTY_HEART = preload("res://Assets/UI/hearts_one2.png")

var max_hearts: int = 3
var hearts: int = 3
var battle_active: bool = true

func _ready() -> void:
	hearts = GlobalGameState.get_current_health()
	max_hearts = GlobalGameState.player_max_health
	_update_hearts()

func _update_hearts() -> void:
	hearts = clamp(hearts, 0, max_hearts)
	for i in range(heart_icons.size()):
		if heart_icons[i]:
			heart_icons[i].texture = FULL_HEART if i < hearts else EMPTY_HEART

func _lose_heart() -> void:
	hearts -= 1
	GlobalGameState.lose_health(1)
	_update_hearts()
	
	if sfx_loseHeart:
		sfx_loseHeart.play()
	
	if hearts <= 0:
		_on_battle_lost()

func _on_battle_won() -> void:
	battle_active = false
	
	if sfx_winBattle:
		sfx_winBattle.play()
	
	_handle_npc_rewards()

	_clear_battle_context()

	await get_tree().create_timer(1.0).timeout
	_return_to_game_level()

func _on_battle_lost() -> void:
	battle_active = false
	
	if sfx_loseBattle:
		sfx_loseBattle.play()
	
	_clear_battle_context()

	await get_tree().create_timer(1.5).timeout
	_go_to_end_screen()

func _handle_npc_rewards() -> void:
	match GlobalGameState.current_battle_npc:
		"aurora":
			GlobalGameState.collect_ship_piece("piece_one")
		"nova":
			GlobalGameState.collect_ship_piece("piece_two")
		"zenith":
			GlobalGameState.collect_ship_piece("piece_three")
		"orion":
			GlobalGameState.mark_npc_defeated("orion")
		_:
			pass

func _clear_battle_context() -> void:
	GlobalGameState.current_battle_npc = ""
	GlobalGameState.current_battle_sentence = ""

func _return_to_game_level() -> void:
	if get_tree():
		get_tree().change_scene_to_file("res://Scenes/game_level.tscn")

func _go_to_end_screen() -> void:
	if get_tree():
		get_tree().change_scene_to_file("res://end_menu.tscn")

func setup_heart_icons(icons: Array[TextureRect]) -> void:
	heart_icons = icons
	_update_hearts()
