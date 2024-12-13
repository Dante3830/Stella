shader_type canvas_item;

uniform float flicker_speed : hint_range(1.0, 10.0) = 5.0;
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Sample the original texture
    vec4 original_texture = texture(TEXTURE, UV);

    // Create a flickering effect using sine wave
    float flicker = (sin(TIME * flicker_speed) + 1.0) * 0.5;

    // Interpolate between orange and red
    vec3 orange = vec3(1.0, 0.5, 0.0);  // Bright orange
    vec3 red = vec3(1.0, 0.0, 0.0);     // Bright red

    // Mix colors based on flicker intensity
    vec3 flicker_color = mix(orange, red, flicker);

    // Preserve original texture's alpha and apply color overlay
    COLOR = vec4(
        mix(original_texture.rgb, flicker_color, flicker * flicker_intensity),
        original_texture.a
    );
}