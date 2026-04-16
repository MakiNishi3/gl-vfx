// Trying out the band limited cosine from https://www.shadertoy.com/view/WtScDt
#define CRAZINESS 1

const float PI = radians(180.);
const float PI2 = 2.*PI; // radians(360) might be 0 instead of 2*PI.

#define Z(X) (.5+.5*(X))

/*
vec3 get_color(float t)
{
    const float F = PI2;
    const float A = .5;
    vec3 col = vec3(1,0,0)*Z(cos(F*t)) + vec3(0,1,0)*Z(cos(2.*F*t)) + vec3(0,0,1)*Z(cos(4.*F*t));
    return col;
}
*/

/*
vec3 get_color(float t)
{
    const float F = PI2;
    const float A = .5;
    vec3 col = vec3(1,0,0)*Z(cos(F*t)) + vec3(0,1,0)*Z(cos(F*t-PI2/3.)) + vec3(0,0,1)*Z(cos(F*t-2.*PI2/3.));
    return col;
}
*/

// box-filted cos(x)
float fcos(float x)
{
    float w = fwidth(x);
	#if 1
    return cos(x) * sin(0.5*w)/(0.5*w);       // exact
	#else
    return cos(x) * smoothstep(6.2832,0.0,w); // approx
	#endif    
}

// pick raw cosine, or band-limited cosine
bool mode = false;
float mcos(float x){return mode ? cos(x) : fcos(x);}

vec3 get_color(float t)
{
    const float F = PI2;
    const float A = .5;
    vec3 col = vec3(1,0,0)*Z(mcos(F*t)) + vec3(0,1,0)*Z(mcos(F*t-PI2/3.)) + vec3(0,0,1)*Z(mcos(F*t-2.*PI2/3.));
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord-.5)/(iResolution.xy-1.);
    uv = 2.*uv-1.;
    uv.x *= iResolution.x/iResolution.y;

    // Time varying pixel color
    //vec3 col = vec3(uv,0.);
    //vec2 xy = uv;
    vec2 xy = 2.*uv/dot(uv,uv);
    xy.x += 20.*dot(normalize(uv), vec2(cos(iTime),sin(iTime)));
    xy.x += 20.*dot(normalize(uv), vec2(0,1));
    #if CRAZINESS
    //float freq = .5+.5*dot(normalize(uv), vec2(1,0));
    float freq = (atan(uv.y,uv.x)+PI)/PI2;
    float amp = texture(iChannel0,vec2(freq,.25)).x;
    xy *= amp;
    //xy += cos(length(xy));
    //xy -= cos(amp*length(xy.x));
    //xy += cos(4.*amp*length(xy.y));
    //xy -= cos(8.*amp*length(xy.x));
    #endif
    xy += iTime;
    float threshold = sin(iTime)*iResolution.x/iResolution.y;
    mode = uv.x < threshold;
    vec3 col = min(get_color(xy.x),get_color(xy.y));
    col = mix(col, vec3(0.), 1.-smoothstep(0.,.01, abs(uv.x-threshold)));
    if(uv.y < -.9)col = get_color(uv.x);

    // Output to screen
    fragColor = vec4(col,1.0);
}