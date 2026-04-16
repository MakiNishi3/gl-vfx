/*
Inspired by Sound Blob : https://www.shadertoy.com/view/Ms3SWr
*/
//rotation & color
#define TWOPI 6.28318530718
#define PI 	3.14159265
#define SPEED 0.05

//ray marching
#define MAX_STEPS 32.0
#define EPSILON 0.002
#define MIN_STEP_SIZE 0.001
#define MIN_DISTANCE 0.0

//modify to change number of spheres
#define NumSpheres 6
//modify to change spread of spheres
#define MAX_ORBIT_DIST 1.0

#define CAMZ -2.0


vec3 getColor(float amt) {
	float colDeg = amt * TWOPI;
    float x = 1.0 - abs(mod(colDeg/radians(60.0), 2.0) -1.0);
    if(colDeg < radians(60.00)){return vec3(1.0,	x, 		0.0);}
    if(colDeg < radians(120.0)){return vec3(x,		1.0, 	0.0);}
    if(colDeg < radians(180.0)){return vec3(0.0, 	1.0, 	x);}
    if(colDeg < radians(240.0)){return vec3(0.0, 	x, 		1.0);}
    if(colDeg < radians(300.0)){return vec3(x, 		0.0, 	1.0);}
    return vec3(1.0, 0.0, x);
}

mat2 rotate(float deg) {return mat2(cos(deg), sin(deg), -sin(deg), cos(deg));}

//rotate about y-axis
vec3 getRay(vec3 rayDir, float rot) {
	rayDir = normalize(rayDir);
    float cosVal = cos(rot);
    float sinVal = sin(rot);    
    return vec3((rayDir.x * cosVal) + (rayDir.z * sinVal), rayDir.y, (rayDir.z * cosVal) - (rayDir.x * sinVal));
}

float sdfSphere(vec3 center, vec3 pos, float rad) {
	float dist = length(center - pos) - rad;
    
    return dist;
}

float smin(float dist0, float dist1, float scaleFactor) {
	float mixVal = clamp(0.5 + 0.5 * (dist1 - dist0) / scaleFactor, 0.0, 1.0);
    return mix(dist1, dist0, mixVal) - scaleFactor * mixVal * (1.0 - mixVal);
}

