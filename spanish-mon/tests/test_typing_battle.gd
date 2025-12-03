extends GutTest

var battle

func before_each():
	var s = load("res://spanish-mon/typing_battle.tscn")
	battle = s.instantiate()

func test_battle_loads_prompts():
	battle.start_battle(["uno", "dos"])
	assert_true(battle.prompts.size() > 0)
	assert_eq(battle.current_prompt_index, 0)

func test_correct_answer_damages_enemy():
	battle.enemy_health = 10
	battle.prompts = ["uno"]
	battle._on_choice_completed(0, "uno")

	assert_lt(battle.enemy_health, 10)

func test_wrong_answer_damages_player():
	battle.player_health = 10
	battle.prompts = ["uno"]
	battle._on_choice_completed(0, "xyz")

	assert_lt(battle.player_health, 10)

func test_battle_ends_when_enemy_dead():
	var ended = false
	battle.connect("battle_finished", func(): ended = true)

	battle.enemy_health = 1
	battle._on_choice_completed(0, battle.prompts[0])

	assert_true(ended)
