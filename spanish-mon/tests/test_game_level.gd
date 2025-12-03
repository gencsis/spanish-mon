extends GutTest

var level

func before_each():
	var scene = load("res://Game/game_level.tscn")
	level = scene.instantiate()

func test_level_has_player():
	assert_true(level.has_node("Player"), "Level should contain a Player node")

func test_level_has_music_node():
	assert_true(level.has_node("Music"), "Level should contain a Music node")

func test_music_starts_playing():
	var music = level.get_node("Music")
	assert_true(music.playing, "Music should automatically be playing on start")
