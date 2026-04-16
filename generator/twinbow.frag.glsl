//Adapted code from https://thebookofshaders.com/06/

#ifdef GL_ES
precision mediump float;
#endif

#define TWO_PI 6.28318530718

//  Function from Iñigo Quiles
//  https://www.shadertoy.com/view/MsS3Wc
vec3 hsb2rgb( in vec3 c ){
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                             6.0)-3.0)-1.0,
                     0.0,
                     1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix( vec3(1.0), rgb, c.y);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iTime*10.;
    float totalsound = texture(iChannel0,vec2(0.0,0.0)).r;
    totalsound *=55.;
    //totalsound =pow(205.*(totalsound+0.1),1.5);
    //t *=(2.0+pow(3.*totalsound,2.));
    vec2 res=iResolution.xy;
    vec2 st = fragCoord.xy/iResolution.xy;
    st.x*=res.x/res.y; //scales the aspect ratio
    st.x -=0.4;
    vec3 color = vec3(0.0);

    // Use polar coordinates instead of cartesian
    vec2 toCenter = vec2(0.5)-st;
    float angle = atan(toCenter.y,toCenter.x);
    float radius = length(toCenter)*2.0;

    // Map the angle (-PI to PI) to the Hue (from 0 to 1)
    // and the Saturation to the radius
    color = hsb2rgb(vec3(((angle*50.*(1.0+totalsound)+t)/TWO_PI)+0.5,radius,1.0));

    fragColor = vec4(color,1.0);
}



    