shader_type canvas_item;
// Modified version of
// https://godotshaders.com/shader/palette-swap-post-process-image-parametrized/

uniform sampler2D old_palette;
uniform sampler2D new_palette;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	ivec2 palette_size = min(
			textureSize(old_palette, 0),
			textureSize(new_palette, 0)
	);
	vec2 uv_offset = 1.0 / vec2(palette_size);

	for (int x = 0; x < palette_size.x; x++)
	for (int y = 0; y < palette_size.y; y++) {
		vec2 palette_uv = vec2(float(x) + 0.5, float(y) + 0.5) * uv_offset;
		if (current_color == texture(old_palette, palette_uv)) {
			COLOR = texture(new_palette, palette_uv);
		}
	}
}
