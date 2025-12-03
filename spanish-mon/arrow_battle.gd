extends Control
class_name ArrowBattle

@onready var instruction_label: Label = $InstructionLabel
@onready var npc_sequence_label: RichTextLabel = $NPCSequenceLabel
@onready var player_input_label: RichTextLabel = $TextBox/InputLabel
@onready var timer_label: Label = $TimeLabel
@onready var round_label: Label = $RoundLabel
@onready var sfx_loseHeart = $sfx_loseHeart
@onready var sfx_winBattle = $sfx_winBattle
@onready var sfx_loseBattle = $sfx_loseBattle

@onready var heart_icons: Array[TextureRect] = [
	$Hearts/Heart,
	$Hearts/Heart2,
	$Hearts/Heart3,
]

@onready var arrow_display: HBoxContainer = $ArrowDisplay

const FULL_HEART  = preload("res://Assets/UI/hearts_one1.png")
const EMPTY_HEART = preload("res://Assets/UI/hearts_one2.png")

@export var starting_sequence_length: int = 3
@export var rounds_to_win: int = 3
@export var time_per_input: float = 1.5

enum BattleState {
	SHOWING_SEQUENCE,
	WAITING_FOR_INPUT,
	BETWEEN_ROUNDS,
	BATTLE_WON,
	BATTLE_LOST
}

var current_state: BattleState = BattleState.SHOWING_SEQUENCE
var current_round: int = 1
var sequence: Array[String] = []
var player_sequence: Array[String] = []
var sequence_index: int = 0

var max_hearts: int = 3
var hearts: int = 3

var time_remaining: float = 0.0
var show_timer: Timer
var battle_active: bool = true

const ARROW_SYMBOLS := {
	"up": "↑",
	"down": "↓",
	"left": "←",
	"right": "→"
}

# randomize color
func random_color() -> String:
	var c := Color.from_hsv(randf(), 1.0, 1.0) 
	return c.to_html(false)  



func _ready() -> void:
	hearts = max_hearts
	_update_hearts()
	battle_active = true
	
	show_timer = Timer.new()
	show_timer.one_shot = false
	add_child(show_timer)
	show_timer.timeout.connect(_on_show_timer_timeout)
	
	instruction_label.text = "Watch this arrow sequence!"
	
	npc_sequence_label.bbcode_enabled = true
	npc_sequence_label.text = "[center][color=yellow]TEST ARROW[/color][/center]"
	_update_round_label()
	_start_round()


func _process(delta: float) -> void:
	if current_state == BattleState.WAITING_FOR_INPUT and battle_active:
		time_remaining -= delta
		_update_timer_label()
		
		if time_remaining <= 0.0:
			_wrong_input()


func _unhandled_input(event: InputEvent) -> void:
	if not battle_active or current_state != BattleState.WAITING_FOR_INPUT:
		return
	
	if event is InputEventKey and event.pressed:
		var e := event as InputEventKey
		var arrow := ""
		
		match e.keycode:
			KEY_UP:
				arrow = "up"
			KEY_DOWN:
				arrow = "down"
			KEY_LEFT:
				arrow = "left"
			KEY_RIGHT:
				arrow = "right"
		
		if arrow != "":
			_handle_arrow_input(arrow)


func _start_round() -> void:
	current_state = BattleState.SHOWING_SEQUENCE
	player_sequence.clear()
	sequence_index = 0
	
	var seq_length := starting_sequence_length + (current_round - 1)
	sequence = _generate_sequence(seq_length)
	
	instruction_label.text = "Watch carefully..."
	player_input_label.text = ""
	npc_sequence_label.text = ""
	
	show_timer.wait_time = 0.6
	show_timer.start()
	sequence_index = 0
	_show_next_arrow()


func _generate_sequence(length: int) -> Array[String]:
	var arrows := ["up", "down", "left", "right"]
	var result: Array[String] = []
	
	for i in range(length):
		result.append(arrows[randi() % arrows.size()])
	
	return result


func _show_next_arrow() -> void:
	if sequence_index >= sequence.size():
		show_timer.stop()
		await get_tree().create_timer(0.5).timeout
		_start_player_input()
		return
	
	var arrow := sequence[sequence_index]
	var symbol: String = ARROW_SYMBOLS[arrow]
	
	var color := random_color() 
	
	npc_sequence_label.text = "[center][color=%s][font_size=72]%s[/font_size][/color][/center]" % [color, symbol]
	sequence_index += 1


func _on_show_timer_timeout() -> void:
	_show_next_arrow()


func _start_player_input() -> void:
	current_state = BattleState.WAITING_FOR_INPUT
	instruction_label.text = "Now repeat the sequence!"
	npc_sequence_label.text = ""
	player_sequence.clear()
	
	time_remaining = sequence.size() * time_per_input
	_update_timer_label()
	_update_player_input_display()


func _handle_arrow_input(arrow: String) -> void:
	if player_sequence.size() >= sequence.size():
		return
	
	player_sequence.append(arrow)
	
	var index := player_sequence.size() - 1
	if arrow != sequence[index]:
		_wrong_input()
		return
	
	_update_player_input_display()
	
	if player_sequence.size() == sequence.size():
		_correct_sequence()


func _update_player_input_display() -> void:
	var bb := "[center]Your input: "
	
	for i in range(sequence.size()):
		if i < player_sequence.size():
			var arrow := player_sequence[i]
			var symbol: String =  ARROW_SYMBOLS[arrow]
			var color := random_color()  
			bb += "[color=%s]%s[/color] " % [color, symbol]
		else:
			bb += "[color=#666666]?[/color] "
	
	bb += "[/center]"
	player_input_label.text = bb


func _correct_sequence() -> void:
	current_state = BattleState.BETWEEN_ROUNDS
	instruction_label.text = "Correct!"
	
	current_round += 1
	_update_round_label()
	
	await get_tree().create_timer(1.5).timeout
	
	if current_round > rounds_to_win:
		_on_player_wins()
	else:
		_start_round()


func _wrong_input() -> void:
	_lose_heart()
	sfx_loseHeart.play()
	
	if hearts > 0:
		instruction_label.text = "Wrong! Try again..."
		player_input_label.text = "[center][color=#ff5555]Incorrect![/color][/center]"
		
		await get_tree().create_timer(1.5).timeout
		_start_player_input()


func _update_timer_label() -> void:
	timer_label.text = "Time: %.1f" % max(0.0, time_remaining)


func _update_round_label() -> void:
	round_label.text = "Round: %d/%d" % [min(current_round, rounds_to_win), rounds_to_win]


func _update_hearts() -> void:
	hearts = clamp(hearts, 0, max_hearts)
	for i in range(heart_icons.size()):
		heart_icons[i].texture = FULL_HEART if i < hearts else EMPTY_HEART


func _lose_heart() -> void:
	hearts -= 1
	_update_hearts()
	
	if hearts <= 0:
		_on_player_loses()


func _on_player_wins() -> void:
	current_state = BattleState.BATTLE_WON
	battle_active = false
	sfx_winBattle.play()
	instruction_label.text = "Victory!"
	player_input_label.text = "[center][color=#00ff00]You mastered the dance![/color]\n[color=#ffff00]Ship Piece Acquired![/color][/center]"
	npc_sequence_label.text = ""
	
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://Scenes/game_level.tscn")


func _on_player_loses() -> void:
	current_state = BattleState.BATTLE_LOST
	battle_active = false
	sfx_loseBattle.play()
	instruction_label.text = "Defeated!"
	player_input_label.text = "[center][color=#ff5555]You couldn't keep up with the dance...[/color][/center]"
	npc_sequence_label.text = ""
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
