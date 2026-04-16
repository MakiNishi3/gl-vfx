/*

	Tunnel3 a.k.a "Unicorn colonoscopy"
    for cooperation of polish demoscene musicians, called:
    
    
    "Power Packed Alliance".
    -----------------------------------

	https://www.youtube.com/watch?v=_lSReW7eRI4
    http://www.pouet.net/prod.php?which=70247

	
    
    also check my chrome extension for Shadertoy:
    https://chrome.google.com/webstore/detail/shadertoy-unofficial-plug/ohicbclhdmkhoabobgppffepcopomhgl?hl=pl

*/

#define getNormal getNormalHex

#define FAR 30.
#define INFINITY 1e32
#define t iTime
#define mt iChannelTime[1]
#define FOV 60.0
#define FOG .4

#define PI 3.14159265
#define TAU (2*PI)
#define PHI (1.618033988749895)

float vol = 0.;
    
vec3 light = vec3(0.0);
vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

vec4 getFreq(float f){
// first texture row is frequency data
	float fft  = texture( iChannel0, vec2(f, 0.25) ).x; 
	
    // second texture row is the sound wave
	float wave = texture( iChannel0, vec2(f, 0.75) ).x;
	
	// convert frequency to colors
	vec3 col = vec3( fft, 4.0 * fft * (1.0 - fft), 1.0 - fft ) * fft;
    return vec4(col, 1.0);
}

// Repeat only a few times: from indices <start> to <stop> (similar to above, but more flexible)
float pModInterval1(inout float p, float size, float start, float stop) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p+halfsize, size) - halfsize;
	if (c > stop) { //yes, this might not be the best thing numerically.
		p += size*(c - stop);
		c = stop;
	}
	if (c <start) {
		p += size*(c - start);
		c = start;
	}
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

vec3 opS2( vec3 d1, vec3 d2 )
{	
    if (-d2.x > d1.x) return -d2;
    return d1;
}


float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}


float fSphere(vec3 p, float r) {
	return length(p) - r;
}

// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

vec4 boxmap(sampler2D t, in vec3 p, vec3 n, in float k ) {
    vec3 m = pow( abs(p), vec3(k) );
	vec4 x = texture(t, p.yz);
	vec4 y = texture(t, p.zx);
	vec4 z = texture(t, p.xy);
	return (x * m.x + y * m.y + z * m.z) / (m.x + m.y + m.z);
}

vec3 map(vec3 p) {
    
    p.y += sin(p.z) / 2.;  
    p.x += cos(p.z) / 1.5;  
   	
    vec3 
        obj = vec3(FAR, -1.0, 0.0),
        obj2 = obj;
    
    vec3 orgP = p;
    
    
    obj = vec3(
        fBox(p, vec3(1.25, 1.25, INFINITY)),
        7.,
        0.
    );
    
    float mp = pModPolar(p.yx, 8.);

    p -= texture(iChannel1, p.xz * 1.4).rrr * .1;
    obj2 = vec3(
        fBox(p, vec3(1.8, .9, INFINITY)),
        8.,
        0.
    );
    
    obj = opS2(obj, obj2);

    p = orgP;

    mp = pModPolar(p.yx, 14.);

    float rz = pModInterval1(p.z, 1.0, -INFINITY, INFINITY);
    
    p.y += -.9;

    obj2 = vec3(
        fSphere(p, 0.1 + sin(mp * 8. + rz + t * 4.) / 12.),
        ceil(mod(sin(rz) * 10., 3.)) + 1.,
        0.
    );    
    
    obj = opU2(obj, obj2);
    
    
    return obj;
}


float t_min = 0.001;
float t_max = 20.;
const int MAX_ITERATIONS = 98;

vec3 trace(vec3 o, vec3 d) {
    float omega = 1.3;
    float t = t_min;
    float candidate_error = INFINITY;
    float candidate_t = t_min;
    float previousRadius = 0.;
    float stepLength = 0.;
    float pixelRadius = 0.0075;//tan(radians (FOV) / 2.0) / iResolution.x;
    float functionSign = map(o).x < 0. ? -1. : +1.;
    vec3 mp;
    
    for (int i = 0; i < MAX_ITERATIONS; ++i) {
        mp = map(d * t + o);
        float signedRadius = functionSign * mp.x;
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
        t += stepLength * .75;
   	}
    if (
        (t > t_max || candidate_error > pixelRadius)
    	) return vec3(INFINITY, 0., 0.);
    
    return vec3(candidate_t, mp.yz);
}

vec3 traceRef(vec3 ro, vec3 rd) {
    
    vec3 t = vec3(0., -1., 0.);
    for (int i = 0; i < 48; i++) {
        vec3 d = map(ro + rd * t.x);
        t.x += d.x;
        t.yz = d.yz;
        
        if (abs(d.x) < 0.015 || t.x> FAR) break;
        
    }
    return t;
}

