class_name GhostTest
extends GdUnitTestSuite

const GHOST_SCENE_PATH = "res://src/ghost/ghost.tscn"

const BUTTON_1_ACTION = "button_1"
const BUTTON_2_ACTION = "button_2"

const GHOST_COSTUME_NAME = "GhostCostume"
const IDLE_ANIMATION_NAME = "idle"


func test_summon_sprint_idle() -> void:
	var runner: GdUnitSceneRunner = scene_runner(GHOST_SCENE_PATH)
	var costume: GhostCostume = runner.find_child(GHOST_COSTUME_NAME)
	await runner.simulate_frames(1)
	runner.simulate_action_press(BUTTON_2_ACTION)
	runner.simulate_action_press(BUTTON_1_ACTION)
	await runner.await_input_processed()
	assert_str(costume.ghost.current_animation).is_equal(IDLE_ANIMATION_NAME)
