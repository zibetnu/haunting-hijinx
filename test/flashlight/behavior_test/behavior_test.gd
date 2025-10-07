class_name FlashlightTest
extends GdUnitTestSuite

var _runner: GdUnitSceneRunner
var _flashlight: Flashlight


func before_test() -> void:
	_runner = scene_runner("uid://dyev6t6l5ykdp")
	_flashlight = _runner.scene()


func test_get_colliders_invalid_object() -> void:
	var mocked_repeat_raycast: RepeatRayCast2D = mock(RepeatRayCast2D)
	var invalid_object := Object.new()
	@warning_ignore("unsafe_method_access")
	do_return([invalid_object]).on(mocked_repeat_raycast).get_colliders()
	_flashlight._repeat_raycasts[0] = mocked_repeat_raycast
	invalid_object.free()
	assert_error(_flashlight._get_colliders).is_success()
