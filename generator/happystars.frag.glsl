#define AA_SIZE 2.0
#define pi 3.141592653589793

float star(vec2 uv) {
	float a = atan(uv.y,uv.x);
    float r = length(uv);
    float starR = 0.5+0.25*pow(sin(a*2.5+iTime), 2.0);
    return r < starR ? 1.0 : 0.0;
}

float pointyStar(vec2 uv, float r, float rotation) {
	float a = atan(uv.y,uv.x);
    float len = length(uv);
    float starR = r/0.75 * (0.5+0.25*(abs(mod(a*2.5+rotation, pi)/(0.5*pi)-1.0)));
    return len - starR;
}

float pointyStars(vec2 uv) {
    uv *= vec2(18.0, 16.0);
    float idx = mod(floor(0.5*uv.x)*0.5+8.2, 16.0);
    float val = texture(iChannel0, vec2(idx/18.0, 0.0)).r;
    float yFac = pow(max(0.0, val - floor((0.5*uv.y)+8.0)*0.5/8.0), 0.2);
    float phase = floor(0.5*uv.x)-floor(0.5*uv.y)+iTime*3.14159;
    return pointyStar(mod(uv, vec2(2.0))-1.0, yFac*1.2-0.2, 2.0*cos(1.0*phase));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float bass = texture(iChannel0, vec2(0.3, 0.0)).r;
    fragColor = vec4(0.0);
    for (float x=0.0; x < AA_SIZE; x++) {
        for (float y=0.0; y < AA_SIZE; y++) {
            vec2 aspect = vec2(iResolution.x/iResolution.y, 1.0);
            vec2 uv = (fragCoord.xy + vec2(x,y)/AA_SIZE) / iResolution.xy;
            uv = (2.0 * uv - 1.0) * aspect;
            float starD = pointyStars(uv);
            float bigStarD = pointyStar(uv+vec2(sin(iTime*2.8)*0.3 + tan(iTime*0.6) + cos(iTime*0.7), sin(iTime*0.8) + tan(iTime*0.5) + cos(iTime*1.6)*0.1), 0.6+0.3*(0.5-0.5*cos(bass*pi)), pi*iTime);
            vec4 stars = vec4(1.2-0.8*abs(sin(uv*3.0)),0.7+0.3*sin(iTime+3.0*uv.x*uv.y),1.0) * float(starD < 0.0);
            vec4 glow = vec4(0.0);
            if (starD > 0.07) {
                glow = vec4(1.0, 1.0, 0.5, 1.0)*max(0.0, step(0.0, 0.1-starD));
            }
            float a = -0.3;
            uv.y += cos(iTime+uv.x*8.0+uv.y)*0.025;
            vec2 ruv = mat2(cos(a), sin(a), -sin(a), cos(a)) * uv * (1.0+0.25*(uv.y+1.7));
            vec2 checkerBoard = 0.5+0.5*sign(pow(sin(ruv*8.0), vec2(20.0))-0.5);
            vec2 checkerBoard2 = 0.5+0.5*sign(pow(sin((ruv)*8.0), vec2(8.0))-0.5);
            float c0 = max(checkerBoard.x, checkerBoard.y);
            float c1 = max(checkerBoard2.x, checkerBoard2.y);
		    float mval = texture(iChannel0, vec2((4.5*uv.x+8.2)/64.0, 0.0)).r;
            vec4 ccol = mix(vec4(mval*1., 0.6, 1.3-mval, 1.0), vec4(2.9*mval, mval, 0.25, 1.0), 1.0-c0);
            vec4 bg = mix(vec4(1.58*mval,0.95,(1.3-mval)*0.75,1.0), ccol, max(c0, c1))*float(starD > 0.07)*float(bigStarD > 0.02);
            vec4 bigStar = vec4(0.4, 0.5, 0.8, 1.0)*float(starD > 0.07)*float(bigStarD < 0.0); 
            bg = mix(bg, vec4(0.2, 0.5, 0.9,1.0), max(0.0, min(0.5, abs(1.5-(ruv.y*0.3+1.7)))));
            vec4 col = bg + bigStar + stars + glow;
            fragColor += col;
 		}
    }
    fragColor /= AA_SIZE * AA_SIZE;
}