shader_type canvas_item;
uniform sampler2D screen_texture:hint_screen_texture,filter_linear_mipmap,repeat_disable;
uniform vec4 color:source_color;
uniform sampler2D _noise:repeat_enable;
uniform float noise_speed:hint_range(0.0, 0.2)=0.1;
uniform float noise_scale:hint_range(0.0, 2.0)=0.5;
uniform float noise_strength:hint_range(0.0, 5.0)=1.0;
uniform float scale_y:hint_range(1.0, 8.0)=5.0;
uniform float y_zoom:hint_range(0.8, 2.0)=1.2;
uniform float wlevel_oscillation:hint_range(0.0, 8.0)=3.0;
uniform float fade:hint_range(0.0, 1.0)=0.3;


void vertex() {
	VERTEX.y += sin(TIME)*wlevel_oscillation;
}

void fragment() {
	vec2 uv_noise = UV*noise_scale + noise_speed * TIME;
	vec2 noise = texture(_noise,uv_noise).rg;

	float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);
	vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));
	vec4 reflected = texture(screen_texture, reflected_uv + noise * y_zoom * (noise_strength / 100.0));
	vec4 screen = texture(screen_texture, SCREEN_UV);
	reflected = mix(reflected,color,0.75);
	screen = mix(screen,color,0.75);
	float _smooth = smoothstep(0.0,fade,UV.y);
	COLOR = mix(reflected,screen,_smooth);
}

