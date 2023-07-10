shader_type canvas_item;
// Wipe an image horizontally or vertically using a custom alpha.
// Supports wiping sprites that have multiple frames.
// Taken from https://godotshaders.com/shader/multi-frame-wipe/.

uniform float percentage: hint_range(0, 1, 0.01);
uniform float hidden_alpha: hint_range(0, 1, 0.01) = 0;

uniform bool horizontal = false;
uniform bool invert = false;

uniform int frames: hint_range(1, 100, 1) = 1;

void fragment() {
	float frame_uv_size = 1.0 / float(frames);
	float uv_pos = horizontal ? UV.x : UV.y;

	// Reduce the uv_pos in all frames to the same relative position in the
	// first frame. For example: with 2 frames, a uv_pos of 0.75 is 0.25 away
	// from the second frame's start of 0.5, so it will be reduced to 0.25.
	uv_pos -= frame_uv_size * floor(uv_pos / frame_uv_size);

	float frame_percentage = percentage / float(frames);
	float step_value = invert ? step(frame_percentage, uv_pos) : step(uv_pos, frame_percentage);
	COLOR.a = texture(TEXTURE, UV).a * (hidden_alpha + step_value);
}
