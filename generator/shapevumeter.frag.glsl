#define PI (3.14159265358979323)
float rand (in vec2 uv) { return fract(sin(dot(uv,vec2(12.4124,48.4124)))*48512.41241); }
const vec2 O = vec2(0.,1.);
float noise (in vec2 uv) {
	vec2 b = floor(uv);
	return mix(mix(rand(b),rand(b+O.yx),.5),mix(rand(b+O),rand(b+O.yy),.5),.5);
}

#define DIR_RIGHT -1.
#define DIR_LEFT 1.
#define DIRECTION DIR_LEFT

#define LAYERS 8
#define SPEED 60.
#define SIZE 5.


float dfSemiArc(float rma, float rmi, vec2 uv)
{
	return max(abs(length(uv) - rma) - rmi, uv.x-0.0);
}

float dfSemiArc2(float rma, float rmi, vec2 uv)
{
	return min(abs(length(uv) - rma) - rmi, uv.x+4.0);
}



float dfQuad(vec2 p0, vec2 p1, vec2 p2, vec2 p3, vec2 uv)
{
	vec2 s0n = normalize((p1 - p0).yx * vec2(-1,1));
	vec2 s1n = normalize((p2 - p1).yx * vec2(-1,1));
	vec2 s2n = normalize((p3 - p2).yx * vec2(-1,1));
	vec2 s3n = normalize((p0 - p3).yx * vec2(-1,1));
	
	return max(max(dot(uv-p0,s0n),dot(uv-p1,s1n)), max(dot(uv-p2,s2n),dot(uv-p3,s3n)));
}

float dfRect(vec2 size, vec2 uv)
{
	return max(max(-uv.x,uv.x - size.x),max(-uv.y,uv.y - size.t));
}

//--- Letters ---
void G(inout float df, vec2 uv)
{
	
	df = min(df, dfSemiArc(0.5, 0.125, uv));
	df = min(df, dfQuad(vec2(0.000, 0.375), vec2(0.000, 0.625), vec2(0.250, 0.625), vec2(0.25, 0.375), uv));
	df = min(df, dfRect(vec2(0.250, 0.50), uv - vec2(0.0,-0.625)));
	df = min(df, dfQuad(vec2(-0.250,-0.125), vec2(-0.125,0.125), vec2(0.250,0.125), vec2(0.250,-0.125), uv));	
}

void I(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.280,-0.625)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-0.45,0.40)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-0.45,-0.625)));
}

//

void A(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.550,-0.625)));
    df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.1,-0.625)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-0.50,0.38)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-0.50,-0.20)));
   
}


void T(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.550,-0.625)));
    df = min(df, dfRect(vec2(0.700, 0.25), uv - vec2(-0.8,0.38)));
    
 
   
}

void R(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-1.0,-0.625)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-0.95,0.38)));
   df = min(df, dfRect(vec2(0.200, 0.60), uv - vec2(-0.600,-0.10)));
    df = min(df, dfRect(vec2(0.450, 0.25), uv - vec2(-0.95,-0.10)));
    
  //  df = min(df, dfRect(vec2(0.450, 0.25), uv - vec2(-0.80,-0.10)));

   df = min(df, dfQuad(vec2(-0.900,-0.100), vec2(-0.600,-0.100), vec2(-0.350,-0.625), vec2(-0.550,-0.625), uv));
   
   
}

void OO(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-1.20,-0.625)));
    df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.750,-0.625)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-1.10,0.38)));
    df = min(df, dfRect(vec2(0.550, 0.25), uv - vec2(-1.10,-0.625)));
   
}

void N(inout float df, vec2 uv)
{
	df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-1.30,-0.625)));
    df = min(df, dfRect(vec2(0.200, 1.25), uv - vec2(-0.650,-0.625)));
   df = min(df, dfQuad(vec2( -1.300,.625), vec2(-1.000,0.625), vec2(-0.450,-0.625), vec2(-0.650,-0.625), uv));
}





