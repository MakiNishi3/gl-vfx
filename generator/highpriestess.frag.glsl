#define blend(c,b) mix(c.rgb,b.rgb,b.a)
#define shape(d,s) smoothstep(s,0.,d)
#define skin_color vec3(.8,.6,.5)
#define eyes_color vec3(.5,.4,.2)
#define lips_color vec3(.8,.45,.4)
#define hair_color vec3(.1,.05,.0)
#define so texture(iChannel0,vec2(.3)).x

float box(vec2 p, vec2 c) {
	return length(max(vec2(0.),abs(p)-c));
}


mat2 rot(float a) {
    float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}

vec4 sphere(vec2 p) 
{
    p.y-=.6;
    p.x*=.85;
    float d=length(p)-.17;
    vec3 yellow=vec3(1.,.7,0.4)*exp(-3.*length(p+.05));
    p.y+=.14;
    p.y*=6.;
    float ring=length(p)-.2;
    d=min(d,ring);
    yellow=mix(yellow,vec3(.35,.3,.3),step(ring,.01));
    yellow+=exp(-17.*ring)*.01;
    return vec4(yellow,shape(d,.01));
}

vec4 horns(vec2 p) 
{
    vec2 pos=p;
    p*=.9;
    p.y-=.65;
    p.x=abs(p.x)-.23;
    p*=rot(-.5);
    p.x+=sin(p.y*17.+6.5)*.05;
    float d=box(p,vec2(.04-p.y*.2,.27));
    pos.y-=.39;
    pos.y*=2.;
    float rin=abs(length(pos)-.23)-.02;
    d=min(d,rin);
    pos.y*=5.;
    vec3 c=vec3(1.,.5,.3)*.6*exp(-10.*length(p.x));
    c=max(c,exp(-30.*rin)*.25*vec3(skin_color*2.));
    return vec4(c,shape(d,.01));
}

vec4 head(vec2 p) 
{
    p.y+=.01;
	p*=.77;
 	p.x*=1.-p.y*p.y;
    p.x*=1.45;
    p.x*=1.-p.y*.9;
    p.x*=1.-smoothstep(-.05,.1,-p.y)*.05;
    p.x*=1.+smoothstep(0.1,.4,-p.y)*.15;
    float d=length(p)-.3;
    return vec4(skin_color-d*.7,shape(d,.01));
}

vec4 neck(vec2 p) 
{
    p.y+=.4;
    p.x*=1.-smoothstep(0.,-.3,p.y)*.7;
    float d=box(p,vec2(.17,.4));
    return vec4(skin_color,shape(d,.01));
}


vec4 eyes(vec2 pos) 
{
	pos.y*=1.3;
    pos.y-=.01;
    vec3 c=vec3(1.);
    pos.x-=.145;
    vec2 p=pos;
    p.y*=1.5+p.x*p.x*20.;
    p.y+=smoothstep(0.05,.1,-p.x)*.05;
    p.y=abs(p.y-.05)+.055;
    float d1=length(p)-.09;
    c-=abs(1.-shape(d1+.01,.015))*.4;
    p=pos;
    p.y-=.045;
    float d2=length(p)-.03;
    float d3=length(p)-.012;
    c=mix(c,eyes_color,shape(d2,.01));
    c*=1.-shape(d3,.015);
    p+=.005;
    float d4=length(p)-.003;
    c+=shape(d4,0.01)*.5;
    return vec4(c,shape(d1,.01));
}

float eyelids(vec2 pos) 
{
    pos.y*=1.1;
    vec2 p=pos;
    p.x-=.135;
    p.y-=.085-p.x*p.x*7.+p.x*.25;
    p.y*=15.;
	float d1=length(p)-.07;
    p=pos;
    p.x-=.155;
    p.y-=.06-p.x*p.x*5.;
    p.y*=15.;
	float d2=length(p)-.07;
    p=pos;
    p.x-=.15;
    p.x*=.8;
    p.y+=.01-p.x*p.x*7.;
    p.y*=15.;
	float d3=length(p)-.07;
    return shape(d1,.01)*.15+shape(d2,.03)*.5+shape(d3,.01)*.03;
}

float eyebrows(vec2 p) 
{
	p.x-=.12+p.x*.2;
    p.y-=.11-p.x*p.x*4.-smoothstep(.03,.1,p.x)*.0;
    p.y*=6.;
    float d=length(p)-.05;
    return shape(d,.04)*.7*(.5+fract(p.x*100.+p.y*10.)*.5);
}

float nose(vec2 pos) 
{
    pos.x*=1.3;
    vec2 p=pos;
    p*=.9;
    p.y-=p.x*p.x*3.;
    p.x*=smoothstep(0.,.05,p.x);
    p.y+=.16+cos(p.x*90.)*.005;
    p.y*=15.;
	float d1=length(p)-.08;
    p=pos;
    p.x-=.047;
    p.y+=.17;
    p.y*=3.;
    float d2=length(p)-.005;
    p=pos;
    p.y+=.02;
    p.x-=.045+p.y*p.y*2.+p.y*.2;
    p.x*=10.;
    float d3=length(p)-.05;
    return shape(d1,.01)*.1+shape(d2,.03)*.15+shape(d3,.1)*.02;
}

float mouth(vec2 p) 
{
 	p.y+=.27-p.x*p.x*1.5;
    p.y*=10.;
    float d=length(p)-.08;
    return shape(d,.01)*.2;
}


