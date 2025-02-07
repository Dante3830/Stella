shader_type canvas_item;

// Original colors to be replaced
uniform vec4 original_color_1 : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 original_color_2 : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform vec4 original_color_3 : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec4 original_color_4 : source_color = vec4(0.0, 0.0, 1.0, 1.0);

// New replacement colors
uniform vec4 new_color_1 : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform vec4 new_color_2 : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 new_color_3 : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 new_color_4 : source_color = vec4(1.0, 0.0, 1.0, 1.0);

// Tolerance for color comparison
uniform float tolerance = 0.1;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);

    // Check if current color is close to any of the original colors
    if (length(current_color - original_color_1) < tolerance) {
        COLOR = new_color_1;
    }
    else if (length(current_color - original_color_2) < tolerance) {
        COLOR = new_color_2;
    }
    else if (length(current_color - original_color_3) < tolerance) {
        COLOR = new_color_3;
    }
    else if (length(current_color - original_color_4) < tolerance) {
        COLOR = new_color_4;
    }
    else {
        COLOR = current_color;
    }
}