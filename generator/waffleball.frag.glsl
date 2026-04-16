// Used to have https://soundcloud.com/socionode/younger-brother-psychic-gibbon but not working anymore
#define M_PI 3.1415926535897932384626433832795
#define r iResolution
#define t iTime
#define lw 0.001 * s3

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / r.x;
    vec2 m = vec2(1., r.y / r.x) / 2.;
    float s1 = texture( iChannel0, vec2( .2, 0. ) ).x;
    float s2 = texture( iChannel0, vec2( .5, 0. ) ).x;
    float s3 = .3 + .8 * texture( iChannel0, vec2( .8, 0. ) ).x;

    
   	float c = .0;
    
	const int MAX_N = 16;
    int N = 3 + int(s1 * 13.);
    float r1 = (m.x / 6.) + s1 / 10.;
    float r2 = (m.x / 6.) + s2 / 3.;
    float as = M_PI * 2. / float(N);
    for(int i = 0; i < MAX_N; i++)
    {
        float a = (M_PI * 2. + sin(t) * M_PI) + float(i) * as - t / 2.;
    	vec2 xy = m + vec2(cos(a) * r1, sin(a) * r1);
    	float d = distance(uv, xy);
        float ad = abs(d - r2);
        c += (.5 + .5 * sin(t * 4. + s3)) * clamp((1. - (ad / 10. - lw) / lw), 0., 1.);
        c = max(c, clamp(1. - (ad * 10. / s3), 0., 1.));
        if (i >= N - 1) break;
    }

    fragColor = vec4(
        c * (.5 + .5 * sin(t)),
        c * (.5 + .5 * cos(t / 2.)),
        c * (.5 + .5 * sin(t / 3.)),
        1.);
}
