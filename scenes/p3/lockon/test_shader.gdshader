shader_type spatial;
render_mode unshaded, blend_add, depth_draw_always;

uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    // Get vertex position in world space
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Use XZ plane for radial symmetry (creates a top-down look)
    vec2 pos = world_pos.xz;
    float d = length(pos);

    // Generate gradient
    float gradient = sin(d * 10.0) * 0.5 + 0.5; // Example: rings

	   float radial_gradient = pow(clamp(d/3.0, 0.0, 1.0), 1.0);

    vec4 final_color = mix(center_color, edge_color, radial_gradient);
    ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}
