extends GutTest

var comp

func before_each():
	comp = load("res://Interaction/interacting_component.gd").new()

func test_component_defaults():
	assert_true(comp.is_interactable, "Component should start interactable")
	assert_true(comp.interact_name.length() > 0, "Interact name should not be empty")

func test_toggle_interactable():
	comp.is_interactable = false
	assert_false(comp.is_interactable)

	comp.is_interactable = true
	assert_true(comp.is_interactable)

func test_interact_signal_exists():
	assert_true(comp.has_signal("interacted"), "interacted signal must exist")
