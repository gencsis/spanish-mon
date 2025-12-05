extends Control
class_name EndMenu

@onready var message_label: RichTextLabel = $CenterContainer/MessageLabel

var is_victory: bool = false

var options: Array[String] = []
var selected_index: int = 0
var typed_text: String = ""

const TYPED_COLOR := "#4CAF50"      # green
const REMAINING_COLOR := "#ffffff"  # white

func _ready() -> void:
	is_victory = GlobalGameState.ship_pieces_collected >= GlobalGameState.TOTAL_SHIP_PIECES
	
	if is_victory:
		options = ["play again", "main menu"]
	else:
		options = ["retry", "main menu"]
	
	selected_index = 0
	typed_text = ""
	_update_label()


func _update_label() -> void:
	if not message_label:
		return
	
	var display_text := ""
	
	for i in options.size():
		var option_text := options[i]
		var is_selected := (i == selected_index)
		
		var prefix := "▶ " if is_selected else "  "
		
		if is_selected:
			var typed_count := typed_text.length()
			typed_count = min(typed_count, option_text.length())
			
			var before := option_text.substr(0, typed_count)
			var after := option_text.substr(typed_count)
			
			if not before.is_empty():
				display_text += prefix + "[color=%s]%s[/color]" % [TYPED_COLOR, before]
			if not after.is_empty():
				if before.is_empty():
					display_text += prefix
				display_text += "[color=%s]%s[/color]" % [REMAINING_COLOR, after]
		else:
			display_text += prefix + "[color=%s]%s[/color]" % [REMAINING_COLOR, option_text]
		
		if i < options.size() - 1:
			display_text += "\n"
	
	message_label.clear()
	message_label.append_text(display_text)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		_change_selection(1)
		return
	if event.is_action_pressed("ui_up"):
		_change_selection(-1)
		return
	
	if event is InputEventKey and event.pressed and event.unicode != 0:
		var ch := char(event.unicode)
		_handle_typed_char(ch)


func _change_selection(delta: int) -> void:
	if options.is_empty():
		return
	
	selected_index = (selected_index + delta + options.size()) % options.size()
	typed_text = "" 
	_update_label()


func _handle_typed_char(ch: String) -> void:
	if options.is_empty():
		return
	
	var target_text := options[selected_index]
	
	if typed_text.length() >= target_text.length():
		return
	
	var expected := target_text[typed_text.length()]
	
	if ch.to_lower() == expected.to_lower():
		typed_text += expected
		_update_label()
		
		if typed_text.length() >= target_text.length():
			await get_tree().create_timer(0.3).timeout
			_handle_completed_option()


func _handle_completed_option() -> void:
	if options.is_empty():
		return
	
	var choice := options[selected_index].to_lower()
	
	if choice == "main menu":
		_go_to_main_menu()
	else:
		_restart_game()


func _restart_game() -> void:
	GlobalGameState.reset_game()
	if get_tree():
		get_tree().change_scene_to_file("res://intro.tscn")


func _go_to_main_menu() -> void:
	GlobalGameState.reset_game()
	if get_tree():
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