vec4 lips(vec2 pos) 
{
    pos.y+=.0;
    vec2 p=pos;
    p.y+=.29-p.x*p.x*2.;
    p.y-=smoothstep(.03,.06,p.x)*.01;
    p.y*=8.;
    float d1=length(p)-.09;
    p=pos;
    p.y+=.25;
    p.y+=smoothstep(.03,.06,p.x)*.01;
    p.y*=8.;
    float d2=length(p)-.1;
    return vec4(lips_color,shape(min(d1,d2),.01));
}

vec4 hair(vec2 pos) {
    vec2 p=pos;   
    p.x+=sin(iTime+cos(iTime*5.+p.y*3.))*smoothstep(0.3,-2.,p.y)*.1*step(-0.1,-p.x);
    p.x+=sin(iTime+cos(iTime*3.+p.y*3.))*smoothstep(0.3,-2.,p.y)*.1*step(0.1,p.x);
    p.y-=.45;
    p.x*=1.+max(0.,p.x*.6);
    p*=rot(-p.x*7.*abs(p.x)-p.y*.6);
    p.y*=max(0.1,.9-abs(p.x)*1.2);
    float d1=box(p,vec2(1.3,.05));
    d1=max(d1,abs(pos.x+.02)-.45);
    d1=max(d1,pos.y-.6);
    vec3 h=hair_color+fract(p.y*50.+sin(p.x*50.)*.15)*0.2+smoothstep(.3,0.,abs(p.x))*.25-step(abs(p.x),.01)*.1;
    return vec4(h,shape(d1,.03));
}

vec4 hair2(vec2 pos) {
    vec2 p=pos;    
    p.y+=.5;
    float d1=box(p,vec2(.37,.5));
    vec3 h=hair_color+fract(p.x*40.+sin(p.y*20.)*.5)*0.2+smoothstep(.3,0.,abs(p.x))*.25-step(abs(p.x),.01)*.1;
    return vec4(h,shape(d1,.02));
}


float lighting(vec2 pos) {
    vec2 p=pos;
    p.y+=.14;
    p.y*=1.2;
    p.x*=.8;
	float d1=length(p)-.01;
    p.x-=.07;
    p.y*=.5;
    p.y+=.04;
	float d2=length(p)-.01;
    p=pos;
    p.y+=.26+cos(p.x*10.)*.02;
    p.y*=2.;
	float d3=length(p)-.05;
    p=pos;
    p.y-=0.04;
    p.x-=.14;
    p.y*=1.8;
	float d4=length(p)-.05;
    p=pos;
    p.y+=0.05;
    p.x*=5.;
	float d5=length(p*p)+.075;
    p=pos;
    p.y+=.24-p.x*.2;
	p.x*=.4;
    float d6=length(p)-.001;
    p=pos;
	p.x*=.4;
    p.y+=.34-p.x*p.x*10.;
    float d7=length(p)-.01;
    p=pos;
    p.y+=.5;
    p.x*=1.7;
	float d8=length(p)-.05;
    return shape(d1,.05)*.1+shape(d2,.1)*.1-shape(d4,.12)*.1+shape(d5,.1)*.4+shape(d7,.05)*.15+shape(d8,.2)*.12;
}

float arm(vec2 uv) {
 uv.x-=.5;
 uv.y=abs(uv.y)-.07;
 uv*=rot(-.1);
 return step(step(.52,abs(uv.x))+abs(uv.y+sin(uv.x*(5.+uv.x*25.))*.05*(1.-uv.x*2.)+uv.x*.07),.01);
}

float star(vec2 uv) {
    vec2 p=uv;
    p*=rot(iTime*.5);
    float c=0.;
    for (int i=0; i<17; i++) {
        c=max(c,arm(p));
        p*=rot(float(i)*3.1416*.25*.5);
    }
    c*=.5+uv.y*.7;
    return c;
}

vec3 background(vec2 p) {
    p.x-=.5;
    p.y+=.75;
    p*=.6;
    float st=star(p);
    vec3 fab=vec3(1.,.5,1.)*.3;
    float y=sin(p.x*10.-iTime*5.)*.04+p.y+p.x*(.5-p.x*.3);
    fab-=-.1+fract(y*3.)*.1;
    vec3 sky=vec3(.5,.8,1.)*exp(-1.*length(p-.1))+so;
    p*=rot(-iTime*.2);
    p=abs(fract(p)-.5);
    for (int i=0; i<6; i++) {
        p=abs(p)/dot(p,p)-.9;
    }
    sky+=step(length(p),.05)*.2;
    fab=mix(fab,sky,step(.5,y));
    return mix(fab,st*vec3(1.,.8,.5),st);
}


vec3 render(vec2 p) 
{
    p.y+=.1;
    p.x+=.2;
    p*=1.8;
	vec2 pos=p;
    p.x=abs(p.x);
	vec3 c=background(pos);
    c=blend(c,hair2(pos));
    c=blend(c,neck(p));
    c=blend(c,head(p));
    c=blend(c,eyes(p));
    c=blend(c,lips(p));
    c-=nose(p);
    c-=eyelids(p);
    c-=eyebrows(p);
    c-=mouth(p);
    c+=lighting(p);
    c=blend(c,hair(pos));
    c=blend(c,horns(pos));
    c=blend(c,sphere(pos));
    return c;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-iResolution.xy*.5)/iResolution.y;
	vec3 col = render(uv);
    vec2 uv2 = fragCoord/iResolution.xy-.5;
    col*=smoothstep(.54,.48,abs(uv2.x));
    col*=smoothstep(.54,.47,abs(uv2.y));
    fragColor = vec4(col,1.0);
}