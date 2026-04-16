/*

	Tunnel7 a.k.a "inFX.3 Tube scanner"
    for cooperation of polish demoscene musicians, called:
    
    
    "Power Packed Alliance".
    -----------------------------------

	https://www.youtube.com/watch?v=_lSReW7eRI4
    http://www.pouet.net/prod.php?which=70247

	
    
    also check my chrome extension for Shadertoy:
    https://chrome.google.com/webstore/detail/shadertoy-unofficial-plug/ohicbclhdmkhoabobgppffepcopomhgl?hl=pl

*/


#define getNormal getNormalHex

#define FAR 70.
#define INFINITY 1e32
#define t iTime
#define mt iChannelTime[1]
#define FOV 130.0
#define FOG .091326

#define PI 3.14159265
#define TAU (2*PI)
#define PHI (1.618033988749895)

float vol = 0.;

float hash(vec2 x){
	return fract(572.612*sin(1413.7613*sin(t*41.12)+1175.2126*fract(dot(x, 1114.41256*vec2(56.0,1.37)))));
}
vec3 fromRGB(int r, int g, int b) {
 	return vec3(float(r), float(g), float(b)) / 255.;   
}
    
vec3 
    light = vec3(0.0, 2.0, 70.);

vec3 lightColour = normalize(vec3(1.8, 1.0, 0.3)); 

vec3 saturate(vec3 a) { return clamp(a, 0.0, 1.0); }

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}


// mercury
vec2 pModMirror2(inout vec2 p, vec2 size) {
	vec2 halfsize = size*0.5;
	vec2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	p *= mod(c,vec2(2.))*2. - vec2(1.);
	return c;
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float opU2( float d1, float d2 ) {
    if (d1 < d2) return d1;
    return d2;
}

vec3 opU2( vec3 d1, vec3 d2 ) {
    if (d1.x < d2.x) return d1;
    return d2;
}

struct geometry {
    float dist;
    vec3 space;
    vec3 hit;
    vec3 sn;
    vec3 color;
    vec2 material;
    int iterations;
    float glow;
};

float smin( float a, float b, float k ){
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
    }    
    
geometry geoU(geometry g1, geometry g2) {
    if (g1.dist < g2.dist) return g1;
    return g2;
}

geometry geoI(geometry g1, geometry g2) {
    if (g1.dist > g2.dist) return g1;
    return g2;
}

vec3 opS2( vec3 d1, vec3 d2 )
{	
    if (-d2.x > d1.x) return -d2;
    return d1;
}

vec3 opI2( vec3 d1, vec3 d2 ) {
 	if (d1.x > d2.x) return d1;
    return d2;
}


float vmax(vec2 v) {
	return max(v.x, v.y);
}

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

// Sign function that doesn't return 0
float sgn(float x) {
	return (x<0.)?-1.:1.;
}

vec2 sgn(vec2 v) {
	return vec2((v.x<0.)?-1.:1., (v.y<0.)?-1.:1.);
}

// mercury
// Repeat space along one axis. Use like this to repeat along the x axis:
// <float cell = pMod1(p.x,5);> - using the return value is optional.
float pMod1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}

// mercury
// Repeat in two dimensions
vec2 pMod2(inout vec2 p, vec2 size) {
	vec2 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5,size) - size*0.5;
	return c;
}


// Mirror at an axis-aligned plane which is at a specified distance <dist> from the origin.
float pMirror (inout float p, float dist) {
	float s = sgn(p);
	p = abs(p)-dist;
	return s;
}

// mercury
vec2 pMirrorOctant (inout vec2 p, vec2 dist) {
	vec2 s = sgn(p);
	pMirror(p.x, dist.x);
	pMirror(p.y, dist.y);
	if (p.y > p.x)
		p.xy = p.yx;
	return s;
}

// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

// Same as above, but in two dimensions (an endless box)
float fBox2Cheap(vec2 p, vec2 b) {
	return vmax(abs(p)-b);
}

float fCross(vec3 p, vec3 size) {
    float obj = fBox(p, size);
    obj = opU2(obj, fBox(p, size.zxy));
    obj = opU2(obj, fBox(p, size.yzx));
               
    return obj;
}

float sdCross( in vec3 p, vec3 b ) {
    float inf = 40.;
    float da = fBox(p.xyz, b.xyz);//vec3(inf, w, w));
    float db = fBox(p.yzx, b.yxz);//vec3(w, inf, w));
    float dc = fBox(p.zxy, b.yzx);//vec3(w, w ,inf));
    return min(da,min(db,dc));
} 

