extends Node2D

@onready var asp = $Music

var volume = -10

func _ready() -> void:
	AudioServer.set_bus_volume_db(0, volume)
	asp.play()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		asp.stream_paused = !asp.stream_paused

func _on_audio_stream_player_finished() -> void:
	asp.play()
