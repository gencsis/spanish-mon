extends GutTest

var inter
var mock_choice

func before_each():
	var s = load("res://spanish-mon/typing_interaction.tscn")
	inter = s.instantiate()
	mock_choice = inter.get_node("TypingChoice")

func test_start_interaction_calls_typing_choice():
	mock_choice.stop_choices()
	inter.start_interaction(["uno"])
	assert_true(mock_choice.is_choosing)

func test_choice_completed_signal_bubbles():
	var bubbled = false

	inter.connect("interaction_finished", func():
		bubbled = true
	)

	mock_choice.emit_signal("choice_completed", 0, "uno")

	assert_true(bubbled)
