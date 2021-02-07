shader_type canvas_item;

uniform bool active = true;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 grey_color = vec4(0.4, 0.4, 0.4, previous_color.a);
	vec4 new_color = previous_color;
	if (active) {
		new_color = grey_color;
	}
	COLOR = new_color;
}