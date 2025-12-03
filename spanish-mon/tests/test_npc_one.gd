extends GutTest

var npc

func before_each():
	var s = load("res://spanish-mon/npc_one.gd")
	npc = s.new()

func test_npc_has_speed():
	assert_true(npc.speed > 0)

func test_set_direction_changes_velocity():
	npc.set_direction(Vector2.RIGHT)
	assert_eq(npc.direction, Vector2.RIGHT)