float softShadow(vec3 ro, vec3 lp, float k) {
    const int maxIterationsShad = 38;
    vec3 rd = (lp - ro); // Unnormalized direction ray.

    float shade = 10.0;
    float dist = .05;
    float end = max(length(rd), 0.001);
    float stepDist = end / float(maxIterationsShad);

    rd /= end;
    for (int i = 0; i < maxIterationsShad; i++) {
        float h = map(ro + rd * dist).x;
        shade = min(shade, k*h/dist);
        //shade = min(shade, smoothstep(0.0, 1.0, k * h / dist)); 
        dist += min(h, stepDist * 2.); 
        if (h < 0.001 || dist > end) break;
    }
    return min(max(shade, 0.4), 2.0);
}




#define EPSILON .001
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

#define delta vec3(.001, 0., 0.)
vec3 getNormalCube(vec3 pos)   
{    
   vec3 n;  
   n.x = map( pos + delta.xyy ).x - map( pos - delta.xyy ).x;
   n.y = map( pos + delta.yxy ).x - map( pos - delta.yxy ).x;
   n.z = map( pos + delta.yyx ).x - map( pos - delta.yyx ).x;
   
   return normalize(n);
}


float getAO(in vec3 hitp, in vec3 normal)
{
    float dist = .3;
    vec3 spos = hitp + normal * dist;
    float sdist = map(spos).x;
    return clamp(sdist / dist, 0.3, 1.0);
}

vec3 getObjectColor(vec3 p, vec3 n, vec2 mat) {
    vec3 col = vec3(1.0, 0.6, .0) * .75 - .5;
    
    col += 
        boxmap(iChannel0, p, n, 1.).rrr;;
            
    if (mat.x == 1.0) col = vec3(2.);
    if (mat.x == 2.0) col = vec3(0., 11., 8.);
    if (mat.x == 3.0) col = vec3(13., 8., 0.);
    if (mat.x == 4.0) col = vec3(15., 0., 15.);

    return col * 1. ;

}

vec3 doColor( in vec3 sp, in vec3 rd, in vec3 sn, in vec3 lp, vec2 mat) {
	vec3 ld = lp-sp;
    float lDist = max(length(ld), 0.001);

    float atten = 1.0 / (1.0 + lDist*0.25 + lDist*lDist*0.05);
    
    float diff = max(dot(sn, ld), 0.);

    float spec = .1;
    

    vec3 objCol = getObjectColor(sp, sn, mat);
    

    vec3 sceneCol = (objCol*(diff + 0.15) + vec3(1.)*spec*2.) * atten;

    return sceneCol;

}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 uv = fragCoord.xy / iResolution.xy - .5;

    uv *= tan(radians (FOV) / 2.0);
    
    vol = getFreq(0.1).r;//texture(iChannel0, vec2(.75, .25)).r  * 4.; 
    
    float 
        sk = sin(t * 2.3) * 2.0,
        ck = cos(t * .3) * 1.0,
        
        mat = 0.;   
    
    light = vec3(0., 0., -4. + ck * vol);        
    
    vec3 sceneColor = vec3(0.);
    float vol = getFreq(0.2).r / 4.;
    vec3 
        vuv = vec3(sin(t), cos(2. *vol), sin(t)),
    	
        ro = vec3(
            sin(t * 4.) / 8.,
            cos(-t * 4.) / 6. + vol,
            -t * 4.),
    	
        vrp =  vec3(
            ck * vol - sin(t * 2.) / 2.,
            vol - cos(-t *4.) / 2.,
            -4. + sk * vol
        ) + ro,
        	
    	vpn = normalize(vrp - ro),
    	u = normalize(cross(vuv, vpn)),
    	v = cross(vpn, u),
    	vcv = (ro + vpn),
    	scrCoord = (vcv + uv.x * u * iResolution.x/iResolution.y + uv.y * v),
    	rd = normalize(scrCoord - ro);        

    vec3 lp = light + ro;
    vec3 tr = trace(ro, rd);       
    
    ro += rd * tr.x;
    float fog = smoothstep(FAR * FOG, 0., tr.x * 2. - texture(iChannel0, ro.xz * .3).r);
    vec3 sn = getNormal(ro);	
    
    float sh = softShadow(ro, lp, 6.);
    float ao = getAO(ro, sn);
    
    sceneColor += doColor(ro, rd, sn, lp, tr.yz) * 4.;

    sceneColor *= fog;
    sceneColor *= ao;
    sceneColor *= sh;
    fragColor = vec4(clamp(sceneColor, 0.0, 1.0), 1.0);
}

