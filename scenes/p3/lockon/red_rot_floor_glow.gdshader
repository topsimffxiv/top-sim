shader_type spatial;
render_mode unshaded; // Use "spatial" for lit, "unshaded" for glowing effect

uniform vec4 center_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_power = 1.0;
uniform float emission_power = 1.0;

varying vec3 v_world_pos;

void vertex() {
    // Pass world position to fragment shader
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Calculate distance from the center (assuming cylinder is at 0,0,0)
    // Adjust based on your scene setup if needed
    float dist = length(v_world_pos.xz);
    
    // Normalize distance based on cylinder radius (assuming radius 1.0)
    // If your cylinder radius is different, divide by that value
    float radial_gradient = pow(clamp(dist, 0.0, 3.0), gradient_power/3.0);
    
    vec4 final_color = mix(center_color, edge_color, radial_gradient);
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
	EMISSION = final_color.rgb * emission_power;
}
