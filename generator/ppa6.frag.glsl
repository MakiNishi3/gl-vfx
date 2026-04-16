/*

	Tunnel6 a.k.a "Polish up"
    for cooperation of polish demoscene musicians, called:
    
    
    "Power Packed Alliance".
    -----------------------------------

	https://www.youtube.com/watch?v=_lSReW7eRI4
    http://www.pouet.net/prod.php?which=70247

	
    
    also check my chrome extension for Shadertoy:
    https://chrome.google.com/webstore/detail/shadertoy-unofficial-plug/ohicbclhdmkhoabobgppffepcopomhgl?hl=pl

*/

#define getNormal getNormalHex

#define INFINITY 1e32
#define FAR 30.
#define t iTime
#define mt iTime * 1.2 
#define FOV 90.0
#define FOG .7

#define PI 3.14159265
#define TAU (2*PI)
#define PHI (1.618033988749895)

vec3 os;

vec3 pal( in float ta, in vec3 a, in vec3 b, in vec3 c, in vec3 d ){return a + b*cos( 6.28318*(c*ta+d) );}

// 	3D noise function (IQ)
float noise(vec3 p)
{
	vec3 ip=floor(p);
    p-=ip; 
    vec3 s=vec3(7,157,113);
    vec4 h=vec4(0.,s.yz,s.y+s.z)+dot(ip,s);
    p=p*p*(3.-2.*p); 
    h=mix(fract(sin(h)*43758.5),fract(sin(h+s.x)*43758.5),p.x);
    h.xy=mix(h.xz,h.yw,p.y);
    return mix(h.x,h.y,p.z); 
}

float yC(float x) {
 	return cos(x * -.134) * 1. * sin(x * .13) * 15.+ noise(vec3(x * .01, 0., 0.) * 55.4);
}

float vol = 0.;

vec3 light = vec3(0.0);
vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// Repeat in three dimensions
vec3 pMod3(inout vec3 p, vec3 size) {
	vec3 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5, size) - size*0.5;
	return c;
}

float opU2( float d1, float d2 ) {
    if (d1 < d2) return d1;
    return d2;
}

vec3 opU2( vec3 d1, vec3 d2 ) {
    if (d1.x < d2.x) return d1;
    return d2;
}

vec3 opS2( vec3 d1, vec3 d2 )
{	
    if (-d2.x > d1.x) return -d2;
    return d1;
}

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float fCross(vec3 p, vec3 size) {
    float obj = fBox(p, size);
    obj = opU2(obj, fBox(p, size.zxy));
    obj = opU2(obj, fBox(p, size.yzx));               
    return obj;
}

vec3 map(vec3 p) {
    p.y -= yC(p.x);
    vec3 
        obj = vec3(FAR, 0.0, 0.0),
        obj2 = obj,
        obj3 = obj;
    
    vec3 orgP = p;
    vec3 orgP3 = orgP;

	orgP3 = p;
    
    vec3 pp = pMod3(orgP3, vec3(2.4));
    p = orgP3;
    
    obj = vec3(
        fBox(p, vec3(1.05)), 
        1.0, 
        1.0
    );
    
    vec3 orgP2 = orgP;
    
    pR(orgP.zy, orgP.x / 12.);
	
    vec3 size = vec3(0.725 , 1.5, 1.275);
    
    p = opRep(orgP, vec3(0.35, 0.1, .4) + size.x + size.y + size.z);
    
    obj = opS2(
        obj, 
        vec3(                
            fCross(p, size), 
            0.0, 
            1.0
        )
    );
	
    size *= 1.2;
    p = opRep(orgP, vec3(0.35, 0.5, 0.1) + size.x + size.x + size.z);
    
    obj = opS2(
        obj, 
        vec3(                
            fCross(p, size), 
            0.0, 
            1.0
        )
    );
    p = orgP2;
    float n = noise(p);
  	pR(p.yz, p.x * .8 + n * 7.);
    p.y += .6;
   
    p = orgP2;

    obj = opS2(obj, vec3(fCross(p, vec3(1e32, .6, .6) ), 1., 1.)); 

	obj3.x = mix(-length(p.zy) + 1., obj3.x,  .6  *  n)- .1;
    obj3 = opU2(obj, vec3(fBox(p, vec3(1.1))));
	os = p;
    
    return obj3;
}

vec3 trace(vec3 prp, vec3 scp) {
    vec3 
        tr = vec3(0., -1., 0.),
        d;
    
    for (int i = 0; i < 164; i++) {	
        d = map(prp + scp * tr.x);
        tr.x += d.x * .4;

        if ((abs(d.x) < .0001) || (tr.x > FAR)) break;
    }
    
    tr.yz = d.yz;
	return tr;
    
}
vec3 traceRef(vec3 ro, vec3 rd) {
    vec3 
        tr = vec3(0., -1., 0.),
        d;
    
    for (int i = 0; i < 50; i++) {
        d = map(ro + rd * tr.x);
        tr.x += d.x;
        
        if (abs(d.x) < 0.0055 || tr.x> FAR) break;
    }
    
    tr.yz = d.yz;
    return tr;
}

