class_name TypingChoice2D
extends Node2D

signal choice_completed(index: int, word: String)

@export var options: Array[String] = ["grab", "eat"]

@onready var option_labels: Array[RichTextLabel] = [
	$Option0,
	$Option1,
]

var selected_index: int = 0
var typed_counts: Array[int] = []
var active: bool = false

var typed_color: String = "#000000"
var remaining_color: String = "#ffffff"


func _ready() -> void:
	# clamp options to number of labels
	if options.size() > option_labels.size():
		options.resize(option_labels.size())

	typed_counts.clear()
	for i in range(options.size()):
		typed_counts.append(0)

	for i in range(option_labels.size()):
		option_labels[i].visible = i < options.size()

	visible = false
	set_process_input(false)
	_update_labels()


func start_choices() -> void:
	selected_index = 0
	for i in range(typed_counts.size()):
		typed_counts[i] = 0

	active = true
	visible = true
	set_process_input(true)
	_update_labels()
	
	if get_tree():
		get_tree().call_group("player", "set_can_move", false)


func stop_choices() -> void:
	active = false
	visible = false
	set_process_input(false)
	
	if get_tree():
		get_tree().call_group("player", "set_can_move", true)


func _input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed:
		var e = event as InputEventKey

		if e.keycode == KEY_ESCAPE:
			stop_choices()
			return

		if e.keycode == KEY_UP:
			_change_selection(-1)
			return
		elif e.keycode == KEY_DOWN:
			_change_selection(1)
			return

		if e.unicode != 0:
			var ch = char(e.unicode)
			_handle_char(ch)


func _change_selection(dir: int) -> void:
	if options.size() <= 1:
		return

	selected_index += dir
	if selected_index < 0:
		selected_index = options.size() - 1
	elif selected_index >= options.size():
		selected_index = 0

	typed_counts[selected_index] = 0
	_update_labels()


func _handle_char(ch: String) -> void:
	var word = options[selected_index]
	var lower_word = word.to_lower()
	var typed = typed_counts[selected_index]

	if typed >= lower_word.length():
		return

	var expected = lower_word[typed]
	if ch.to_lower() == expected:
		typed_counts[selected_index] += 1
		_update_labels()

		if typed_counts[selected_index] >= lower_word.length():
			choice_completed.emit(selected_index, word)
			stop_choices() 


func _update_labels() -> void:
	for i in range(options.size()):
		var label = option_labels[i]
		var word = options[i]
		var typed = clamp(typed_counts[i], 0, word.length())
		var is_selected = (i == selected_index)

		label.clear()
		label.append_text(_format_word(word, typed, is_selected))


func _format_word(word: String, typed_count: int, is_selected: bool) -> String:
	var before = word.substr(0, typed_count)
	var after = ""
	if typed_count < word.length():
		after = word.substr(typed_count)

	var prefix = "> " if is_selected else "  "

	var bbcode = prefix

	if not before.is_empty():
		bbcode += "[color=%s]%s[/color]" % [typed_color, before]

	if not after.is_empty():
		bbcode += "[color=%s]%s[/color]" % [remaining_color, after]

	return bbcode


func set_word(new_word: String) -> void:
	options = [new_word]
	
	typed_counts.clear()
	for i in range(options.size()):
		typed_counts.append(0)
	
	for i in range(option_labels.size()):
		option_labels[i].visible = i < options.size()

	selected_index = 0
	_update_labels()
