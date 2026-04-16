#define time iTime
#define resolution iResolution

float s;

mat2 rot(float a) {
    float s=sin(a);
    float c=cos(a);
    return mat2(c,s,-s,c);
}


float t;

vec3 fractal(vec2 p) {
    p=vec2(abs(atan(p.x,p.y)/3.1416*sin(time*.1)*6.),length(p));
    p.y-=tan(time*.1);
    p.x=fract(p.x-t)+.5;
    vec2 m=vec2(1000);
    float ml=100.;
    for (int i=0; i<4; i++) {
        p=abs(p)/clamp(abs(p.x*p.y),.1,.6)-3.;
        m = min(m, abs(p))+fract(p.x*.2+time*.5)+fract(p.y*.2+time);
        ml=min(ml,length(p));;
    }
    m=exp(-1.5*m);
    vec3 c=vec3(m.x*3.,length(m),m.y*2.)*1.;
    //c.gb*=rot(time*2.);
    //c=-abs(c);
    //c=mix(c.rbb,c,.3);
    ml=exp(-3.*ml)*3.*s;
    c+=ml;
    return c;
}

float getSound() 
{
    float s=0.;
    for (float i=0.; i<20.; i++) {
        s+=texture(iChannel0,vec2(0.,i/20.)).r;
    }
    for (float i=0.; i<20.; i++) {
        s+=texture(iChannel0,vec2(i/20.,0.)).r;
    }
    return s/25.;
}

void texto(inout vec3 col, vec2 offset) {
    vec2 uv=gl_FragCoord.xy/iResolution.xy;
    uv.y=1.-uv.y;
    vec4 tx = texture(iChannel1, uv+offset);
    col = mix(col, tx.rgb, length(tx.rgb));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    s=getSound();
    vec2 uv = -1. + 2. * fragCoord/resolution.xy;
    vec2 puv = uv;
    t=time*.1;
    uv.x*=resolution.x/resolution.y;
    uv.x*=1.-uv.y*.7;
    uv*=1.5-s*.3;
    //uv+=vec2(sin(t),cos(t))*.5;
    //t*=.5+floor(length(uv)*6.)*.1;
    t+=smoothstep(.0,.2,fract(length(uv*.5)-time*.5));
 //   uv*=1.+exp(-3*length(uv))*spectrum.x*100;
    //uv=abs(.5-fract(uv));
    vec3 c=fractal(uv);
    c+=exp(-2.*length(uv))*(1.+4.*s*s);
    c*=vec3(1.2,.9,.8);
    texto(c, vec2(-0.35,-0.4));
    fragColor = vec4(c, 1.0);//*mod(gl_FragCoord.y,10.)*.1;
}



