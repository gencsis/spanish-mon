extends Node2D

@onready var asp = $Music
@onready var player: Node2D = $Characters/PlayerAxol

var volume = -10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pos := GlobalGameState.get_player_return_position()
	player.global_position = pos

	for name in GlobalGameState.npcs.keys():
		var data = GlobalGameState.npcs[name]
		var npc = load(data["scene_path"]).instantiate()
		npc.name = name
		npc.global_position = data["position"]
		add_child(npc)
	AudioServer.set_bus_volume_db(0, volume)
	asp.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		asp.stream_paused = !asp.stream_paused


func _on_audio_stream_player_finished() -> void:
	asp.play()
