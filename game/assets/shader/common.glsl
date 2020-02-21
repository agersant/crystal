uniform vec3 highlightColor;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    vec4 outColor = texturecolor * color;
	outColor.rgb = max(outColor.rgb, highlightColor);
	return outColor;
}
