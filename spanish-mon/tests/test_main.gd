extends Node

# This is a single point where GUT loads and runs all tests

func _ready():
	var Gut = load("res://addons/gut/gut.gd")
	var gut = Gut.new()

	gut.set_autorun(true)
	gut.set_include_subdirs(true)
	gut.set_test_dir("res://tests")

	# Write XML results for CI
	# gut.set_output_junit_xml(true)
	# gut.set_junit_xml_file("res://tests/results.xml")

	add_child(gut)
	gut.run()
