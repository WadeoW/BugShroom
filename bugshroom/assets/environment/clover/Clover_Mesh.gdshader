shader_type spatial;
render_mode cull_disabled, depth_draw_opaque; 

uniform sampler2D clover_texture : source_color, repeat_disable; 

uniform vec3 wind_direction = vec3(1.0, 0.0, 0.5);
uniform float wind_speed = 2.0;
uniform float wind_strength = 0.2;

uniform float root_y_offset = 0.0; 
uniform float stem_height = 1.0;   

// --- NEW: Height Categorization Uniforms ---
uniform float height_small = 0.6;
uniform float height_medium = 0.85;
uniform float height_large = 1.1;
uniform float height_jitter = 0.1; // The +/- variance applied to the chosen tier

// HELPER FUNCTION: Pseudo-random number generator
// Uses dot products and large scalar multiplication to create deterministic noise
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

// HELPER FUNCTION: Constructs a 3D rotation matrix
mat3 rotation_matrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(
        vec3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s),
        vec3(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s),
        vec3(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c)
    );
}

void vertex() {
	// --- INSTANCE SCALING MATH ---
	// 1. Extract the object's discrete world origin point to use as a seed
	vec3 object_world_pos = MODEL_MATRIX[3].xyz;
	
	// 2. Generate two random values (one for the tier selection, one for the jitter)
	float tier_rand = hash(object_world_pos.xz); 
	float jitter_rand = hash(object_world_pos.zx); 

	// 3. Categorize into Small, Medium, or Large
	float instance_scale = height_large; 
	if (tier_rand < 0.333) {
		instance_scale = height_small;
	} else if (tier_rand < 0.666) {
		instance_scale = height_medium;
	}

	// 4. Calculate and apply jitter
	// Converts the 0.0 to 1.0 random range into a -jitter to +jitter range
	float current_jitter = (jitter_rand * 2.0 - 1.0) * height_jitter;
	instance_scale += current_jitter;

	// 5. Apply the calculated scale uniformly to the vertex to prevent texture distortion
	VERTEX *= instance_scale;

	// --- WIND & TILT MATH ---
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float phase = world_pos.x * 0.5 + world_pos.z * 0.5;
	vec3 norm_wind_dir = normalize(wind_direction);
	
	float sway = sin(TIME * wind_speed + phase) * wind_strength;

	// 6. Scale the structural parameters so the bend arc remains proportional
	float current_stem_height = stem_height * instance_scale;
	float current_root_offset = root_y_offset * instance_scale;

	float normalized_height = smoothstep(current_root_offset, current_root_offset + current_stem_height, VERTEX.y);
	float bend_factor = pow(normalized_height, 2.0);

	float angle = sway * bend_factor;
	vec3 rotation_axis = normalize(cross(vec3(0.0, 1.0, 0.0), norm_wind_dir));
	
	mat3 rot = rotation_matrix(rotation_axis, angle);
	
	// Apply dynamic pivot translation, rotate, and return
	vec3 pivot = vec3(0.0, current_root_offset, 0.0);
	vec3 local_vertex = VERTEX - pivot;
	
	local_vertex = rot * local_vertex;
	VERTEX = local_vertex + pivot;
	
	NORMAL = rot * NORMAL;
}

void fragment() {
	vec4 tex_color = texture(clover_texture, UV);
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
