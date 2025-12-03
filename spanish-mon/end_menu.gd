extends Control

@onready var menu_container: VBoxContainer = $Buttons/Options

var menu_options: Array[String] = ["play again", "main menu", "quit"]
var selected_index: int = 0

var cursor_labels: Array[Label] = []
var option_labels: Array[RichTextLabel] = []
var typed_counts: Array[int] = []

var typed_color: String = "#fff000"
var remaining_color: String = "#ffffff"


func _ready() -> void:
	if menu_container == null:
		push_error("Options not found! Check scene structure / path.")
		return

	_create_menu()
	_update_selection()


func _create_menu() -> void:
	for child in menu_container.get_children():
		child.queue_free()

	cursor_labels.clear()
	option_labels.clear()
	typed_counts.clear()

	for i in range(menu_options.size()):
		typed_counts.append(0)

		var h_container := HBoxContainer.new()
		h_container.alignment = BoxContainer.ALIGNMENT_CENTER
		menu_container.add_child(h_container)

		var cursor := Label.new()
		cursor.text = "►" if i == selected_index else " "
		cursor.add_theme_font_size_override("font_size", 12)
		cursor.custom_minimum_size = Vector2(20, 0)
		h_container.add_child(cursor)
		cursor_labels.append(cursor)

		var option := RichTextLabel.new()
		option.bbcode_enabled = true
		option.autowrap_mode = TextServer.AUTOWRAP_OFF
		option.mouse_filter = Control.MOUSE_FILTER_IGNORE
		option.fit_content = true
		option.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		h_container.add_child(option)
		option_labels.append(option)

		_update_option_label(i)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		_move_selection(-1)
	elif event.is_action_pressed("down"):
		_move_selection(1)
	elif event.is_action_pressed("interact"):
		_confirm_selection()
	elif event is InputEventKey and event.pressed and event.unicode != 0:
		var ch := char(event.unicode)
		_handle_typed_char(ch)


func _move_selection(direction: int) -> void:
	selected_index += direction

	if selected_index < 0:
		selected_index = menu_options.size() - 1
	elif selected_index >= menu_options.size():
		selected_index = 0

	typed_counts[selected_index] = 0
	_update_selection()


func _update_selection() -> void:
	for i in range(cursor_labels.size()):
		cursor_labels[i].text = "►" if i == selected_index else " "

	for i in range(option_labels.size()):
		_update_option_label(i)


func _handle_typed_char(ch: String) -> void:
	var word := menu_options[selected_index]
	var lower := word.to_lower()
	var typed := typed_counts[selected_index]

	if typed >= lower.length():
		return

	var expected := lower[typed]
	if ch.to_lower() == expected:
		typed_counts[selected_index] += 1
		_update_option_label(selected_index)

		if typed_counts[selected_index] >= lower.length():
			_confirm_selection()
	else:
		pass


func _update_option_label(i: int) -> void:
	var word := menu_options[i]
	var typed : int = clamp(typed_counts[i], 0, word.length())

	var before := word.substr(0, typed)
	var after := ""
	if typed < word.length():
		after = word.substr(typed)

	var bbcode := ""

	if not before.is_empty():
		bbcode += "[color=%s]%s[/color]" % [typed_color, before]

	if not after.is_empty():
		bbcode += "[color=%s]%s[/color]" % [remaining_color, after]

	option_labels[i].clear()
	option_labels[i].append_text(bbcode)


func _confirm_selection() -> void:
	match selected_index:
		0: 
			_play_again()
		1:  
			_go_to_main_menu()
		2:  
			_quit_game()


func _play_again() -> void:
	# full game reset
	if GlobalGameState.has_method("reset_game"):
		GlobalGameState.reset_game()
	if GlobalGameState.has_method("clear_saved_player_position"):
		GlobalGameState.clear_saved_player_position()

	if get_tree():
		get_tree().change_scene_to_file("res://intro.tscn")


func _go_to_main_menu() -> void:
	if get_tree():
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")


func _quit_game() -> void:
	get_tree().quit()
