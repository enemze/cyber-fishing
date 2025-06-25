shader_type sky;

render_mode blend_mix, depth_draw_always, cull_back;

uniform float time : hint_range(0.0, 1000.0);
uniform float noise_scale = 2.0;
uniform float melt_intensity = 0.3;
uniform float speed = 0.5;

/// Hash and noise functions (basic 2D)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void fragment() {
    // uv coordinates from direction
    vec2 uv = vec2(atan(NORMAL.x, NORMAL.z) / (2.0 * 3.14159265) + 0.5, asin(NORMAL.y) / 3.14159265 + 0.5);

    // Animate noise
    float n = noise(vec2(uv.x * noise_scale, uv.y * noise_scale - time * speed));
    float melt = n * melt_intensity;
    uv.y += melt;

    // Gradient: black (bottom) → blue → orange (top)
    vec3 black = vec3(0.0);
    vec3 blue = vec3(0.0, 0.2, 0.6);
    vec3 orange = vec3(1.0, 0.4, 0.0);

    float gradient = smoothstep(0.0, 1.0, uv.y);
    vec3 color = mix(black, blue, gradient);
    color = mix(color, orange, pow(gradient, 3.0));

    float detail = noise(uv * 8.0 + vec2(time * 0.1, 0.0));
    color += detail * 0.03;

    COLOR = vec4(color, 1.0);
}
