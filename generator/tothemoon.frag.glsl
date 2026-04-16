#define rays 20.
#define starlayers 5.
#define nebulalayers 4.

vec2 noise(vec2 uv) {
    return fract(1234.1234 * sin(1234.1234 * fract(1234.1234 * uv) + uv.yx));
}

vec4 fbm(vec2 v) {
    float t = 0.;
    vec4 n = vec4(0.);
    float b = 1./32.;
    for (float s = 1.; s > b; s *= 0.5) {
        t += s;
    	n += texture(iChannel1, b / s * v) * s;
    }
    return n / t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime + 300.;
    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;
	vec2 polar = vec2(atan(uv.y, uv.x), length(uv));
    float r = mod(polar.x + time * .1,  6.28318 / rays);
    float r1 = r - 3.14159 / rays * 1.5;
    float r2 = 3.14159 / rays * .5 - r;
    float ray = 1.-smoothstep(fwidth(r1), -fwidth(r1), r1) 
        * smoothstep(fwidth(r2), -fwidth(r2), r2) + fwidth(r)*.75;
    float c = (texture(iChannel0, vec2(0., 0.)).x) * .1 + .05 - polar.y;
    float circle = smoothstep(fwidth(c), -fwidth(c), c);
    float starDist = 10000.;
    for (float k = 0.; k < starlayers; k++) {
        float kt = mod(k - iTime * .1, starlayers);
        vec2 tiled = uv * 10. * kt;
        vec2 tileUV = 2. * fract(tiled) - 1.;
        vec2 tileID = floor(tiled);
        vec2 n = noise(tileID + .1);
        float size = n.x * .1;
        float invSize = 1. - size;
        starDist = min(starDist, smoothstep(1., 0., kt) + length(tileUV + invSize * sin(time * noise(tileID))) - size);
    }
        
    float fx = floor(mod(polar.x + time * .1, 6.28318) / 6.28318 * rays) / rays + 1. / rays;
    float fft = texture(iChannel0, vec2(fx, 0.)).x + .2;
    
    float fbmTotal = 0.;
    float totalWeight = 0.;
    for (float k = 0.; k < nebulalayers; k++) {
        float kt = mod(k - iTime * 1., nebulalayers);
        vec4 f = fbm(uv * kt * .05 + k);
        float weight = smoothstep(0., 1., kt) * smoothstep(nebulalayers, nebulalayers - 1., kt);
        fbmTotal += weight * fbm(f.xy + time * .03).x * 1.;
        totalWeight += weight;
    }
    fbmTotal /= totalWeight;
    float l = mix(1., ray*circle, fft);
    float st = clamp(.5 + fft - polar.y * .5, 0., 1.);
    st *= st;
    st *= st;
    st = mix(st, step(starDist, 0.), l);
    vec3 color = (.7+.3*sin(time * vec3(.1, .11, .111)));
    fragColor = vec4(st * .3 + (2. - polar.y) * fbmTotal * color, 1.);
}