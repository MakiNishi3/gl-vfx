#define TAU 6.28318530718

vec3 ro, rd, p;
float h, n, g, t, s;

mat2 r(float a)
{
    float s=sin(a), c=cos(a);
    return mat2(c,s,-s,c);
}

float d()
{
    vec2 u = 5e-4 * p.xz; float k = 2.0; n = .0;
    for(int i=0; i<6; i++)n += texture(iChannel1,u*k).r/k, k*=2.;
    h = 4. * texture(iChannel0, vec2(n,0)).r, s += h/n;
    return p.y + 30.*n - h;
}

float tr()
{
    t = abs(ro.y/rd.y);
    g = float(!all(greaterThan(vec2(.48), fract(.2*(ro.xz+rd.xz*t*5.)*r(1.))-.5)));
    for(int i=0; i<40; i++)p=ro+rd*t, t+=.5*d();
    //g = float(!all(greaterThan(vec2(.48), fract(.2*p.xz*r(1.))-.5)));
    return .01 * s * exp(-.02*t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    rd = normalize(vec3(2.*fragCoord.xy - iResolution.xy, iResolution.y));
    ro = vec3(0, 5, 15.*iTime);
    rd.yz *= r(-.65); rd.xy *= r(.2*sin(.1*iTime));

    float a = 1.21*iDate.w + 1.31*sin(iDate.w);
    vec3 col = .5 + .5 * vec3(sin(a), sin(a+TAU/3.), sin(a+TAU*2./3.));
    fragColor = vec4(max(.6 * tr() * col + .3 * (1. - col), .3 * exp(-.01*t) * g), .05*(p.z-ro.z));

    vec2 uv = 3.*(fragCoord.xy / iResolution.xy) - 1., bv = 2.*abs(uv-.5)-1.;
    float box = max(bv.x * iResolution.x/iResolution.y, bv.y);
    float amp = texture(iChannel0, vec2(uv.x, 0)).r;
    if(uv.y*uv.y < amp && box < .0 || abs(box - .1) < .01)fragColor = vec4(1);
    
    fragColor.w = min(.5*abs(fragColor.w-1.), 5.);
}