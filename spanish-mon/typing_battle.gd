extends Control
class_name TypingBattle

@onready var sentence_label: RichTextLabel = $TextBox/SentenceLabel
@onready var enemy_timer: Timer = $EnemyTimer
@onready var timer_label: Label = $TimeLabel
@onready var sfx_loseHeart = $sfx_loseHeart
@onready var sfx_winBattle = $sfx_winBattle
@onready var sfx_loseBattle = $sfx_loseBattle

@onready var heart_icons: Array[TextureRect] = [
	$Hearts/Heart,
	$Hearts/Heart2,
	$Hearts/Heart3,
]

# TODO: change these to your actual paths
const FULL_HEART  = preload("res://Assets/UI/hearts_one1.png")
const EMPTY_HEART = preload("res://Assets/UI/hearts_one2.png")

@export_multiline var sentence: String = "wild creature appeared type this fast"

var player_index: int = 0
var enemy_index: int = 0
var battle_active: bool = true

var max_hearts: int = 3
var hearts: int = 3

const PLAYER_TYPED_COLOR := "#ffffff"
const PLAYER_REMAIN_COLOR := "#000000"
const CURRENT_CHAR_COLOR := "#2E6F40"   # highlighted letter

func _ready() -> void:
	player_index = 0
	enemy_index = 0
	battle_active = true

	hearts = max_hearts
	_update_hearts()

	_update_sentence_label()
	_update_timer_label()

	enemy_timer.timeout.connect(_on_enemy_timer_timeout)
	enemy_timer.start()


func _unhandled_input(event: InputEvent) -> void:
	if not battle_active:
		return
	
	if event is InputEventKey and event.pressed and event.unicode != 0:
		var ch := char(event.unicode)
		_handle_player_char(ch)
		
	#code if you want arrow keys as typing inputs
	#if event is InputEventKey and event.pressed:
		#var e:= event as InputEventKey
		#match e.keycode:
			#KEY_UP:
				#_handle_player_char("↑")
				#return
			#KEY_DOWN:
				#_handle_player_char("↓")
				#return
			#KEY_LEFT:
				#_handle_player_char("←")
				#return
			#KEY_RIGHT:
				#_handle_player_char("→")
				#return
		#if e.unicode != 0:
			#var ch := char(e.unicode)
			#_handle_player_char(ch)
		
		


func _handle_player_char(ch: String) -> void:
	if player_index >= sentence.length():
		return

	var expected := sentence[player_index]

	if ch.to_lower() == expected.to_lower():
		player_index += 1
		_update_sentence_label()

		if player_index >= sentence.length():
			_on_player_wins()
	else:
		_lose_heart()


func _on_enemy_timer_timeout() -> void:
	if not battle_active:
		return

	if enemy_index < sentence.length():
		enemy_index += 1
		_update_timer_label()

		if enemy_index >= sentence.length() and player_index < sentence.length():
			_on_enemy_wins()




func _update_sentence_label() -> void:
	var len := sentence.length()
	var typed_count = clamp(player_index, 0, len)

	var before := sentence.substr(0, typed_count)
	var current_char := ""
	var after := ""

	if typed_count < len:
		current_char = sentence[typed_count]
		if typed_count + 1 < len:
			after = sentence.substr(typed_count + 1)

	var bb := ""

	# already typed letters
	if not before.is_empty():
		bb += "[color=%s]%s[/color]" % [PLAYER_TYPED_COLOR, before]

	# current letter – highlighted + underlined
	if not current_char.is_empty():
		bb += "[color=%s][u]%s[/u][/color]" % [CURRENT_CHAR_COLOR, current_char]

	# remaining
	if not after.is_empty():
		bb += "[color=%s]%s[/color]" % [PLAYER_REMAIN_COLOR, after]

	sentence_label.text = bb


func _update_timer_label() -> void:
	# Time left until the enemy finishes, based on its progress & speed
	var remaining_chars := sentence.length() - enemy_index
	var time_left = max(0.0, float(remaining_chars) * enemy_timer.wait_time)
	timer_label.text = "Time: %.1f" % time_left


func _update_hearts() -> void:
	hearts = clamp(hearts, 0, max_hearts)
	for i in range(heart_icons.size()):
		heart_icons[i].texture = FULL_HEART if i < hearts else EMPTY_HEART

func _lose_heart() -> void:
	hearts -= 1
	_update_hearts()
	sfx_loseHeart.play()
	
	if hearts <= 0:
		_on_enemy_wins()


func _on_player_wins() -> void:
	battle_active = false
	enemy_timer.stop()
	sentence_label.text = "[color=#ffffff]You won the battle![/color]"
	_update_timer_label()
	sfx_winBattle.play()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game_level.tscn")


func _on_enemy_wins() -> void:
	battle_active = false
	enemy_timer.stop()
	sentence_label.text = "[color=#ff5555]You lost the battle...[/color]"
	_update_timer_label()
	sfx_loseBattle.play()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
