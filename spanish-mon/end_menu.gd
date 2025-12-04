extends Control
class_name EndMenu

@onready var message_label: RichTextLabel = $CenterContainer/MessageLabel

var is_victory: bool = false
var typed_text: String = ""
var target_text: String = ""

const TYPED_COLOR := "#4CAF50"      # Green
const REMAINING_COLOR := "#ffffff"  # White 

func _ready() -> void:
	is_victory = GlobalGameState.ship_pieces_collected >= GlobalGameState.TOTAL_SHIP_PIECES
	
	if is_victory:
		target_text = "play again"
	else:
		target_text = "retry"
	
	_update_label()

func _update_label() -> void:
	if not message_label:
		return
	
	var typed_count = typed_text.length()
	var before := target_text.substr(0, typed_count)
	var after := target_text.substr(typed_count) if typed_count < target_text.length() else ""
	
	var display_text := ""
	if not before.is_empty():
		display_text += "[color=%s]%s[/color]" % [TYPED_COLOR, before]
	if not after.is_empty():
		display_text += "[color=%s]%s[/color]" % [REMAINING_COLOR, after]
	
	message_label.clear()
	message_label.append_text(display_text)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.unicode != 0:
		var ch := char(event.unicode)
		_handle_typed_char(ch)

func _handle_typed_char(ch: String) -> void:
	if typed_text.length() >= target_text.length():
		return
	
	var expected := target_text[typed_text.length()]
	
	if ch.to_lower() == expected.to_lower():
		typed_text += expected
		_update_label()
		
		if typed_text.length() >= target_text.length():
			await get_tree().create_timer(0.3).timeout
			_restart_game()

func _restart_game() -> void:
	GlobalGameState.reset_game()
	
	if get_tree():
		get_tree().change_scene_to_file("res://intro.tscn")
