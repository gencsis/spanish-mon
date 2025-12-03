extends Node

var ship_pieces_collected: int = 0
const TOTAL_SHIP_PIECES: int = 3

#tracking pieces
var has_piece_one: bool = false
var has_piece_two: bool = false
var has_piece_three: bool = false

var player_max_health: int = 3
var player_current_health: int = 3

signal all_pieces_collected()

func _ready() -> void:
	pass
	
func collect_ship_piece(piece_name: String) -> void:
	match piece_name:
		"piece_one":
			if not has_piece_one:
				has_piece_one = true
				ship_pieces_collected += 1
				print("Piece one collected")
	match piece_name:
		"piece_two":
			if not has_piece_two:
				has_piece_two = true
				ship_pieces_collected += 1
				print("Piece two collected")
	match piece_name:
		"piece_three":
			if not has_piece_three:
				has_piece_three = true
				ship_pieces_collected += 1
				print("Piece three collected")
	
	_check_all_pieces()
	
func _check_all_pieces() -> void:
	if ship_pieces_collected >= TOTAL_SHIP_PIECES:
		all_pieces_collected.emit()
		print("all pieces collected")

func reset_game() -> void:
	ship_pieces_collected = 0
	has_piece_one = false
	has_piece_two = false
	has_piece_three = false
	player_current_health = player_max_health
	
func get_pieces_text() -> String:
	return "Ship Pieces: %d/%d" % [ship_pieces_collected, TOTAL_SHIP_PIECES]
