float li (vec2 uv ,vec2 a, vec2 b) { vec2 ua = uv-a;  vec2 ba = b-a;
    float h = clamp(dot(ua,ba)/dot(ba,ba),0.,1.);
    return length(ua-ba*h);}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec2 uv = fragCoord.xy / iResolution.xy;
	float uc = uv.x*0.6;
    float nbr = 200.;
   vec2 ba = vec2(fract(uc*nbr),uv.y*nbr);
    float u = floor(uc*nbr)/nbr;
	float f0 = (pow(texture( iChannel0, vec2(u,0.64)).x,0.5)-0.62)*100.;
    float f1  = (texture( iChannel0, vec2(u,0.64) ).x-0.4)*100.;
    float f2  = (texture( iChannel0, vec2(u,0.) ).x-0.24)*40.;
	float l = smoothstep(0.2,0.,li(ba,vec2(0.5,30.-f0),vec2(0.5,30.+f0)));

    fragColor = vec4(l);
}