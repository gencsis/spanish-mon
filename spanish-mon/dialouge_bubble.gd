class_name DialogueBubble2D
extends Node2D

@onready var bubble: NinePatchRect = $Bubble                
@onready var text_label: RichTextLabel = $Label

@export_multiline var default_text: String = "i need to find her"

func _ready() -> void:
	visible = false
	set_text(default_text)


func set_text(text: String) -> void:
	text_label.text = text
	
	await get_tree().process_frame

	if bubble is NinePatchRect:
		var padding = Vector2(8, 8)
		bubble.size = text_label.get_minimum_size() + padding


func show_text(text: String) -> void:
	set_text(text)
	visible = true


func hide_bubble() -> void:
	visible = false
