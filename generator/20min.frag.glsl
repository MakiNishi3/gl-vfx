vec3 rectangle(vec3 color, vec3 background, vec4 region, vec2 uv);
vec3 bar(vec3 color, vec3 background, vec2 position, vec2 diemensions, vec2 uv);
vec3 bars(vec3 color, vec3 background, int bars, sampler2D sound, vec2 uv);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec3 color = vec3(1.0);
    
    color = bars(vec3(0.0), color, 96, iChannel0, uv);
    
    fragColor = vec4(color,1.0);
}

vec3 bars(vec3 color, vec3 background, int bars, sampler2D sound, vec2 uv)
{
    for(int i = 1; i <= bars; i++)
    {
        float len = 0.6 * texture(sound, vec2(float(i)/float(bars), 0.0)).x;
        background = bar(1.0 - color - len*.2, background, vec2(float(i)/float(bars+1), len*.9), vec2(1.0/float(bars+1)*0.8, len/1.5), uv);
    }
    return background;
}

vec3 bar(vec3 color, vec3 background, vec2 position, vec2 diemensions, vec2 uv)
{
    return rectangle(color, background, vec4(position.x, position.y+diemensions.y/2.0, diemensions.x/2.0, diemensions.y/2.0), uv); //Just transform rectangle a little
}

vec3 rectangle(vec3 color, vec3 background,  vec4 region, vec2 uv) //simple rectangle
{
    if(uv.x > (region.r-region.b) && uv.x < (region.r+region.b) &&
       uv.y > (region.g-region.a) && uv.y < (region.g+region.a))
    	return color;
    else return background;
}