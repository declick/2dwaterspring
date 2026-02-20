shader_type canvas_item;
render_mode blend_mix;
uniform vec4 _color:source_color;
uniform float wlevel_oscillation:hint_range(0.0, 8.0)=3.0;
void vertex() {
		VERTEX.y += sin(TIME)*wlevel_oscillation;
}
void fragment() {
	COLOR = _color;
}
