shader_type spatial;
render_mode unshaded, blend_mix, cull_back; // Use "spatial" for lit, "unshaded" for glowing effect

uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform mat4 global_transform;
varying vec3 world_pos;
uniform float gradient_power = 1.0;
uniform float emission_power = 1.0;
uniform float radius = 3.0;
uniform float fade_width = 0.3;

void vertex() {
    // Pass world position to fragment shader
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Calculate distance from the center (assuming cylinder is at 0,0,0)
    // Adjust based on your scene setup if needed
	float top_mask = smoothstep(0.8, 0.98, NORMAL.y);

	float r = length(VERTEX.xz);
	float a = (1.0 - smoothstep(radius - fade_width, radius, r)) * TOP);
    float dist = length(world_pos.xz);

    // Normalize distance based on cylinder radius (assuming radius 1.0)
    // If your cylinder radius is different, divide by that value
    float radial_gradient = pow(clamp(dist/3.0, 0.0, 1.0), gradient_power);

    vec4 final_color = mix(center_color, edge_color, radial_gradient);
    ALBEDO = center_color.rgb;
	ALPHA = a;
}
