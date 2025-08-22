shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform int levels_r : hint_range(2, 16) = 10;
uniform int levels_g : hint_range(2, 16) = 10;
uniform int levels_b : hint_range(2, 16) = 10;

void fragment() {
    vec4 color = texture(screen_texture, SCREEN_UV);

    float r = floor(color.r * float(levels_r)) / float(levels_r);
    float g = floor(color.g * float(levels_g)) / float(levels_g);
    float b = floor(color.b * float(levels_b)) / float(levels_b);

    COLOR = vec4(r, g, b, color.a);
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
