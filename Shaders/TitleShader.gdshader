shader_type canvas_item;

uniform vec4 color_texto : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_borde_interno : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_borde_externo : source_color = vec4(0.0, 0.0, 1.0, 1.0);
uniform float ancho_borde : hint_range(0.0, 20.0) = 5.0;
uniform float suavizado : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 color_original = texture(TEXTURE, UV);

    // Calcular la distancia al borde del texto
    float distancia = texture(TEXTURE, UV).a;

    // Crear el borde con degradado
    float borde_interno = smoothstep(0.5 - suavizado, 0.5 + suavizado, distancia);
    float borde_externo = smoothstep(0.5 - ancho_borde / 100.0 - suavizado, 0.5 - ancho_borde / 100.0 + suavizado, distancia);

    // Mezclar los colores para crear el degradado
    vec4 color_borde = mix(color_borde_externo, color_borde_interno, borde_externo);

    // Combinar el texto original con el borde
    vec4 color_final = mix(color_borde, color_texto, borde_interno);

    // Aplicar el color final con la transparencia original
    COLOR = vec4(color_final.rgb, color_original.a * color_final.a);
}