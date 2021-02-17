uniform vec4 radii; // In pixels (top-left, top-right, bottom-right, bottom-left)
uniform vec2 textureSize; // In pixels
uniform vec2 drawSize; // In pixels

//  Reference: https://www.shadertoy.com/view/3tj3Dm
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    vec4 outColor = texturecolor * color;

    // Position within the rectangle, in range [-0.5, 0.5]
    vec2 pos = texture_coords * textureSize / drawSize - vec2(0.5);

    vec2 quadrant = step(pos, vec2(0.0));
    float radius = mix(
        mix(radii.z, radii.y, quadrant.y),
  	    mix(radii.w, radii.x, quadrant.y),
        quadrant.x
    );

    if (radius > 0) {
        float distToCenter = length(max(abs(pos * drawSize) + vec2(radius) - drawSize * vec2(0.5), 0.0));
        outColor *= smoothstep(-0.5, 0.5, radius - distToCenter);
    }

	return outColor;
}
