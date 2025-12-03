extends Control
class_name UnscrambleBattle

@onready var instruction_label: Label = $InstructionLabel
@onready var scrambled_label: RichTextLabel = $Textbox/ScrambledLabel
@onready var timer_label: Label = $TimeLabel

@onready var heart_icons: Array[TextureRect] = [
	$Hearts/Heart,
	$Hearts/Heart2,
	$Hearts/Heart3,
]

const FULL_HEART  = preload("res://Assets/UI/hearts_one1.png")
const EMPTY_HEART = preload("res://Assets/UI/hearts_one2.png")

# unscrambled word
@export var word_list: Array[String] = ["apple", "pineapple", "peach"]

@export var battle_timer: float = 30.0

var target_word: String = ""
var scrambled_word: String = ""
var player_input: String = ""
var battle_active: bool = true
var time_remaining: float = 0.0

var max_hearts: int = 3
var hearts: int = 3

var current_round: int = 0
var total_rounds: int = 3

const TYPED_COLOR := "#ffffff"
const REMAINING_COLOR := "#888888"
const CURRENT_CHAR_COLOR := "#2E6F40"

func _ready() -> void:
	hearts = max_hearts
	_update_hearts()
	
	total_rounds = word_list.size()
	current_round = 0
	_start_round()

func _start_round() -> void:
	if current_round >= word_list.size():
		_on_player_wins()
		return
	
	target_word = word_list[current_round]
	scrambled_word = _scramble_word(target_word)
	player_input = ""
	battle_active = true
	time_remaining = battle_timer
	
	instruction_label.text = "Unscramble this word to get the ship piece! (Round %d/%d)" \
	% [current_round + 1, total_rounds]
	
	_update_scrambled_label()
	_update_timer_label()

func _process(delta: float) -> void:
	if not battle_active:
		return
		
	time_remaining -= delta
	_update_timer_label()
	
	if time_remaining <= 0.0:
		_on_time_runs_out()

func _unhandled_input(event: InputEvent) -> void:
	if not battle_active:
		return
	
	if event is InputEventKey and event.pressed:
		var e := event as InputEventKey
		
		if e.keycode == KEY_BACKSPACE:
			if player_input.length() > 0:
				player_input = player_input.substr(0, player_input.length() - 1)
				_update_scrambled_label()
			return
		
		if e.keycode == KEY_ENTER or e.keycode == KEY_KP_ENTER:
			await _check_answer()
			return
		
		if e.unicode != 0:
			var ch := char(e.unicode).to_lower()

			if ch >= 'a' and ch <= 'z':
				if player_input.length() < target_word.length():
					player_input += ch
					_update_scrambled_label()
					
					if player_input.length() == target_word.length():
						await _check_answer()

func _scramble_word(word: String) -> String:
	var chars := []
	for i in range(word.length()):
		chars.append(word[i])
	
	# Fisher-Yates shuffle (from: https://www.geeksforgeeks.org/dsa/shuffle-a-given-array-using-fisher-yates-shuffle-algorithm/
	for i in range(chars.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var temp = chars[i]
		chars[i] = chars[j]
		chars[j] = temp
	
	var result := ""
	for c in chars:
		result += c
	
	# Make sure it's actually scrambled
	if result == word and word.length() > 1:
		return _scramble_word(word)
	
	return result

func _update_scrambled_label() -> void:
	var bb := ""
	
	bb += "[center]Scrambled: [color=#ffaa00]%s[/color][/center]\n\n" % scrambled_word
	
	bb += "[center]Your answer: "
	
	if player_input.is_empty():
		bb += "[color=%s]%s[/color]" % [REMAINING_COLOR, "_".repeat(target_word.length())]
	else:
		bb += "[color=%s]%s[/color]" % [TYPED_COLOR, player_input]
		
		var remaining := target_word.length() - player_input.length()
		if remaining > 0:
			bb += "[color=%s]%s[/color]" % [REMAINING_COLOR, "_".repeat(remaining)]
	
	bb += "[/center]"
	
	scrambled_label.text = bb

func _update_timer_label() -> void:
	timer_label.text = "Time: %.1f" % max(0.0, time_remaining)

func _update_hearts() -> void:
	hearts = clamp(hearts, 0, max_hearts)
	for i in range(heart_icons.size()):
		heart_icons[i].texture = FULL_HEART if i < hearts else EMPTY_HEART

func _lose_heart() -> void:
	hearts -= 1
	_update_hearts()
	
	
	if hearts <= 0:
		_on_player_loses()

func _check_answer() -> void:
	if player_input.to_lower() == target_word.to_lower():
		battle_active = false
		scrambled_label.text = "[center][color=#00ff00]Correct![/color][/center]"
		
		current_round += 1
		if current_round >= total_rounds:
			await get_tree().create_timer(1.0).timeout
			_on_player_wins()
		else:
			instruction_label.text = "Wow! Next word!"
			await get_tree().create_timer(1.0).timeout
			_start_round()
	else:
		_lose_heart()
		
		if hearts > 0:
			player_input = ""
			_update_scrambled_label()

func _on_player_wins() -> void:
	battle_active = false
	scrambled_label.text = "[center][color=#00ff00]Correct! You got the ship piece![/color][/center]"
	instruction_label.text = "Ship Piece Acquired!"
	
	# TODO: Add the ship piece to inventory here
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game_level.tscn")

func _on_player_loses() -> void:
	battle_active = false
	scrambled_label.text = "[center][color=#ff5555]You failed to unscramble the word...[/color][/center]"
	instruction_label.text = "Mission Failed"
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

func _on_time_runs_out() -> void:
	battle_active = false
	scrambled_label.text = "[center][color=#ff5555]Time's up![/color][/center]"
	instruction_label.text = "Out of Time"
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
