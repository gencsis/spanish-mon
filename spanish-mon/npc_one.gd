extends StaticBody2D

@onready var typing_choice: TypingChoice2D = $TypingChoice
@onready var area: Area2D = $Area2D
@onready var bubble: DialogueBubble2D = $DialogueBubble

func _ready() -> void:
	typing_choice.choice_completed.connect(_on_choice_completed)
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	bubble.hide_bubble()


func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		typing_choice.start_choices()   # shows "talk"


func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		typing_choice.stop_choices()
		bubble.hide_bubble()


func _on_choice_completed(index: int, word: String) -> void:
	if word.to_lower() == "talk":
		_start_dialogue()


func _start_dialogue() -> void:
	bubble.show_text("hello, who are you?")
