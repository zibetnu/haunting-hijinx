class_name TutorialSelectTest
extends GdUnitTestSuite

var _runner: GdUnitSceneRunner

@warning_ignore_start("redundant_await")


func before_test() -> void:
	_runner = scene_runner("uid://cis3vfoj3ussh")


func test_ghost_frame_coord_x() -> void:
	await _runner.simulate_frames(10)
	var ghost_costume: GhostCostume = _runner.get_property("ghost_costume")
	assert_int(ghost_costume.frame_coord_x).is_equal(1)
