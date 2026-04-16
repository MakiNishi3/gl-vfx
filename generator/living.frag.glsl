// "Living in a Box - WIP" by neriakX.
// 2022-11-26

/* inspired by Flopine's and evvvvil's twitch streams

this is my first attempt in ray marching.
just starting to mess around with (hopefully) simple stuff ...
I took some functions from iq also => https://iquilezles.org/articles/distfunctions

there's a lot of stuff missing and funky things are happening :)

*/

#define FOV .5
#define ITER 64.
//#define PI acos(-1.0)
//#define TAU PI*2
#define tt mod(iTime,62.82)
#define tc (iChannelTime[0] - .1)
#define bpm (129./60.+1.2)

const float PI = acos(-1.0),
TAU = 2.*PI;
const vec2 BEAT = vec2(200./440.*0.0390,.05);
float t, scene, g1=0.;
vec2 sc;
vec3 np, no, al, po, ld;




// smin function
float smin(float a, float b, float h){
  float k=clamp((a-b)/h*.5+.5,0.,1.);
  return mix(a,b,k)-k*(1.-k)*h;
}

// smin2 function
vec2 smin2(vec2 a, vec2 b, float h){
  float k=clamp((a.x-b.x)/h*.5+.5,0.,1.);
  return mix(a,b,k)-k*(1.-k)*h;
}

// iq's Tools
float un( float d1, float d2 ) { return min(d1,d2); }
float sub( float d1, float d2 ) { return max(-d1,d2); }
float isec( float d1, float d2 ) { return max(d1,d2); }

float ssub( float d1, float d2, float k ){
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); 
}

vec3 opRepLim( in vec3 p, in float c, in vec3 l){
    vec3 q = p-c*clamp(round(p/c),-l,l);
    return q;
}

// rotation function
mat2 r2 (float a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }


//sphere
float sp(vec3 p, float r) { return length(p)-r; }

//diamond
float di (vec3 p, float s){
    float lx = length(p.x);
    float ly = length(p.y);
    float lz = length(p.z);
    return sqrt(lx+ly+lz)-s;   
}

// box
float bo (vec3 p, vec3 c){
    float r = 0.12;
    vec3 q = abs(p)-c;
    //return length(max(q, 0.)) + min(0., max(q.x,max(q.y,q.z)));  
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) -r; // rounded
}

// unsigned box
float ub (vec3 p, vec3 c){
    vec3 q = abs(p)-c;
    return length(max(q , 0.));   
}

// Cylinder
float cy (vec3 p, float r, float height){
    return max(length(p.xy)-r,abs(p.z)-height); 
}

// lighting
float lighting (vec3 n, vec3 l){
  //return max(0., dot(n, l)); // more toonish light
  return dot(n,l)*0.5+0.5; // more real light
}


// Camera
/* vec3 camera (vec3 ro, vec3 ta, vec2 uv, float fov)
{
    vec3 f = normalize(ta-ro);
    vec3 l = normalize(cross(vec3(0.,1.,1.), f));
    vec3 u = normalize(cross(f, l));
    return normalize(f*fov + l*uv.x + u*uv.y);
} */



//Noise function stolen form evvvvil who stole from Virgil who stole it from Shane
float noise(vec3 p){ 
  vec3 ip=floor(p),s=vec3(7,157,113);
  p-=ip;
  vec4 h=vec4(0,s.yz,s.y+s.z)+dot(ip,s);
  p=p*p*(3.-2.*p);
  h=mix(fract(sin(h)*43758.5),fract(sin(h+s.x)*43758.5),p.x);
  h.xy=mix(h.xz,h.yw,p.y);
  return mix(h.x,h.y,p.z);
}

// the box
vec2 sbx (vec3 p, vec3 s)
{	

    //p.x -= 2.5*sin(bpm*tt/4.);
    p.yz *= r2(bpm*tt);
    p.xz *= r2(bpm*tt);
    //p.y += 2.2*sin(bpm*tt*4.);
    vec2 h,t=vec2(bo(p, s-0.7*sin(texture(iChannel0,BEAT).x)),11.);
    return t;
}


// the sphere
vec2 bs (vec3 p)
{	
    // bouncing sphere 
    p.x -= 2.5*sin(bpm*tt/4.);
    //p.xz *= r2(tt);
    p.y += 2.2*sin(bpm*tt*2.);
    vec2 h,t=vec2(sp(p, 1.3),11.);
    return t;
}

// the diamond
vec2 sdd (in vec3 p) {
    float per = 3.0; 
    p.x -= -2.*sin(bpm*tt/4.)-2.*cos(bpm*tt/4.);
    p.y -= sin(bpm*tt*1.8);
    p.yz *= r2(bpm*tt*1.115);
    p.xz *= r2(bpm*tt/4.);
    
    vec2 h,t=vec2(di(p,1.3),11.);
    if (tt > 30.) {
        //p.yz *= r2(bpm*tt*1.8);
        p.xz *= r2(-0.5*sin(bpm*tt/8.)+0.1*cos(bpm*tt/8.));
        return t;
    } else {    
        p.xz *= r2(1.8*sin(bpm*tt/8.)-1.8*cos(bpm*tt/8.));
    }
    return t;
}

