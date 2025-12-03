extends Node

var ship_pieces_collected: int = 0
const TOTAL_SHIP_PIECES: int = 3

# Tracking pieces
var has_piece_one: bool = false
var has_piece_two: bool = false
var has_piece_three: bool = false

# Health tracking
var player_max_health: int = 3
var player_current_health: int = 3

signal all_pieces_collected()
signal health_changed(new_health: int)

# Battle context
var current_battle_npc: String = ""
var current_battle_sentence: String = ""

# Player position tracking 
var player_last_position: Vector2 = Vector2.ZERO
var player_spawn_position: Vector2 = Vector2(100, 100)

var defeated_npcs: Array[String] = []

func _ready() -> void:
	player_current_health = player_max_health

func collect_ship_piece(piece_name: String) -> void:
	match piece_name:
		"piece_one":
			if not has_piece_one:
				has_piece_one = true
				ship_pieces_collected += 1
				print("Piece one collected! Total: ", ship_pieces_collected)
		"piece_two":
			if not has_piece_two:
				has_piece_two = true
				ship_pieces_collected += 1
				print("Piece two collected! Total: ", ship_pieces_collected)
		"piece_three":
			if not has_piece_three:
				has_piece_three = true
				ship_pieces_collected += 1
				print("Piece three collected! Total: ", ship_pieces_collected)
	
	_check_all_pieces()

func _check_all_pieces() -> void:
	if ship_pieces_collected >= TOTAL_SHIP_PIECES:
		all_pieces_collected.emit()
		print("All pieces collected!")

func reset_game() -> void:
	"""Call this when starting a NEW game (from main menu)"""
	ship_pieces_collected = 0
	has_piece_one = false
	has_piece_two = false
	has_piece_three = false
	player_current_health = player_max_health
	current_battle_npc = ""
	current_battle_sentence = ""
	defeated_npcs.clear()
	player_last_position = player_spawn_position
	health_changed.emit(player_current_health)
	print("Game reset! Health: ", player_current_health)

func get_pieces_text() -> String:
	return "Ship Pieces: %d/%d" % [ship_pieces_collected, TOTAL_SHIP_PIECES]

func set_battle_context(npc_name: String, sentence: String = "") -> void:
	current_battle_npc = npc_name
	current_battle_sentence = sentence

func lose_health(amount: int = 1) -> void:
	player_current_health = max(0, player_current_health - amount)
	health_changed.emit(player_current_health)
	print("Lost health! Current: ", player_current_health)

func gain_health(amount: int = 1) -> void:
	player_current_health = min(player_max_health, player_current_health + amount)
	health_changed.emit(player_current_health)
	print("Gained health! Current: ", player_current_health)

func get_current_health() -> int:
	return player_current_health

func is_dead() -> bool:
	return player_current_health <= 0

func save_player_position(pos: Vector2) -> void:
	player_last_position = pos
	print("Saved player position: ", pos)

func get_player_return_position() -> Vector2:
	return player_last_position

func mark_npc_defeated(npc_name: String) -> void:
	if not defeated_npcs.has(npc_name):
		defeated_npcs.append(npc_name)
		print("Marked NPC as defeated: ", npc_name)

func is_npc_defeated(npc_name: String) -> bool:
	return defeated_npcs.has(npc_name)
