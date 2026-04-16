float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 center = iResolution.xy / 2.0;
    vec2 p = center - fragCoord;
    vec2 polar = vec2(length(p), atan(p.y, p.x));
    //float rf = rand(vec2(trunc(polar.y * 100.) / 100., 0)) * 0.05;
    float freq = abs((trunc(polar.y * 100.) / 100.) / radians(180.0));
    float fft = texture(iChannel0, vec2(freq, 0.25)).x;
    float wave = texture(iChannel0, vec2(freq, 0.75)).x * 0.3;
    vec3 hsv = vec3(
        polar.y / radians(180.0) + wave + iTime + polar.x / 100.,
        0.75,
        //sin(polar.x / (10. + sin(iTime) * 5.)) + 1.2);
        //0, 0, rf);
        sin(polar.x / (9. + fft + sin(iTime) * 5.)) + 1.2);
	fragColor = vec4(hsv2rgb(hsv), 1.0);
}