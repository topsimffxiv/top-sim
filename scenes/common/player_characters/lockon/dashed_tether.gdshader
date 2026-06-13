shader_type spatial;
render_mode unshaded;

uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 dash_color : source_color = vec4(0.0);
uniform float mesh_length = 1.0;
uniform float dash_speed = 1.5;
uniform float dash_size = 0.4;

void fragment() {

    float scroll = fract(UV.x*4.0 + TIME * dash_speed / mesh_length);

	float dash = step(1.0 - dash_size, scroll);

	vec4 final_color = mix(base_color, dash_color, dash);
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a; // Combine dash pattern with edges
}
