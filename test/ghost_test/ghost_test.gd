class_name GhostTest
extends GdUnitTestSuite

const SCENE_PATH = "uid://nwyok6u2y3vu"

const BUTTON_1 = "button_1"
const BUTTON_2 = "button_2"
const MOVE_RIGHT = "move_right"

const GHOST_COSTUME = "GhostCostume"
const IDLE = "idle"

@warning_ignore_start("redundant_await")


func test_sprint_idle() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE_PATH)
	var costume: GhostCostume = runner.find_child(GHOST_COSTUME)

	runner.simulate_action_press(BUTTON_1)
	await runner.await_input_processed()

	runner.simulate_action_press(MOVE_RIGHT)
	await runner.await_input_processed()

	assert_str(costume.ghost.current_animation).is_equal("sprint")

	runner.simulate_action_release(MOVE_RIGHT)
	await runner.await_input_processed()

	assert_str(costume.ghost.current_animation).is_equal(IDLE)


func test_summon_sprint_idle() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SCENE_PATH)
	var costume: GhostCostume = runner.find_child(GHOST_COSTUME)

	runner.simulate_action_press(BUTTON_2)
	await runner.await_input_processed()

	assert_str(costume.ghost.current_animation).is_equal("summon")

	runner.simulate_action_press(BUTTON_1)
	await runner.await_input_processed()

	assert_str(costume.ghost.current_animation).is_equal(IDLE)
