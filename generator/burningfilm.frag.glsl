#ifdef GL_ES
precision lowp float;
#endif


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////



vec3 cosPalette( float t, vec3 a, vec3 b, vec3 c, vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d));
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,vec2(0))) + min(max(d.x,d.y),0.0);
}

float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 rs = vec2(uv.x-sin(iTime),uv.y+sin(iTime));
    float r = random(rs);
    float shape = sdBox(sin(iTime)-uv, vec2(-sin(uv.y),-sin(uv.y)));
   	
    vec3 a = vec3(.1,.1,.1);
    vec3 b = vec3(.5,.5,.5);
    vec3 c = vec3(r, 1.0,0.0);
    vec3 d = vec3(.5,.2,.25);
    float s = texture(iChannel0,vec2(0.0,0.0)).x;
    
    vec3 color = cosPalette(cos(iTime-uv.y) + s,a,b,c,d);
    vec3 final = (cos(shape-s) + color);
    
    fragColor = vec4(final,1.0);
}
