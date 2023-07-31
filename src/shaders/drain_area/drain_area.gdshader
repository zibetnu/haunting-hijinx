shader_type canvas_item;

// for circles
uniform float amplitude: hint_range(0, 2, 0.01) = 2.0;
uniform float frequency: hint_range(-15, 15, 0.01) = 12.69;
uniform float ripple_rate: hint_range(0.5, 150.0, 0.1) = 9.2;

// for wave
uniform float wave_amplitude = 0.1;
uniform float wave_frequency = 4.0;

// other
uniform sampler2D noise;

void fragment() {
	vec2 wave_uv = vec2(
			UV.x + sin(UV.y * wave_frequency * 5.0 + TIME) * wave_amplitude,
			UV.y + sin(UV.x * wave_frequency + TIME) * wave_amplitude
	);
	vec4 ns = texture(noise, wave_uv);

	float pi = 3.14159265358979323846;
	vec2 uv = UV * 2.0 - 1.0;

	float dist = length(uv);
	ns *= 1.4142135;
	dist += -0.1 * ns.x;
	float ripple = sin(dist * -frequency * pi + ripple_rate * TIME) * amplitude / (dist + 1.0);

	vec4 color = vec4(1.0, 1.0, 1.0, 2.0 * ripple);
	float alpha_scalar = (1.0 - min(dist, 1.0)) * ns.x * 2.5; 

	color.a *= 1.0 * alpha_scalar * (ripple + ns.x * ns.y);
	color.a = max(color.a - (ns.y * 0.45), 0.0);

	COLOR = color;
}
