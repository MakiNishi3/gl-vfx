#define E .005
#define F 40.
#define T iTime

#define PSD pow(abs(textureLod(iChannel0, vec2(.5), 0.).r), 2.)

#define r(p, a) {p = p * cos(a) + vec2(p.y, -p.x) * sin(a);}
float sdBox(vec3 p, vec3 b)
{
    vec3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)), 0.) + length(max(d, 0.));
}

float map(vec3 p)
{
    float d = 1e5;
    for (int i = 0; i < 3; i++)
    {
        p = abs(p);
        p = .5 - abs(p)*1.5/clamp(dot(p,p), -1., 1.);
        r(p.xz, T + PSD);
        r(p.yz, T);
        float b = sdBox(p, vec3(.01, 10., .01));
        d = min(d, b);
        b = sdBox(p, vec3(10., .05 + .5 * PSD, .5));
        d = min(d, b);
    }
    return d;
}

vec3 calcNormal(vec3 p)
{
    vec2 e = vec2(E, 0);
    return normalize(vec3(
        map(p+e.xyy)-map(p-e.xyy),
        map(p+e.yxy)-map(p-e.yxy),
        map(p+e.yyx)-map(p-e.yyx)
        ));
}

void mainImage( out vec4 O, in vec2 w )
{
	vec2 R = iResolution.xy, u = (2.*w-R) / R.y;
    vec3 ro = vec3(u, 1), rd = normalize(vec3(u, -1)), p, n;
    
    float t = 0., x;
    for (int i = 0; i < 100; i++)
    {
        p = ro + rd * t;
        x = map(p);
        t += x;
        if (x < E || t > F) break;
    }
    
    if (t > F)
    {
        vec3 col = abs(sin(floor(p.z*.05) * PSD*.5 * vec3(1., 5., 4.) + T));
        O = vec4(col, 1.);
        return;
    }
    
    n = calcNormal(p);
    
    // Lighting
    
    vec3 lp = vec3(1, 3, 5);
    vec3 ld = lp - p;
    float len = length(ld);
    ld /= len;
    float atten = max(1., 1./len);
    float amb = .25;
    float diff = max(dot(ld, n), 0.);
    float spec = pow(max(dot(reflect(-ld, n), ro-p), 0.), 8.);
    vec3 col = vec3(.8, .1, .5) * (((diff*.9+amb*.5)*atten)+spec*.5);
	O = vec4(col,1.0);
}
