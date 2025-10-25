class_name HunterTest
extends GdUnitTestSuite

@warning_ignore_start("redundant_await")


func test_push_dead_hunter() -> void:
	var runner: GdUnitSceneRunner = scene_runner("uid://bo35ift2bygh0")
	var hunter: Hunter = runner.find_child("Hunter")
	var hunter_start_position: Vector2 = hunter.position
	var hunter_2: Hunter = runner.find_child("Hunter2")
	var hunter_2_start_position: Vector2 = hunter_2.position

	await await_idle_frame()
	hunter_2.state_chart.send_event(&"died")
	assert_int(hunter_2.collision_layer).is_equal(hunter_2.dead_layer)
	assert_int(hunter_2.collision_mask).is_equal(hunter_2.dead_mask)

	hunter.controller.move_vector = Vector2.RIGHT
	await runner.simulate_frames(10)
	assert_vector(hunter.position).is_not_equal(hunter_start_position)
	assert_vector(hunter_2.position).is_equal(hunter_2_start_position)