// the room
vec2 rtr (vec3 p)
{   
  	// moving room
   
    
    p.xz *= r2(-bpm*tt/4.);
    if (tt>30.){
        p.yz *= r2(-bpm*tt/4.);
    } else {
        p.yz *= r2(atan(sin(tt)*.5));
    }
    vec2 h,t = vec2(-bo(p, vec3(20.,4.0,20.)),5.);

    // cut the room with cylinders
    float per = 2.5; //period - Wiederholungen - netter Wert 1.9 o. 2.5
    p.xz = mod(p.xz, per)-per *0.5; // repeat
	h=vec2(cy(p.xzy,0.7, 5.0*1.05+sin(texture(iChannel0,BEAT).x*6.)),5.); // 1e10
    t.x=ssub(h.x, t.x, .03);
    return t; 
}

// the scene
vec2 map (vec3 p) 
{ 	
    np=p;
    vec2 h,t=rtr(p);
    if (tc>15.) {
        h=sdd(p);
    } else {
        h=sbx(p,vec3(1.7));
    }
    g1 += 0.01/(0.01+h.x*h.x)*0.12;
   	t=(t.x<h.x)?t:h;
   	t.x*=0.6;
    return t;
}

// main raymarching function
vec2 tr (vec3 ro, vec3 rd) 
{    
    vec2 h,t=vec2(0.1);
    for(float i=0.;i<ITER;i++){
        h=map(ro+rd*t.x);
        if(h.x<.0001||t.x>ITER) break;
        t.x+=h.x;t.y=h.y;
        //t+=h;
    }
    if (t.x>ITER) t.x=0.;
    return t;
}

// get Normals (iq)
vec3 calcNormal( in vec3 po )
{	
    vec2 e=vec2(.00035,-.00035);
    return normalize(e.xyy*map(po+e.xyy).x+
        e.yyx*map(po+e.yyx).x+
        e.yxy*map(po+e.yxy).x+
        e.xxx*map(po+e.xxx).x); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=(fragCoord.xy/iResolution.xy-0.5)/vec2(iResolution.y/iResolution.x,1);
    
    // ray_origin / camera
    vec3 ro = vec3(0.,0.,6.), //ray origin is 0.,0.,6. in space - step back
    cw=normalize(vec3(0.,1.,0.)-ro),
    cu=normalize(cross(cw, vec3(0.,0.,1.))),
    cv=normalize(cross(cu,cw)),
    rd=mat3(cu,cv,cw)*normalize(vec3(uv,FOV)),
    co,fo,
    ld=normalize(vec3(0.5,.4,-.1));

    co=fo=vec3(0.2)*(1.-length(uv)-0.2);
       
    sc=tr(ro,rd); // sc.x = distance geometry, sc.y = colour
    t=sc.x; // t is the result of the geometry
    
    if (t>0.) 
    {	
        po=ro+rd*t;
        vec3 no = calcNormal(po),
        al=vec3(0,.2,.8);
        
        // colouring
        if(sc.y<5.) al=vec3(0);
    	if(sc.y>5.) al=vec3(1);
        if(sc.y>6.) al=vec3(.0, .04, .18);
        if(sc.y>9.) al=vec3(.18, .08, .0);
        if(sc.y>10.5) al=vec3(.6, .3, .7);
        
    	float dif=dot(no,ld)*0.5+0.5,// diffuse
    	aor=t/50.,ao=exp2(-2.*pow(max(0.,1.-map(po+no*aor).x/aor),2.)), //ao = ambient occlusion, aor = ambient occlusion range
    	spo=exp2(1.+3.*noise(np/vec3(0.4,.8,.8)+noise(np/vec3(0.1,.2,.2)))),
    	fr=pow(1.+dot(no,rd),4.);
    	vec3 sss=vec3(0.5)*smoothstep(0.,1.,map(po+ld*0.4).x/0.4), //Fake sub surface scattering, from tekf https://www.shadertoy.com/view/lslXRj
    	sp=vec3(0.5)*pow(max(dot(reflect(-ld,no),-rd),0.),30.); //specular by shane.

    	co=mix(sp+al*(0.8*ao+0.2)*(dif),fo,fr); //final lights
        co += g1*vec3(0.2,0.1,0.2);
        co=mix(co, vec3(0.035*texture(iChannel0,BEAT).x,0.,0.045)*texture(iChannel0,BEAT).x*0.8, 1.-exp(-0.0033*t*t*t)); // purple fog blinking
        
        fragColor = vec4(pow(co, vec3(.45)),1.); // gamma correction
        fragColor *= 1.2-dot(uv, uv);// vignette
    }
}
