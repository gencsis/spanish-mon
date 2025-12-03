class_name ScreenDialogue
extends CanvasLayer

@onready var bubble: NinePatchRect = $Control/Bubble
@onready var label: Label = $Control/Bubble/Label

@export var padding := Vector2(8, 6)

func _ready() -> void:
	visible = false

	layer = 100
	
	if label:
		label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if bubble:
		bubble.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func show_text(text: String) -> void:
	if label:
		label.text = text
	
	visible = true

func hide_dialogue() -> void:
	visible = false
