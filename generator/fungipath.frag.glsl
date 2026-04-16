#define PSD pow(textureLod(iChannel0, vec2(.5), 0.).r, 1.)
void mainImage( out vec4 f, in vec2 g )
{
    f-=f;
    float x = 1., i=x, T=iTime, l;
	vec2 R = iResolution.xy;
    vec4 p = vec4((g+g-R)/R.y, .5, 0), d=p;
    p.y -= 5.; p.z -= T+T;
    p *= .5;
    for (; i > 0. && x > 1e-3; i-= .02)
        x = length(cos(p.wxw)-cos(p.yzw))-PSD*.5,
        f = i*i*vec4(l=distance(p, p-p), 1./l*l, abs(p.y), 1.),
        p -= d*x*.5;
}
