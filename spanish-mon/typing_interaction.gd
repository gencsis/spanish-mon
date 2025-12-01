extends Control

signal word_completed(option_index: int, word: String)
signal typing_cancelled()
signal option_changed(option_index: int)
signal letter_changed(current_index: int, letter: String)

@onready var prompt_label: Label = $PanelContainer/VBoxContainer/PromptLabel
@onready var options_container: HBoxContainer = $PanelContainer/VBoxContainer/OptionsContainer
@onready var option0_label: Label = $PanelContainer/VBoxContainer/OptionsContainer/Option0
@onready var option1_label: Label = $PanelContainer/VBoxContainer/OptionsContainer/Option1
@onready var typed_label: RichTextLabel = $PanelContainer/VBoxContainer/TypedLabel

# Colors as hex strings – you can tweak these easily
var typed_color: String = "#ffffff"      # letters already typed
var current_color: String = "#ffd700"    # current letter to type
var remaining_color: String = "#888888"  # letters not typed yet

var options: Array[String] = []
var current_option_index: int = 0
var current_char_index: int = 0
var active: bool = false


func _ready() -> void:
	visible = false
	set_process_input(false)


# Call this when you want to show the typing UI.
# Example: start_with_options(["grab", "eat"])
func start_with_options(words: Array[String]) -> void:
	if words.is_empty():
		push_warning("TypingInteraction: No words provided to start_with_options().")
		return

	options = words
	current_option_index = 0
	current_char_index = 0
	active = true

	_update_option_labels()
	_update_typed_label()

	visible = true
	set_process_input(true)
	grab_focus()  # let this control receive keyboard input

	option_changed.emit(current_option_index)


func stop() -> void:
	active = false
	set_process_input(false)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed:
		var e := event as InputEventKey

		# Cancel with Escape
		if e.keycode == KEY_ESCAPE:
			typing_cancelled.emit()
			stop()
			return

		# Change option with left/right/up/down
		if e.keycode in [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]:
			_change_option(e.keycode)
			return

		# Confirm word finish with Enter (optional – you can rely on full typing instead)
		if e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER:
			# only emit if fully typed
			if current_char_index >= options[current_option_index].length():
				word_completed.emit(current_option_index, options[current_option_index])
				# You can leave it active or stop; here I stop it:
				stop()
			return
			
		# Detect arrow keys as characters
		match e.keycode:
			KEY_UP:
				_handle_typed_char("↑")
				return
			KEY_DOWN:
				_handle_typed_char("↓")
				return
			KEY_LEFT:
				_handle_typed_char("←")
				return
			KEY_RIGHT:
				_handle_typed_char("→")
				return

		# Handle actual character typing
		if e.unicode != 0:
			var char_typed := char(e.unicode).to_lower()
			_handle_typed_char(char_typed)
			
			


func _change_option(keycode: Key) -> void:
	if options.size() <= 1:
		return

	# Simple toggle between two options for now
	if keycode in [KEY_LEFT, KEY_UP]:
		current_option_index = (current_option_index - 1 + options.size()) % options.size()
	elif keycode in [KEY_RIGHT, KEY_DOWN]:
		current_option_index = (current_option_index + 1) % options.size()

	# Reset typing progress when changing option
	current_char_index = 0
	_update_option_labels()
	_update_typed_label()
	option_changed.emit(current_option_index)


func _handle_typed_char(char_typed: String) -> void:
	var word := options[current_option_index]
	var word_lower := word.to_lower()

	if current_char_index >= word_lower.length():
		# Already fully typed; ignore extra input
		return

	var expected := word_lower[current_char_index]

	if char_typed == expected:
		current_char_index += 1
		_update_typed_label()
		letter_changed.emit(current_char_index, char_typed)

		# If fully typed, emit signal
		if current_char_index >= word_lower.length():
			word_completed.emit(current_option_index, word)
			# Do NOT stop here if you want another script to decide.
			# If you want this UI to auto-close when done, uncomment:
			# stop()
	else:
		# Wrong letter – you could add feedback here (shake, color flash, etc.)
		# For now, we just ignore it.
		pass


func _update_option_labels() -> void:
	# For now this assumes exactly two options; you can generalize later.
	if options.size() >= 1:
		option0_label.text = _format_option_label(options[0], 0)
	if options.size() >= 2:
		option1_label.text = _format_option_label(options[1], 1)


func _format_option_label(word: String, index: int) -> String:
	# Put a ">" in front of the selected option
	if index == current_option_index:
		return "> " + word
	return "  " + word


func _update_typed_label() -> void:
	var word := options[current_option_index]
	var before := word.substr(0, current_char_index)
	var current := ""
	var after := ""

	if current_char_index < word.length():
		current = word.substr(current_char_index, 1)
		if current_char_index + 1 < word.length():
			after = word.substr(current_char_index + 1)
	# else: fully typed – only 'before' will have content

	var bbcode := ""
	if not before.is_empty():
		bbcode += "[color=%s]%s[/color]" % [typed_color, before]
	if not current.is_empty():
		bbcode += "[color=%s]%s[/color]" % [current_color, current]
	if not after.is_empty():
		bbcode += "[color=%s]%s[/color]" % [remaining_color, after]

	typed_label.clear()
	typed_label.append_text(bbcode)
