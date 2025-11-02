extends GutTest

var player

func before_each():
	var scene = load("res://Characters/player_axol.tscn")
	player = scene.instantiate()

func test_player_has_speed():
	assert_true(player.has_variable("speed"), "Player must have a speed variable")
	assert_true(player.speed > 0, "Speed must be positive")

func test_player_moves_when_processing():
	var old_pos = player.position
	player._physics_process(1.0)
	assert_true(player.position != old_pos, "Player should move after physics update")
