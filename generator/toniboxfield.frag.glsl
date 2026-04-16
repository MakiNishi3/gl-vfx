vec3 c;
float s;

mat2 rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, s, -s, c);
}


float de(vec3 p)
{
    p.xy *= rot(iTime * .5 + p.z * .02);
    p.x += iTime * 25.;
    p.z += iTime * 50.;
    float sc = 1.2;
    float der = 1.;
    float id = floor(p.x / 30.);
    p = mod(p, 30.) - 15.;
    p.xy *= rot(iTime * 3.);
    p.yz *= rot(iTime * 1.5);
    vec3 cc = abs(p) - vec3(8.*s, 6., .5);
    float d = length(max(vec3(0.), cc));
    vec3 cr = vec3(0., .5, 1.);
    cr.xz *= rot(id * 2.);
    cr = abs(cr);
    c = max(0., 2. - d) * length(sin(p * 4.)) * cr;
    return d * .5;
}

vec3 march(vec3 from, vec3 dir)
{
    float d, td = 0.;
    vec3 p, col = vec3(0.);
    for (int i = 0; i < 120; i++)
    {
        p = from + td * dir;
        d = de(p);
        td += max(.05, abs(d));
        col += c * exp(-.007 * td);
    }
    if (mod(iTime,20.)>10.) return abs(.5-col * .02);
    else return col*.02;
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
    vec3 dir = normalize(vec3(uv, 1.));
    dir.yz *= rot(floor(iTime * .2) * 3.1416 / 3.);
    vec3 from = vec3(0.,0.,-10.);
    vec3 col = march(from, dir);
   texto(col, vec2(-.35,-.4));
   fragColor = vec4(col,1.0);
}
