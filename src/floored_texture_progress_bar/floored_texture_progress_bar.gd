extends TextureProgressBar


## Sets [member Range.value] to the difference of [member Range.max_value] and
## [member Range.min_value] multiplied by [param new_ratio], rounding downward
## (towards negative infinity) to the nearest multiple of [member Range.step].
## [br][br]
## Useful for ensuring that [member Range.value] isn't rounded up to
## [member Range.max_value].
func set_as_ratio_floored(new_ratio: float) -> void:
	var value_range: float = max_value - min_value
	var value_not_floored: float = min_value + value_range * new_ratio
	value = value_not_floored - fposmod(value_not_floored, step)
