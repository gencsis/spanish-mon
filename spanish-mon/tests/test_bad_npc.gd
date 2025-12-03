extends GutTest

var npc

func before_each():
	var s = load("res://spanish-mon/bad_npc.tscn")
	npc = s.instantiate()

func test_npc_defaults():
	assert_true(npc.health > 0)
	assert_true(npc.speed > 0)

func test_take_damage_reduces_health():
	var h = npc.health
	npc.take_damage(2)
	assert_eq(npc.health, h - 2)

func test_death_signal_emitted():
	var died = false
	npc.connect("enemy_defeated", func(): died = true)

	npc.health = 1
	npc.take_damage(5)

	assert_true(died)
