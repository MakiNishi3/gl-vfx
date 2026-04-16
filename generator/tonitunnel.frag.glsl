float s;

mat2 rot(float a)
{
    float s = sin(a), c = cos(a);
    return mat2(c, s, -s, c);
}


vec3 path(float z)
{
    vec3 p = vec3(sin(z) * .5, cos(z * .5), z);
    p.x+=p.y*p.x*2.;
    return p;
}

vec3 fractal(vec3 p)
{
    float z = p.z * .1;
    p.z = abs(.5 - fract(z));
    float m = 100.;
    for (int i = 0; i < 10; i++)
    {
        p.xy *= rot(z);
        p = abs(p * (1.5+sin(z*3.)*.2)) - 2.;
        m = min(m, abs(p.y) + .5 * abs(.5 - fract(p.x * .25 + iTime + float(i) * .1)));
    }
    m = exp(-8. * m) * 2.;
    return vec3(p.xz * 2., m) * m + .5;
}

float g=0.;
vec3 lpos;

float de(vec3 p)
{
    float d=length(p-lpos)-s*.2;
    p.xy -= path(p.z).xy;
    g+=.003/(.1+d*5.);
    return min(d,-length(p.xy) + .3);
}

vec3 march(vec3 from, vec3 dir)
{
    float d, td = 0.;
    vec3 p, col = vec3(0);
    for (int i = 0; i < 80; i++)
    {
        p = from + dir * td;
        d = de(p);
        if (d < .001) break;
        td += d;
    }
    if (d < .1) 
    {
        p -= .001 * dir;
        col = fractal(p) * exp(-1. * td * td) * smoothstep(.3, 1., td);
    }
    return (col+g)*(.3+s*4.);
}

mat3 lookat(vec3 dir, vec3 up) {
    dir = normalize(dir);
    vec3 rt = normalize(cross(dir, normalize(up)));
    return mat3(rt, cross(rt, dir), dir);
}

float getSound() 
{
    float s=0.;
    for (float i=0.; i<20.; i++) {
        s+=texture(iChannel0,vec2(0.,i/20.)).r;
        s+=texture(iChannel0,vec2(i/20.,0.)).r;
    }
    return s/20.;
}

void texto(inout vec3 col, vec2 offset) {
    vec2 uv=gl_FragCoord.xy/iResolution.xy;
    uv.y=1.-uv.y;
    vec4 tx = texture(iChannel1, uv+offset);
    col = mix(col, tx.rgb, length(tx.rgb));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
     s=getSound();
     vec2 uv = (fragCoord - iResolution.xy * .5) / iResolution.y;
    float t = iTime;
    vec3 from = path(t);
    lpos = path(t+1.);
    vec3 fw = normalize(path(t + .5) - from);
    vec3 dir = normalize(vec3(uv, 1));
    dir = lookat(fw, vec3(0, 1, 0)) * dir;
    vec3 col = march(from, dir);
    texto(col, vec2(-0.35,-0.4));
    fragColor = vec4(col,1.0);
}
