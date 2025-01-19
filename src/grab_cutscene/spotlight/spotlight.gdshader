shader_type canvas_item;
render_mode unshaded;
// Taken from
// https://godotshaders.com/shader/spotlight-effect-transition-with-feathering-position/

uniform float circle_size = 0.5;
uniform float feather = 0.05;
uniform vec2 circle_position = vec2(0.5, 0.5);
uniform float screen_width = 1920;
uniform float screen_height = 1080;

void fragment() {
    float ratio = screen_width / screen_height;
    vec2 adjusted_uv = vec2(mix(circle_position.x, UV.x, ratio), UV.y);
    float dist = distance(circle_position, adjusted_uv);
    float edge_start = circle_size - feather;
    float edge_end = circle_size + feather;
    COLOR.a = smoothstep(edge_start, edge_end, dist);
}
