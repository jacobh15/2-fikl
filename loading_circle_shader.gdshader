shader_type canvas_item;

const float PERIOD = 2.0;  // Period in seconds

void fragment() {
	float r = length(2.0 * UV - 1.0);
	float theta = atan(UV.y - 0.5, UV.x - 0.5) + PI;
	float ann = smoothstep(0.97, 0.95, r) * smoothstep(0.65, 0.67, r);
	float theta_start = mod(TIME, PERIOD) / PERIOD * TAU;
	float theta_rel = mod(theta - theta_start, TAU);
	
	COLOR = COLOR * vec4(1.0, 1.0, 1.0, ann) * theta_rel / TAU;
}
