shader_type spatial; // Use "canvas_item" for 2D materials

uniform sampler2D albedo_texture;
uniform float emission_strength = 1.0;
uniform float time_scale = 1.0;

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_scale;

    // Simulate noise with sine waves
    float noise = sin(uv.x * 1.0 + time) * sin(uv.y * 10.0 + time);
    noise = noise * 0.5 + 0.5; // Normalize to [0, 1]

    vec4 tex_color = texture(albedo_texture, uv);
    ALBEDO = tex_color.rgb;

    // Animate emission using "noise"
    EMISSION = tex_color.rgb * noise * emission_strength;
}
