// Author: BSC
// Title: 

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926
#define TAU PI*2

vec3 analyzer(in vec2 uv) {
    // Normalize pixel coordinates (from -1 to 1)
    vec2 p = -1. + (2.*uv);

    float th = 0.01;
    vec3 audio = textureLod(iChannel0, uv*0.5, 0.0).xyz;

    vec3 col = vec3(0.);
    if ((p.y < th+audio.x) && (p.y > -th-audio.x)) {
        float d = abs(p.y-audio.x);
        col.r = audio.x;
        col.g = audio.x * d;
        col.b = 0.5 * pow(-2., p.x);
    }
    return col;
}

vec3 bass(in vec2 uv) {
    const float bands = 80.;
    //const float fact = 0.2;
    //uv *= 0.5;
    //float band = -36. + bands * uv.x; //  uv.x / bands;
    float band = uv.x / bands;
    float f = 440. * pow(2., band/12.);
    float val = textureLod(iChannel0, vec2(f,0.), 0.0).x;

    const float e = 0.3;
    vec3 col = vec3(0.);
    if ((uv.y < e) && (val > 0.2)) {
        col.g = val*(1./e)*(e-uv.y);
        col.b = val*e;
    }

    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.y;
   
    vec3 col = analyzer(uv);
    col += bass(uv);

    fragColor = vec4(col,1.0);
}