extends Node2D

@onready var image := $Sprite2D
@onready var anim := $AnimationPlayer
@onready var skip : Label = $CanvasLayer/SkipLabel

var frames = [
	preload("res://Assets/intro-animation/intro-1.png"),
	preload("res://Assets/intro-animation/intro-2.png"),
	preload("res://Assets/intro-animation/intro-3.png"),
	preload("res://Assets/intro-animation/intro-4.png"),
	preload("res://Assets/intro-animation/intro-5.png"),
	preload("res://Assets/intro-animation/intro-6.png"),
	preload("res://Assets/intro-animation/intro-7.png"),
	preload("res://Assets/intro-animation/intro-8.png"),
	preload("res://Assets/intro-animation/intro-9.png"),
	preload("res://Assets/intro-animation/intro-10.png"),
	preload("res://Assets/intro-animation/intro-11.png"),
	preload("res://Assets/intro-animation/intro-12.png"),
]

func _ready() -> void:
	GlobalGameState.reset_game()
	
	image.texture = frames[0]
	_viewport_adjustments()
	anim.play("intro")
	skip.visible = true
	
func set_intro_frame(index: int) -> void:
	if index >= 0 and index < frames.size():
		image.texture = frames[index]
	
func _intro_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		_start_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		_skip_with_any_input(event)

func _skip_with_any_input(event: InputEvent) -> void:
	_start_game()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		_start_game()

func _start_game() -> void:
	skip.visible = false
	get_tree().change_scene_to_file("res://Scenes/game_level.tscn")

func _viewport_adjustments() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	var img_size: Vector2 = frames[0].get_size()
	
	var factor : float = max(
		viewport_size.x / img_size.x,
		viewport_size.y / img_size.y
		)
	
	image.scale = Vector2(factor, factor)
	image.position = viewport_size / 2.0
