shader_type canvas_item;
uniform float strength = 10.0;
uniform float speed = 1.0;
void vertex() {
	float sway = sin(TIME * speed);
	float anchor = (1.0 - UV.y);
	VERTEX.x += sway * strength * anchor;
	VERTEX.x = floor(VERTEX.x);
	VERTEX.y = floor(VERTEX.y);
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
