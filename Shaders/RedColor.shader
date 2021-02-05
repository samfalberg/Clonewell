shader_type canvas_item;

uniform bool active = true;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 red_color = vec4(1.0, 0.0, 0.0, previous_color.a);
	vec4 new_color = previous_color;
	if (active) {
		new_color = red_color;
	}
	COLOR = new_color;
}