extends StaticBody2D
class_name BadNPC

@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var bubble: DialogueBubble2D = $DialogueBubble
@onready var typing_choice: TypingChoice2D = $TypingChoice

enum BattleType {
	TIMED_TYPING,
	WORD_UNSCRAMBLE,
	ARROW_SEQUENCE
}

@export var battle_type: BattleType = BattleType.TIMED_TYPING
@export var dialogue_duration: float = 2.0
@export var npc_unique_id: String = ""

@export var sentence_pool: Array[String] = [
	"[The quick brown fox jumps over the lazy dog.]",
	"[He was surprised that his immense laziness was inspirational to others.]",
	"[I really want to go to work, but I am too sick to drive.]",
	"[His ultimate dream fantasy consisted of being content and sleeping eight hours in a row.]",
	"[It was her first experience training a rainbow unicorn!]"
]

@export_multiline var pre_battle_dialogue: String = ""
@export_multiline var after_battle_dialogue: String = "[You already beat me!]"

@export_file("*.tscn") var timed_typing_scene: String = "res://typing_battle.tscn"
@export_file("*.tscn") var unscramble_scene: String = "res://unscramble_battle.tscn"
@export_file("*.tscn") var arrow_battle_scene: String = "res://arrow_battle.tscn"

var has_triggered: bool = false
var chosen_sentence: String = ""
var is_defeated: bool = false
var scene_path: String = ""


func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)

	if typing_choice:
		typing_choice.choice_completed.connect(_on_talk_chosen)

	if bubble:
		bubble.hide_bubble()

	if sprite:
		sprite.visible = false

	if npc_unique_id != "":
		is_defeated = GlobalGameState.is_npc_defeated(npc_unique_id)
		if is_defeated:
			if sprite:
				sprite.visible = true

	_choose_random_sentence()


func _choose_random_sentence() -> void:
	if pre_battle_dialogue != "":
		chosen_sentence = pre_battle_dialogue
	elif sentence_pool.size() > 0:
		chosen_sentence = sentence_pool[randi() % sentence_pool.size()]
	else:
		chosen_sentence = "[The quick brown fox jumps over the lazy dog.]"


func _on_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	_start_interaction()


func _start_interaction() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		GlobalGameState.player_position = player.global_position + Vector2(0, 20)

	if has_triggered:
		return

	if sprite:
		sprite.visible = true

	if is_defeated:
		_show_already_defeated_message()
		return

	if typing_choice:
		typing_choice.options = ["talk"]
		typing_choice.start_choices()


func _on_area_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if not has_triggered:
		if typing_choice:
			typing_choice.stop_choices()
		if bubble:
			bubble.hide_bubble()

		if not is_defeated and sprite:
			sprite.visible = false


func _on_talk_chosen(index: int, word: String) -> void:
	if word.to_lower() != "talk":
		return

	if is_defeated:
		_show_already_defeated_message()
	else:
		has_triggered = true
		_show_dialogue_then_battle()


func _show_already_defeated_message() -> void:
	if bubble:
		bubble.show_text(after_battle_dialogue)

	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)


func _show_dialogue_then_battle() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		GlobalGameState.save_player_position(player.global_position)
		if player.has_method("set_can_move"):
			player.set_can_move(false)

	if bubble and chosen_sentence != "":
		bubble.show_text(chosen_sentence)
		await get_tree().create_timer(dialogue_duration).timeout

	if npc_unique_id != "":
		GlobalGameState.mark_npc_defeated(npc_unique_id)

	scene_path = ""

	match battle_type:
		BattleType.TIMED_TYPING:
			scene_path = timed_typing_scene
			GlobalGameState.set_battle_context("random", chosen_sentence)
		BattleType.WORD_UNSCRAMBLE:
			scene_path = unscramble_scene
			GlobalGameState.set_battle_context("random_unscramble", "")
		BattleType.ARROW_SEQUENCE:
			scene_path = arrow_battle_scene
			GlobalGameState.set_battle_context("random_arrow", "")

	if scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Not a valid battle type: ", battle_type)
		if player and player.has_method("set_can_move"):
			player.set_can_move(true)
