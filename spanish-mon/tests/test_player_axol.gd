extends GutTest

var player

func before_each():
	var scene = load("res://Characters/player_axol.tscn")
	player = scene.instantiate()

func test_player_has_move_speed():
	assert_true(player.move_speed > 0, "Player move_speed must be positive")

func test_player_can_stop_movement():
	player.velocity = Vector2(100, 0)
	player.can_move = false
	player._physics_process(0.016)

	assert_eq(player.velocity, Vector2.ZERO, "Velocity should become zero when movement is disabled")

func test_animation_parameters_update():
	player.update_animation_parameters(Vector2.RIGHT)
	var walk_blend = player.animation_tree.get("parameters/Walk/blend_position")
	assert_eq(walk_blend, Vector2.RIGHT, "Walk blend position must be updated")