vec2 map(in vec3 pos, out float rad) {

    
    float minDist = 10000000.0;
    float xStep = MAX_ORBIT_DIST / float(NumSpheres);
    float maxRadius = (xStep * 2.0 / 2.0);
    float zPos = 3.0;
    float yPos = 0.0;
    
    float distFromCenter = length(pos.xy);
    
    //if(distFromCenter > MAX_ORBIT_DIST + maxRadius) {distFromCenter = MAX_ORBIT_DIST;}
    
    float sphereNum = distFromCenter / xStep;
    
    //optimizations, no loops, only calculate nearest 2 spheres
    //distinct orbits should keep there from ever being 3 all in mutual contact
    
    //get the closest two spheres by radius from origin
    float sphere0 = floor(sphereNum);
    if(sphere0 > float(NumSpheres) ) {sphere0 = float(NumSpheres);}
    float sphere1 = ceil(sphereNum);
    if(sphere1 > float(NumSpheres) ) {sphere1 = float(NumSpheres);}
    
    //get relevant info about each sphere
    float rotDir0 = mod(sphere0, 2.0);
    float rotDeg0 = fract( (sphere0 + 1.0) * SPEED * iTime) * TWOPI;
    mat2  rotAmt0 = rotate(rotDeg0);
	float sampX0  = sphere0 / float(NumSpheres);
    float amp0    = texture(iChannel0, vec2(sampX0, 0.25)).x;
    float xDist0   = sphere0 * xStep + 0.01;
    if(rotDir0 == 1.0) {xDist0 = -xDist0;}
    vec3 spherePos0 = vec3(vec2(0. + xDist0, yPos) * rotAmt0, zPos);
    float rad0  = amp0 * pow(1.01,sphere0)* maxRadius + 0.01;
    float dist0 = sdfSphere(spherePos0, pos, rad0);
    
    float rotDir1 = mod(sphere1, 2.0);
    float rotDeg1 = fract( (sphere1 + 1.0) * SPEED * iTime) * TWOPI;
    mat2  rotAmt1 = rotate(rotDeg1);
	float sampX1  = sphere1 / float(NumSpheres);
    float amp1    = texture(iChannel0, vec2(sampX1, 0.25)).x;
    float xDist1  = sphere1 * xStep + 0.01;
    if(rotDir1 == 1.0) {xDist1 = -xDist1;}
    vec3 spherePos1 = vec3(vec2(0. + xDist1, yPos) * rotAmt1, zPos);
    float rad1 =  amp1 * pow(1.01,sphere1)* maxRadius + 0.01;
    float dist1 = sdfSphere(spherePos1, pos, rad1);
    
    rad = rad0 / maxRadius;
    
    minDist = smin(minDist, dist0, 0.04);
    
    if(dist1 < minDist) {rad = rad1 / maxRadius;}
    minDist = smin(minDist, dist1, 0.04);
    
    
    /*
    for(int i = 0; i < NumSpheres; i++) {
        float rotDir = mod(float(i), 2.0);
        float rotDeg =fract( (float(i) + 1.0) * SPEED * iTime) * TWOPI;
        //rotDeg = rotDeg + (TWOPI / float(NumSpheres));
        //if(rotDir == 1.0) {rotDeg = -rotDeg;}
        mat2 rotAmt = rotate(rotDeg);
        float xDist = float(i) * xStep + 0.01;
        if(rotDir == 1.0) {xDist = -xDist;}
        vec3 spherePos = vec3(vec2(0. + xDist, yPos) * rotAmt, zPos);
		float sampX = float(i) / float(NumSpheres);
        float amp = texture(iChannel0, vec2(sampX, 0.25)).x;
        float dist = sdfSphere(spherePos, pos, amp * pow(1.01,float(i))* maxRadius + 0.01);
        if(dist < minDist) { rad = (amp * pow(1.01,float(i))* maxRadius + 0.01) / maxRadius;}
        minDist = smin(minDist, dist, 0.04);
    }
    */
    return vec2(1.0, minDist);
}
 
vec3 getNormal(vec3 pos, float epsilon) {
    float rad = 0.0;
	vec3 e = vec3(epsilon, 0.0, 0.0);
    vec3 normal = vec3(map(pos + e.xyy, rad).y - map(pos - e.xyy,rad).y,
                       map(pos + e.yxy,rad).y - map(pos - e.yxy,rad).y,
                       map(pos + e.yyx,rad).y - map(pos - e.yyx,rad).y);
    return normalize(normal);
}
                       
vec3 marchIt(vec3 origin, vec3 dir) {

    float rad = 0.0;
    float traveled = 0.0;
    for(float i = 0.0; i < MAX_STEPS; i += 1.0) {
        vec3 pos = origin + (dir * traveled);
        vec2 result = map(pos, rad);
        
        if(traveled > MIN_DISTANCE && result.y < EPSILON) {
			return vec3(traveled, i / MAX_STEPS, rad);
        }
        
        traveled += max(MIN_STEP_SIZE, result.y);
    }
    
    return vec3(0.0,1.0,0.0);
}
    
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xx) -vec2( 0.5,0.5*iResolution.y/iResolution.x);

    vec3 camPos = vec3(0.0, 0.0, CAMZ);
    vec3 rayDir = normalize(vec3(uv, 1.0));
       
    vec3 result = marchIt(camPos, rayDir);
    
    vec3 col = vec3(0.0);
    
    if(result.x > 0.0) {
        
        vec3 surfPos = camPos + (rayDir * result.x);
        vec3 normal = getNormal(surfPos, 0.001);
        vec3 light = normalize(vec3(-1.0, 1.0, -0.5));
        vec3 reflection = reflect(rayDir, normal);
        float diffuse = dot(normal, light);
        float specular = pow(clamp(dot(reflection, light), 0.0, 1.0), 20.0);
        
        col += vec3(specular * diffuse) * vec3(1.) + vec3(diffuse*0.4+0.6)* getColor(result.z);//vec3(0.9,0.5-(result.y)*0.5,(1.0/result.x)*0.1);
    }
                               
    // Time varying pixel color
    //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}
