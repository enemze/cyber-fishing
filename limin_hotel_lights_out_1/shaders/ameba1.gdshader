shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Uniforms for existing effects
uniform float level : hint_range(0.0, 1.0) = 1.0;
uniform float emission_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec3 fresnel_color : source_color = vec3(0.0, 0.8, 0.2); // Green for translucency
uniform float fresnel_intensity : hint_range(0.0, 10.0) = 1.0;
uniform float fresnel_power : hint_range(1.0, 10.0) = 2.0;
uniform float fresnel_blur : hint_range(0.0, 1.0) = 0.2; // New: Controls Fresnel blur
uniform vec3 rim_color : source_color = vec3(0.7, 0.5, 1.0); // Light purple for rim
uniform float rim_size : hint_range(0.0, 0.8) = 0.2;
uniform float rim_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float rim_start : hint_range(-1.0, 1.0) = 0.0;
uniform float rim_end : hint_range(-1.0, 1.0) = 1.0;

// Uniforms for animated noise
uniform float noise_scale : hint_range(0.0, 10.0) = 2.0; // Noise spatial scale
uniform float noise_speed : hint_range(0.0, 5.0) = 1.0; // Noise animation speed
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.3; // Noise modulation strength

// Uniforms for subsurface scattering (from previous request)
uniform vec3 subsurface_color : source_color = vec3(0.7, 0.5, 1.0); // Light purple
uniform float subsurface_amount : hint_range(0.0, 1.0) = 0.3;

// Procedural 3D noise function
float hash(vec3 p) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(
        mix(
            mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
            mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x),
            f.y),
        mix(
            mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
            mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x),
            f.y),
        f.z);
}

void fragment() {
    // Calculate animated noise
    vec3 noise_pos = VERTEX * noise_scale + vec3(0.0, 0.0, TIME * noise_speed);
    float noise_value = noise(noise_pos) * noise_intensity;
    
    // Fresnel effect with blur
    float dir = 1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
    // Apply blur by smoothing the Fresnel transition
    float fresnel_amount = pow(smoothstep(fresnel_blur, 1.0, dir), fresnel_power) * fresnel_intensity;
    fresnel_amount = mix(fresnel_amount, fresnel_amount * noise_value, noise_intensity);
    vec3 fresnel = fresnel_color * fresnel_amount;
    
    // Rim effect with noise modulation
    float top_align = dot(normalize(NORMAL), vec3(0.0, 1.0, 0.0));
    float top_limit = smoothstep(rim_start, rim_end, top_align);
    float rim_amount = step(1.0 - rim_size, dir) * rim_intensity * top_limit;
    rim_amount = mix(rim_amount, rim_amount * noise_value, noise_intensity);
    vec3 rim = rim_color * rim_amount;
    
    // Combine effects
    ALBEDO = fresnel + rim;
    EMISSION = (fresnel + rim) * emission_intensity * level;
    ALPHA = (rim_amount + fresnel_amount) * level;
}

void light() {
    // Simulate subsurface scattering (from previous request)
    float subsurface_factor = subsurface_amount * (1.0 - ALPHA) * max(0.0, dot(-NORMAL, LIGHT));
    DIFFUSE_LIGHT += subsurface_color * subsurface_factor;
}