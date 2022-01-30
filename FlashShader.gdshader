shader_type canvas_item;

uniform bool active = false;

void fragment()
{
	vec4 previous_colour = texture(TEXTURE, UV);
	vec4 white_colour = vec4(1.0, 1.0, 1.0, previous_colour.a);
	vec4 new_colour = previous_colour;
	if (active == true)
	{
		new_colour = white_colour;
	}
	COLOR = new_colour;
}