geometry DE(vec3 p, float c)
{
 	const float scale = 4.1;
	const float offset = 11.0;
    const int FRACTALITERATIONS = 5;
    vec3 modifier = vec3(6.3, 9.4, 1.5) * c;// vec3(sin(t), sin(t / 2.), 0.);
	for(int n=0; n< FRACTALITERATIONS; n++)
	{
        
        p = abs(p);
        
		p.xz = (p.x - p.z < 0.0) ? p.zx : p.xz;
		p.zy = (p.y - p.z < 0.0) ? p.yz : p.zy;


		p.zy += 11.9;

        pR(p.xz, .31364);
		pR(p.yx, .04112915);
        
        
        p.xyz = scale* p.xyz - offset * (scale-1.0) * modifier.xyz;
        
	}
 	geometry obj;
    obj.dist = length(p.xz) * 1.3 * (pow(scale, -float(FRACTALITERATIONS))) - 0.2; 
	obj.space = p;
    return obj;
}


geometry map(vec3 p) {
    vec3 bp = p;
    
    p.x -= 8.5;
    
	pModMirror2(p.yz, vec2(34.));
    
    vec2 c =  pMirrorOctant(p.zy, vec2(58., 38. ));
    
    pMirrorOctant(p.xz, vec2(12., 40.));
    
    geometry obj;
  	
    obj = DE(p, 1. );
    obj.material = vec2(1., 0.);
    obj.space = p;
    obj.color = fromRGB(204,141,96); 
    
    geometry obj2;
    
    p.yx += 15.;
    
    obj2 = DE(p, 1.5 * sin(p.x / 10.) * 10.);
    obj2.color = vec3(5.);

    p = bp;
    p += + vec3(-70., 20., 10. + t * 25.);
    
    geometry obj3;
    
    p += vol;
    
    pR(p.xz, t);
    pR(p.yz, p.x / 10. -t);

    vec3 bo = vec3(.1, 1. + vol * 10., .1);
    
	bo.xz += length(p) / 15.;
    obj3.dist = sdCross(p, bo);
    
    pR(p.xy, PI / 4.);
    pR(p.zy, PI / 4.);
    
    obj3.dist = min(obj3.dist, sdCross(p, bo));
    
    pR(p.xy, PI / 2.);
    pR(p.zy, PI / 2. );

    obj3.dist = min(obj3.dist, sdCross(p, bo.zxy));
    obj3.color = fromRGB(204,141,96) + 1. - length(p.xy) / 10.; 
    
    obj3.material = vec2(1. , 0.);
    obj3.dist = smin(obj3.dist, obj.dist, .4);
    
    obj = geoU(obj, obj3);
    
    
    return obj;
}


float t_min = 0.01;
float t_max = FAR;
const int MAX_ITERATIONS = 80;

geometry trace(vec3 o, vec3 d) {
    float omega = 1.3;//vol;
    float t = t_min;
    float candidate_error = INFINITY;
    float candidate_t = t_min;
    float previousRadius = 0.;
    float stepLength = 0.;
    float pixelRadius = 1./ 228.;
    
    geometry mp = map(o);
    mp.glow = 0.;
    
    float functionSign = mp.dist < 0. ? -1. : +1.;
    float minDist = INFINITY;
    
    for (int i = 0; i < MAX_ITERATIONS; ++i) {

        mp = map(d * t + o);
		mp.iterations = i;
        
        minDist = min(minDist, mp.dist * 3.);
        if (i < 116) mp.glow = pow(1. / minDist, 1.8);
        
        //glow = pow( 1. / minDist, 0.8);
        float signedRadius = functionSign * mp.dist;
        float radius = abs(signedRadius);
        bool sorFail = omega > 1. &&
        (radius + previousRadius) < stepLength;
        if (sorFail) {
            stepLength -= omega * stepLength;
            omega = 1.;
        } else {
        stepLength = signedRadius * omega;
        }
        previousRadius = radius;
        float error = radius / t;
        if (!sorFail && error < candidate_error) {
            candidate_t = t;
            candidate_error = error;
        }
        if (!sorFail && error < pixelRadius || t > t_max) break;
        t += stepLength;
   	}
    
    mp.dist = candidate_t;
    
    
    if (
        (t > t_max || candidate_error > pixelRadius)
    	) mp.dist = INFINITY;
    
    
    return mp;
}


float softShadow(vec3 ro, vec3 lp, float k) {
    const int maxIterationsShad = 8;
    vec3 rd = (lp - ro); // Unnormalized direction ray.

    float shade = 4.;
    float dist = 4.5;
    float end = max(length(rd), 0.01);
    float stepDist = end / float(maxIterationsShad);

    rd /= end;
    for (int i = 0; i < maxIterationsShad; i++) {
        float h = map(ro + rd * dist).dist;
        shade = min(shade, k*h/dist);
        //shade = min(shade, smoothstep(0.0, 1.0, k * h / dist)); 
        dist += min(h, stepDist * 2.); 
        if (h < 0.001 || dist > end) break;
    }
    return min(max(shade, 0.0), 1.0);
}

