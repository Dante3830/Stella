shader_type canvas_item;

//global uniform float global_brightness = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    //COLOR = vec4(color.rgb * global_brightness, color.a);
}