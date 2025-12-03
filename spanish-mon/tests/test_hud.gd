extends GutTest

var hud

func before_each():
	var s = load("res://spanish-mon/hud.tscn")
	hud = s.instantiate()

func test_update_score():
	hud.update_score(50)
	assert_eq(hud.score, 50)

func test_update_health():
	hud.update_health(3)
	assert_eq(hud.health, 3)