void S(inout float df, vec2 uv)
{
	df = min(df, dfSemiArc(0.25, 0.125, uv - vec2(-0.250,0.250)));
	df = min(df, dfSemiArc(0.25, 0.125, (uv - vec2(-0.125,-0.25)) * vec2(-1)));
	df = min(df, dfRect(vec2(0.125, 0.250), uv - vec2(-0.250,-0.125)));
	df = min(df, dfQuad(vec2(-0.625,-0.625), vec2(-0.500,-0.375), vec2(-0.125,-0.375), vec2(-0.125,-0.625), uv));	
	df = min(df, dfQuad(vec2(-0.250,0.375), vec2(-0.250,0.625), vec2(0.250,0.625), vec2(0.125,0.375), uv));
}
//---------------

//--- From e#26829.0 ---
float linstep(float x0, float x1, float xn)
{
	return (xn - x0) / (x1 - x0);
}
 



vec3 hsv(float h,float s,float v) {
	return mix(vec3(1.),clamp((abs(fract(h+vec3(3.,2.,1.)/3.)*6.-3.)-1.),0.,1.),s)*v;
}

// s is for scale, r is for rotation// supershape from glslsandbox !
float supershape(vec2 p, float m, float n1, float n2, float n3, float a, float b, float s, float r) {
	float ang = atan(p.y * iResolution.y, p.x * iResolution.x) + r;
	float v = pow(pow(abs(cos(m * ang / 4.0) / a), n2) + pow(abs(sin(m * ang / 4.0) / b), n3), -1.0 / n1);
	return 1. - step(v * s * iResolution.y, length(p * iResolution.xy)); 
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p=(fragCoord.xy/iResolution.xy)-.5;
    
    float time=iTime;
    
    float snd=texture(iChannel0,p/1000.).x;
    vec4 color=vec4(0.2);
    color += supershape(p - vec2(0.0, 0), 8.0, 1.0, 8.0, 4.0, 1.0, 1.0, 0.01+snd/8., sin(time));
    // include texture ... computer code no limit !
    color *= 0.8-texture(iChannel1,p+time*0.2);
    
    
    vec3 c = vec3(1.0, 0.0, 0.);
	if(p.x < -0.166)
		c = vec3(0, 0.0, 0.874);
	else if(p.x > -0.50 && p.x < 0.166) 
		c = vec3(1.0, 1.0, 1.0);
        
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv=p;
    
    float stars = 0.;
	float fl, s;
	for (int layer = 0; layer < LAYERS; layer++) {
		fl = float(layer);
		s = (400.-fl*20.);
		stars += step(.1,pow(noise(mod(vec2(uv.x*s + iTime*SPEED*DIRECTION - fl*100.,uv.y*s),iResolution.x)),18.)) * (fl/float(LAYERS));
	}        
        
  // logo !
    float t=time*2.0;
    float bf=1.4;
	uv = (uv - uv/2.0)*16.0*abs(sin(t*0.2+bf/12.));

	float dist = 1e6;
	
	float charSpace = 1.025;
	
	vec2 chuv = uv;
	chuv.x += charSpace * 3.0;
    
    G(dist, chuv-vec2(-0.0,abs(sin(t*2.+bf/6.)))); chuv.x -= charSpace;
    
    I(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*2.0)))); chuv.x -= charSpace;
    G(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*3.0)))); chuv.x -= charSpace;
    A(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*4.0)))); chuv.x -= charSpace;
    T(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*5.0)))); chuv.x -= charSpace;
    R(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*6.0)))); chuv.x -= charSpace;
    OO(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*7.0)))); chuv.x -= charSpace;
    
	N(dist, chuv-vec2(0.0,abs(sin(t*2.+bf/6.*8.0)))); chuv.x -= charSpace;

	
	float mask = smoothstep(8.0/iResolution.y,0.008,dist);
    
       
    
    
        vec3 textcol =  vec3(.2);
    	  
    
    	 fragColor = vec4(-1.+color);
         if(s>0.00)fragColor += 2.*vec4( vec3(stars), 1.0 );
		 fragColor += vec4(c,1.0);
         fragColor += vec4(2.*textcol*mask,1.0);
    // and you have a nice demo with mixing glsl.. so we can mix all shadertoy's  !!
}
