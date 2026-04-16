#define time iTime
uniform vec2 v2Resolution;
uniform float fFrameTime;

#define F float
#define V vec2
#define W vec3
#define N normalize
#define L length
#define rot(x) mat2(cos(x),-sin(x),sin(x),cos(x))
#define S(x) sin((x)+2.*sin((x)+4.*sin(x)))
#define col(x) (clamp(x,0.,1.)-cos((x+W(.3,.4,.5))*6.283)*.5+.5)

#define o fragColor

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	F B=texture(iChannel0,vec2(.02,.25)).r;
	o-=o;
	vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
	uv -= 0.5;
	uv /= vec2(iResolution.y / iResolution.x, 1);
	
	F i=0.,d=0.,e=1.;
	W rd=N(W(uv,1.)),p,P;
	rd.xz*=rot(.6*S(time*.05));
	for(;i++<99.&&e>.001;){
		p=P=rd*d;
		p.xy*=rot(.2*S(time*.1+P.z));
		p.y+=6.*S(.05*time);
		W stp=W(3.6+.6*sin(-P.z+time*.1),2000,4);
		p.z+=time*.6+.01*S(time);
		p.x-=stp.x/2.;
		p=mod(p-stp/2.,stp)-stp/2.;
		F ss=1.,s;
		for(F j=0.;j<13.;j++){
			p=abs(p);
			p-=W(.12,3.+.2*S(P.z*.2+time*.02),.2+.01*S(P.z));
			ss*=s=2.7/clamp(dot(p,p),.2,2.1);
			p*=s;
			p-=W(.1,.5+.2*(sin(B*P.x)*sin(P.x)),.2);
		}
		d+=e=(L(p)-1.4-.6*S(time*.2-P.z*.3-B))/ss;
		o+=.03*B/exp(500.*e) * (fract(P.y*90.+time+B*90.));
	}

	o.rgb+=(18./i);
	o.rgb*=col(cos(time*.2+log(P.z*.52))*.5+.5);
}
