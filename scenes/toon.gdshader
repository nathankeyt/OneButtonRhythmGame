shader_type spatial;
render_mode unshaded; // Remove this line if you're not on the transparency pipeline.

uniform vec3 color : source_color;

void fragment() {
	ALBEDO = color;
}

void light() {
 	DIFFUSE_LIGHT = vec3(0.0);
}
