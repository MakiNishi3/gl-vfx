mat2 rotate(in float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

float noise(in vec2 uv) {
	return sin(1.5*uv.x) * sin(1.5*uv.y);
}

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );

float fbm(vec2 uv) {
    float f = 0.0;
    f += 0.5000*noise(uv); uv = m*uv*2.02;
    f += 0.2500*noise(uv); uv = m*uv*2.03;
    f += 0.1250*noise(uv); uv = m*uv*2.01;
    f += 0.0625*noise(uv);
    return f/0.9375;
}

float fbm2(in vec2 uv) {
   vec2 p = vec2(fbm(uv + vec2(0.0,0.0)),
                 fbm(uv + vec2(5.2,1.3)));

   return fbm(uv + 4.0*p);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 p = -1. + 2. * uv;
    p.x *= iResolution.x / iResolution.y;

    float mp = cos(iTime + length(p));
    
    p *= rotate(length(p * .1));
    
    p = mod(p, .25 * mp) * mod(-p, .25 * mp);
    
    float d = length(p + fbm2(abs(p) + iTime * .3) * .02  );
    
	float fft = texture(iChannel0, vec2(d,0.25)).x;
    
    vec3 col = vec3(.2, 1. * fft, .4 * fft) * fft;

	fragColor = vec4(col,1.0);
}