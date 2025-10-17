class_name SummonBarTest
extends GdUnitTestSuite

const START = "start"
const STOP = "stop"

var _runner: GdUnitSceneRunner
var _bar: TextureProgressBar
var _highlight: AnimatedSprite2D
var _get_animation_speed: Callable

@warning_ignore_start("redundant_await")


func before_test() -> void:
	_runner = scene_runner("uid://c2p8hmv11uyfp")
	_bar = _runner.get_property("bar")
	_highlight = _runner.get_property("highlight")
	_get_animation_speed = _highlight.sprite_frames.get_animation_speed.bind(
			&"partial"
	)


func test_start() -> void:
	_runner.invoke(START, 0.1)
	await _runner.simulate_frames(10)
	assert_float(_bar.value).is_greater(0.0)
	assert_float(_get_animation_speed.call()).is_greater(0.0)


func test_stop() -> void:
	_runner.invoke(START, 0.1)
	await _runner.simulate_frames(10)
	_runner.invoke(STOP)
	assert_float(_bar.value).is_equal(0.0)
	assert_float(_get_animation_speed.call()).is_equal(0.0)
	assert_int(_highlight.frame).is_equal(0)


func test_stop_start() -> void:
	_runner.invoke(START, 0.1)
	await _runner.simulate_frames(1)
	_runner.invoke(STOP)
	await _runner.simulate_frames(1)
	_runner.invoke(START, 0.1)
	await _runner.simulate_frames(10)
	assert_float(_bar.value).is_greater(0.0)
	assert_float(_get_animation_speed.call()).is_greater(0.0)


func test_complete() -> void:
	_runner.invoke(START, 0.0)
	await _runner.simulate_frames(10)
	assert_float(_bar.value).is_equal(_bar.max_value)
	assert_str(_highlight.animation).is_equal(&"complete")
