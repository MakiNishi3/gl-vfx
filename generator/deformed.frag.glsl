#define eps .002
#define far 40.
#define time iTime
#define PI 3.1415926

#define fft texture(iChannel0, vec2(.25, 0.)).r

mat2 r2(float a) {float c = cos(a), s = sin(a); return mat2(c, -s, s, c);}

void distort(inout vec3 p)
{
    p += dot(p, p.yzx)*.01;
    p += dot(p, p.zxy)*.01;
    p += dot(p, p.xyx)*.01;
    p += dot(p, p.yxy)*.01;
    if (p.x<p.y){ p.xy = p.yx;}
	if (p.x<p.z){ p.xz = p.zx;}
	if (p.y<p.z){ p.yz = p.zy;}
}

float trap;

float map(vec3 p)
{
    float d = 0.;
    float s = 6. + fft;
    for (int i = 0; i < 3; i++)
    {
        p = -abs(p) + .5;
        p.xz *= r2(PI / 4. + time + fft);
        p.yz *= r2(PI / 8. + time + fft);
        distort(p);
        d = max(-d, length(max(abs(p) -s, 0.)));
        s *= .2;
        trap = sin(dot(p, p/p));
    }
    return d;
}

float trace(vec3 ro, vec3 rd)
{
    float t = 0., m;
    
    for (int i = 0; i < 128; i++)
    {
        vec3 p = ro + rd * t;
        m = map(p);
        t += m;
        if (m < eps || t > far) break;
    }
    return t;
}

vec3 calcNormal(vec3 p)
{
    vec2 e = vec2(eps, 0);
    return normalize(vec3(
        map(p+e.xyy)-map(p-e.xyy),
        map(p+e.yxy)-map(p-e.yxy),
        map(p+e.yyx)-map(p-e.yyx)
        ));
}

vec3 doColor(vec3 ro, vec3 rd, vec3 p, vec3 n, vec3 lp, float t)
{
    vec3 col = vec3(0.),
         objCol = vec3(trap, trap/dot(p,p), trap*trap)*5.,
         ld = lp - p;
    if (t < far)
    {
        float len = length(ld);
        ld /= len;
        float diff = max(dot(ld, n), 0.),
              atten = (1./len*len),
              amb = .25,
              spec = pow(max(dot(reflect(-ld, n), -rd), 0.), 8.);
        col = objCol * (((diff + amb*.2)+spec*.1)+atten*.1);
    }
    return col;
}

void mainImage( out vec4 f, in vec2 g )
{
	vec2 R = iResolution.xy, u = (g+g-R)/R.y;
    vec3 ro = vec3(0, 0, 1),
         rd = normalize(vec3(u, -1)),
         p = ro-ro,
         col = p,
         n = p,
         lp = vec3(1, 3, 5);
    float t = trace(ro, rd);
    p = ro + rd * t;
    n = calcNormal(p);
    col = doColor(ro, rd, p, n, lp, t);
    f = vec4(col, 1.);
}