#define EPSILON .001
vec3 getNormalHex(vec3 pos)
{
	float d=map(pos).dist;
	return normalize(
        vec3(
            map(
                pos+vec3(EPSILON,0,0)).dist-d,
                map(pos+vec3(0,EPSILON,0)).dist-d,
                map(pos+vec3(0,0,EPSILON)).dist-d 
        	)
    	);
}

float getAO(vec3 hitp, vec3 normal, float dist)
{
    vec3 spos = hitp + normal * dist;
    float sdist = map(spos).dist;
    return clamp(sdist / dist, 0.0, 1.0);
}

vec3 Sky(in vec3 rd, bool showSun, vec3 lightDir)
{
   float sunSize = 3.5;
   float sunAmount = max(dot(rd, lightDir), 0.4);
   float v = pow(1.2 - max(rd.y, 0.0), 1.1);
   vec3 sky = mix(fromRGB(0,136,254), vec3(.1, .2, .3) * 1., v);
   if (showSun == false) sunSize = .1;
   sky += lightColour * sunAmount * sunAmount * 1. + lightColour * min(pow(sunAmount, 122.0)* sunSize, 0.2 * sunSize);
   return clamp(sky, 0.0, 1.0);
}

vec3 doColor( in vec3 sp, in vec3 rd, in vec3 sn, in vec3 lp, geometry obj) {
	vec3 sceneCol = vec3(0.0);
    lp = sp + lp;
    vec3 ld = lp - sp; 
    float lDist = max(length(ld / 2.), 0.001); 
    
    ld /= lDist;
    float diff = max(dot(sn, ld), 1.);
    float spec = pow(max(dot(reflect(-ld, sn), -rd), 1.), 1.);
    vec3 objCol = obj.color;
    sceneCol += (objCol * (diff + .15) * spec * .2);// * atten;
    
    return sceneCol;
}

// iq
vec3 applyFog( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayOri,   // camera position
               in vec3  rayDir ) {  // camera to point vector
    
    float c = .1;
    float b = .04;
    float fogAmount = c * exp(-rayOri.y*b) * (1.0-exp( -distance*rayDir.y*b ))/rayDir.y;
    vec3  fogColor  = vec3(0.5,0.6,0.7);
    
    return mix( rgb, fogColor, fogAmount );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 ouv = fragCoord.xy / iResolution.xy;
    vec2 uv = ouv - .5;
    vec2 puv = uv;
    
    vol = (texture(iChannel0, vec2(.3, .25)).r) * .6;
    
    uv *= tan(radians (FOV) / 2.0) * 1.1;

    float t2 = t - 35.;
    float 
        sk = sin(-t2 * 1.4) * 166.0, 
        ck = cos(-t2 * .4) * 162.0;
    
    light = vec3(0., 10., -30.);        
        
    vec3 
        vuv = vec3(0., 1., sin(t)), // up
    	
    ro = vec3(45., -20., -t * 25.);
    
    ro.x += 20.;
    
    vec3
        vrp =  vec3(135. - sk / 2., 50. + sk / 3. , -160.) + ro; // lookat    */
    
    vec3 
    	vpn = normalize(vrp - ro),
    	u = normalize(cross(vuv, vpn)),
    	v = cross(vpn, u),
    	vcv = (ro + vpn),
    	scrCoord = (vcv + uv.x * u * iResolution.x/iResolution.y + uv.y * v),
    	rd = normalize(scrCoord - ro);
    
    vec3 sceneColor = vec3(0.);
    
    vec3 lp = light + ro;
	
    geometry tr = trace(ro, rd);    
    
    tr.hit = ro + rd * tr.dist;
    tr.sn = getNormal(tr.hit);	
    
    float sh = softShadow(tr.hit, ro + light, 9.);
    
    vec3 sky = vec3(0.); 
    
    if (tr.dist < FAR) {
        vec3 col = (doColor(tr.hit, rd, tr.sn, light, tr) * 1.) * 1.;
        
        sceneColor = col;
        sceneColor *= 1.5 + length(
            max(0., length(normalize(light.yz) - max(vec2(0.), tr.sn.yz)))             
        );
        sceneColor *= .2 + length(saturate(tr.sn) - normalize(light));
        sceneColor = max(sceneColor, col);
        sceneColor += pow(float(tr.iterations) / 40. , 2.);

    } else {
        fragColor = vec4(1.);
        return;
    }
    
    sceneColor = applyFog(sceneColor - sh, tr.dist * 2.5, ro, rd);
    sceneColor = mix(sceneColor, lightColour, 0.1); 
    //sceneColor = mix(sceneColor, vec3(1.), clamp(tr.dist / FAR / 4., 0., 1.));
    
    
    fragColor = vec4(clamp(sceneColor * (1. - length(uv) / 2.5), 0.0, 1.0), 1.0);
	fragColor += pow(vol * 0.3,  1.2) + vol / 5.;
    fragColor = pow(fragColor, vec4(1.4));
    
    
    //fragColor = texture(iChannel0, ouv);
}
