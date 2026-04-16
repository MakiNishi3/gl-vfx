// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
// Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
// =========================================================================================================

#define sat(a) clamp(a, 0., 1.)
vec3 pink = (vec3(255, 59, 98)/255.);
vec3 blue = vec3(59, 154, 255)/255.;
mat2 r2d(float a) { float ca = cos(a), sa = sin(a); return mat2(ca, sa, -sa, ca);}

float lenny(vec2 uv)
{
    return abs(uv.x)+abs(uv.y);
}

float sdLoz(vec2 uv, float sz)
{
    return lenny(uv)-sz;
}

float sdSqr(vec2 uv, vec2 sz)
{
    vec2 q = abs(uv)-sz;
    return max(q.x,q.y);
}

float bars(vec2 uv)
{
    vec2 ouv = uv;
    float rep = 0.08;
	float idx = float(int((uv.x+rep*.5)/rep));
    uv.x = mod(uv.x+rep*.5, rep)-rep*.5;
    float h = texelFetch(iChannel0, ivec2(int((idx+8.5)*7.), 0), 0).x;
    float sqr = sdSqr(uv, vec2(.00001,.1+.2*h));
    return max(sqr, -(abs(uv.y)-.05));
}

vec2 myPixel(vec2 uv, float sz)
{
    vec2 uv2 = uv/sz;
    
    return  vec2(float(int(uv2.x)), float(int(uv2.y)))*sz;
}

vec3 rdrPix(vec2 uv)
{
    vec3 col;
    uv = myPixel(uv, 0.1);
    float beat = texelFetch(iChannel0, ivec2(25,0),0).x;
    float patt = sin((55.*(abs(uv.x)+beat*.05+uv.y)-iTime*10.)*(1.+abs(uv.y)*.01));
    col = mix(col, vec3(.5,.2,.9), sat((patt-.99)*iResolution.x));
    col += (vec3(.2,.7,.3))*0.+blue*(sat((patt-.5)*.5));
    return col;
}

vec3 rdrLoz(vec2 uv)
{
    vec2 ouv = uv;
    uv *= 15.;
    uv = myPixel(uv, 0.025);
    uv.y += sin(uv.x*5.+iTime)*.5;
    vec3 col;
    vec3 a = vec3(255,98,14)/255.;
    vec3 b = vec3(255,239,88)/255.;
    vec3 c = vec3(91,222,150)/255.;
    if (uv.y < 0.)
        col = mix(b, c, sat(abs(uv.y)));
    else
        col = mix(b, a, sat(uv.y));
    float f = iResolution.x/10.;
    float sz = .99;
    col *= 1.-sat((sin(ouv.x*f)-sz)*iResolution.x*.1);
    col *= .5+1.-sat((sin(ouv.y*f)-sz)*iResolution.x*.1);
    return col;
    
}

vec3 rdr(vec2 uv)
{
    vec3 col;
    
    // Back bars
    vec2 uvBar = uv;
    uvBar.x += -sign(uvBar.x)*pow(sat(abs(uvBar.x)), .2)*abs(uvBar.y);
    float bar = bars(uvBar);
    col = mix(col, vec3(1.), 1.-sat(bar*iResolution.x));

    col += (vec3(255, 59, 216)/255.)*pow((1.-sat(bar*1.)), 10.)*.5;
    col += mix(pink, blue, pow(sat(abs(uv.y*5.)),5.))*pow((1.-sat(bar*5.)), 20.);
    col *= (uv.y < 0. ? 1.-abs(uv.y*5.) : 1.0);
    
    vec2 uvLz = uv;
    float lz = sdLoz(uvLz, .15);
    
    
    vec3 pixCol = rdrPix(uv);
    col += pixCol*(1.-sat(lz*2.))*texelFetch(iChannel0, ivec2(25,0),0).x;
    
	col = mix(col, col+rdrLoz(uv), 1.-sat(lz*iResolution.x*.01));
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-vec2(.5)*iResolution.xy)/iResolution.xx;
	uv *= 1.5;
    uv *= sin(iTime*.4)*.2+.8;

    vec3 col = rdr(uv);

	col = pow(col, vec3(mix(.45,1.45,sat(lenny(uv)))));
    fragColor = vec4(col,1.0);
}