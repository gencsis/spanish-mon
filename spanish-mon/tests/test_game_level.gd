extends GutTest

var level

func before_each():
	var scene = load("res://Phases/game_level.tscn")
	level = scene.instantiate()

func test_level_has_player():
	assert_true(level.has_node("Player"), "Level should contain a Player node")

func test_level_has_music():
	assert_true(level.has_node("Music"), "Level should contain a Music node")
