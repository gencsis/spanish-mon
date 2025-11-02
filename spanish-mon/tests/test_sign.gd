extends GutTest

@warning_ignore("shadowed_global_identifier")
var sign

func before_each():
	var scene = load("res://Characters/sign.tscn")
	sign = scene.instantiate()

func test_sign_has_dialogue():
	assert_true(sign.dialogue.size() > 0, "Sign must contain text")

func test_interact_emits_signal():
	var interacted := false
	@warning_ignore("confusable_capture_reassignment")
	sign.connect("interacted", func(): interacted = true)
	sign.interact()
	assert_true(interacted, "Sign should emit interaction signal on interact()")
