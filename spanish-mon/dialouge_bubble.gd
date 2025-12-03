class_name DialogueBubble2D
extends Node2D

@onready var bubble: NinePatchRect = $Bubble
@onready var label: Label = $Label

@export var mouth_offset := Vector2(0, -28)
@export_multiline var default_text := "i need to find her"
@export var padding := Vector2(4, 4)

@export var use_screen_top: bool = false
@export var screen_top_offset: Vector2 = Vector2(480, 50)  

func _ready() -> void:
	visible = false

	if use_screen_top:

		global_position = screen_top_offset
	else:

		position = mouth_offset

	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = false
	label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bubble.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bubble.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if default_text != "" and default_text != "i need to find her":
		say(default_text)

func say(text: String) -> void:
	label.text = text
	await get_tree().process_frame
	
	var text_size := label.get_minimum_size()
	
	label.position = padding
	bubble.size = text_size + padding * 2
	
	visible = true

func show_text(text: String) -> void:
	say(text)

func hide_bubble() -> void:
	visible = false