float softShadow(vec3 ro, vec3 lp, float k) {
    const int maxIterationsShad = 12;
    vec3 rd = (lp - ro); 

    float shade = .1;
    float dist = 2.2;
    float end = max(length(rd), 0.001);
    float stepDist = end / float(maxIterationsShad);

    rd /= end;
    for (int i = 0; i < maxIterationsShad; i++) {
        float h = map(ro + rd * dist).x;
        shade = min(shade, smoothstep(0.0, 1.0, k * h / dist)); 
        dist += min(h, stepDist * 2.); 
        if (h < 0.001 || dist > end) break;
    }
    return min(max(shade, 0.), 1.0);
}


#define EPSILON .1
vec3 getNormalHex(vec3 pos)
{
	float d=map(pos).x;
	return normalize(
        vec3(
            map(
                pos+vec3(EPSILON,0,0)).x-d,
                map(pos+vec3(0,EPSILON,0)).x-d,
                map(pos+vec3(0,0,EPSILON)).x-d 
        	)
    	);
}

float getAO(in vec3 hitp, in vec3 normal)
{
    float dist = 0.2;
    vec3 spos = hitp + normal * dist;
    float sdist = map(spos).x;
    return clamp(sdist / dist, 0.0, 1.0);
}

vec3 getObjectColor(vec3 p, vec3 n, inout vec2 mat) {
    vec3 col = vec3(.4, 0.6, 1.);    
	
    col = pal( p.x * 0.01, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20) );
   	col *= 1.+ pow(noise( os * 5.) * noise(p * 3.2), 1.);
    
    return col;
}

vec3 doColor( in vec3 sp, in vec3 rd, in vec3 sn, in vec3 lp, inout vec2 mat) {
	vec3 sceneCol = vec3(0.0);
    
    vec3 ld = lp - sp; 
    float lDist = max(length(ld), 0.001); 
    ld /= lDist;

    float atten = max(0.1, 2.0 / (1.0 + lDist * .525 + lDist * lDist * 1.05));
    float diff = max(dot(sn, ld), .1);
    float spec = pow(max(dot(reflect(-ld, sn), -rd), .5), 2.0);
   
    vec3 objCol = getObjectColor(sp, sn, mat);
    sceneCol += (objCol * (diff + 0.15) + vec3(.3, .4, .6) * spec * 1.) * atten;

    return sceneCol;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 uv = fragCoord.xy / iResolution.xy - .5;
	uv.x /= iResolution.y / iResolution.x;
    
    uv *= tan(radians (FOV) / 2.0);
    
    vol = texture(iChannel0, vec2(.0, .25)).r  * 1.; 
    
    float 
        sk = sin(mt * .2) * 2.0,
        ck = cos(mt * .3) * 2.0,
        
        mat = 0.;
    
    light = vec3(0., 0., 11.);        
    
    vec3 sceneColor = vec3(0.);
    float camx = mt;
    
    vec3 
        vuv = vec3(0., 1., 0.),
    	ro = vec3(camx, yC(camx), 0.),
    	vrp =  vec3(camx + 1., yC(camx + 1.5), 0.),
    	vpn = normalize(vrp - ro),
    	u = normalize(cross(vuv, vpn)),
    	v = cross(vpn, u),
    	vcv = (ro + vpn),
    	scrCoord = (vcv + uv.x * u * iResolution.x/iResolution.y + uv.y * v),
    	rd = normalize(scrCoord - ro);        
	
    light = ro;
    
    vec3 lp = vrp;
    
	vec3 orgRO = ro,
         orgRD = rd;
	
    vec3 tr = trace(ro, rd), otr;
    
    float fog = smoothstep(FAR * FOG, 0., tr.x * 1.);
    
    ro += rd * tr.x;
    otr = ro;
    
    vec3 sn = getNormal(ro);	
    float ao = getAO(ro, sn);
   	
    sceneColor += doColor(ro, rd, sn, lp, tr.yz);
    
    float dist = tr.x;
    
    rd = reflect(rd, sn);
    tr = traceRef(ro + rd * .03, rd);
    ro += rd * tr.x;
    sn = getNormal(ro);
    sceneColor += doColor(ro, rd, sn, lp, tr.yz) * .3;

    fragColor = vec4(clamp(sceneColor * 1.3, 0.0, 1.0), tr.x / FAR);
}

