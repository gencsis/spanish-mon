extends StaticBody2D
class_name BadNPC

@onready var area: Area2D = $Area2D


enum BattleType {
	TIMED_TYPING,   
	WORD_UNSCRAMBLE,
	ARROW_SEQUENCE
}

@export var battle_type: BattleType = BattleType.TIMED_TYPING


@export_file("*.tscn") var timed_typing_scene: String = "res://typing_battle.tscn"
@export_file("*.tscn") var unscramble_scene: String = "res://unscramble_battle.tscn"
@export_file("*.tscn") var arrow_battle_scene: String = "res://arrow_battle.tscn"

func _ready() -> void:
	area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_start_battle()
		
func _start_battle() -> void:
	var player = get_tree().current_scene.get_node("Characters/PlayerAxol")
	GlobalGameState.player_position = player.global_position + Vector2(0, 20)
	
	 # Save all NPCs
	GlobalGameState.npcs.clear()
	for npc in get_tree().get_nodes_in_group("NPC"):
		GlobalGameState.npcs[npc.name] = {
			"scene_path": "res://Scenes/BadNPC.tscn",
			"position": npc.global_position
			
	}

	var scene_path: String
	match battle_type:
		BattleType.TIMED_TYPING:
			scene_path = timed_typing_scene
		BattleType.WORD_UNSCRAMBLE:
			scene_path = unscramble_scene
		BattleType.ARROW_SEQUENCE:
			scene_path = arrow_battle_scene
	
	if scene_path and scene_path != "":
		get_tree().change_scene_to_file(scene_path)
	else:
		push_error("Not a battle type: ", battle_type)
