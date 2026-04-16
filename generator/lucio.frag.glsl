#define eps 3./iResolution.x
float rdith(vec2 uv)
{
    return .02*fract(sin(dot(uv,vec2(17.12,1.26))*10.)*513.1);
}

float sqrts(float a)
{return sqrt(max(a,.1));}
vec3 lucio(vec2 uv)
{
        uv.x = abs(uv.x);
    vec3 bg = vec3(.2,.6,.05);
    float sh = smoothstep(eps,0.,length(uv)-.5);
    sh*=smoothstep(eps,0.,pow(sqrt(3.*uv.x*uv.x+.1),.25)-1.1-uv.y);
    sh*=smoothstep(eps*2.2,0.,2.2*uv.y-sqrts(1.-4.84*uv.x*uv.x)+.1);
    sh*=mix(1.,smoothstep(0.,eps*2.4,2.4*uv.y-sqrts(1.-5.76*uv.x*uv.x)+.1),
           smoothstep(0.,eps,uv.y-.1-.3*sqrt(uv.x)*(sqrt((uv.x*3.-.5)*(uv.x*3.-.5)+.01)))) ;
    sh*=smoothstep(0.,eps,abs(uv.x-.45)-.002);
    sh*=mix(1.,smoothstep(0.,eps,abs(uv.x+.07*uv.y-.02*sin(-15.*uv.y)-.35)-.01*abs(sin(-10.*uv.y)))
            ,smoothstep(eps,0.,uv.y-.195));
    sh*=smoothstep(0.,eps,length(uv-vec2(.2,.0))-.06);
    sh*=mix(1.,smoothstep(0.,eps,abs(uv.y-.1*exp(uv.x*uv.x*10.)+.25)-.005),
            smoothstep(eps,0.,uv.x-.18));
    return mix(bg,vec3(1),sh);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.*fragCoord.xy - iResolution.xy)/iResolution.x;
    vec3 col = lucio(uv);
	float wave = texture(iChannel0,vec2(abs(uv.x)*2.-1.,1.)).r;
    col = mix(col, vec3(1.,1.,.2),smoothstep(0.,.1,abs(uv.x)-.5)*
              (smoothstep(.02,0.,abs((1.-wave)*.4-uv.y-.2))+.7*smoothstep(.2,0.,abs(wave*.5-uv.y-.25))));
	fragColor = vec4(col*smoothstep(1.,.2,length(fragCoord/iResolution.xy-.5))+rdith(uv),1.0);
}
