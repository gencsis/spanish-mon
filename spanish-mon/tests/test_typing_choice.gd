extends GutTest

var choice

func before_each():
	var s = load("res://spanish-mon/typing_choice.tscn")
	choice = s.instantiate()

func test_start_choices_initializes_state():
	choice.start_choices(["uno", "dos", "tres"])
	assert_true(choice.is_choosing, "Should enter choosing state")
	assert_eq(choice.current_index, 0, "Should start at first choice")
	assert_true(choice.answer.is_empty(), "Answer should start empty")

func test_stop_choices_resets_state():
	choice.start_choices(["uno"])
	choice.stop_choices()
	assert_false(choice.is_choosing)
	assert_eq(choice.answer, "")
	assert_eq(choice.current_index, -1)

func test_handle_input_adds_letters():
	choice.start_choices(["hola"])
	choice.handle_input("h")
	assert_eq(choice.answer, "h")

func test_validate_input_emits_correct_choice():
	var result_index = null
	var result_choice = null

	choice.connect("choice_completed", func(i, c):
		result_index = i
		result_choice = c
	)

	choice.start_choices(["hola"])
	choice.answer = "hola"
	choice.validate_input()

	assert_eq(result_index, 0)
	assert_eq(result_choice, "hola")
