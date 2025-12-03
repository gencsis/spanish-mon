extends GutTest

var sign
var fake_player

func before_each():
	var scene = load("res://Characters/sign.tscn")
	sign = scene.instantiate()

	fake_player = Node2D.new()
	fake_player.add_to_group("player")

func test_sign_has_required_nodes():
	assert_true(sign.has_node("TypingChoice"), "Sign must have a TypingChoice node")
	assert_true(sign.has_node("Area2D"), "Sign must have an Area2D node")

func test_entering_area_starts_choices():
	var choice = sign.get_node("TypingChoice")
	choice.stop_choices()
	sign._on_area_body_entered(fake_player)
	assert_true(choice.is_choosing, "Entering area should start choices")

func test_exiting_area_stops_choices():
	var choice = sign.get_node("TypingChoice")
	choice.start_choices()
	sign._on_area_body_exited(fake_player)
	assert_false(choice.is_choosing, "Exiting area should stop choices")

func test_choice_completed_with_read():
	sign._on_choice_completed(0, "read")
	assert_true(true, "Function should execute without errors")
