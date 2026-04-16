#define R iResolution.xy
#define MaxSteps 100.
#define MinDistance 0.01
#define eps 0.001
#define Iterations 22.

mat3 rotateX(float angle) {
	float c = cos(angle), s = sin(angle);
    return mat3(1, 0, 0, 0, c, -s, 0, s, c);
}

mat3 rotateY(float angle) {
	float c = cos(angle), s = sin(angle);
    return mat3(c, 0, -s, 0, 1, 0, s, 0, c);
}

mat3 rotateZ(float angle) {
	float c = cos(angle), s = sin(angle);
    return mat3(c,-s,0,s,c,0,0,0,1);
}

// from IQ
float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}

// from IQ
float sdBox(vec3 p, vec3 b) { 
	vec3 d = abs(p) - b;
    return length(max(d,0.0));
}

vec2 scene(vec3 p) {
    
    
    float plane = sdPlane(p - vec3(0,1,0) + 0.0005*texture(iChannel1, p.xz).xyz, vec4(0., 1., 0., 1.));  
    float square1 = sdBox(p, vec3(.1));
    float square = 1e10;
    
    float numSquares = 16.;
    for(float i=0.; i < numSquares; i++) {
        vec4 music = texture( iChannel0, vec2(i/numSquares,0.1));
		square = min(square, sdBox(p - vec3(.3 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x * .2,.05)));
        square = min(square, sdBox(p - vec3(.10 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x * .5,.05)));
        square = min(square, sdBox(p - vec3(-.1 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x,.05)));
    }
    
    int closestId = 0;
    if(square > plane) closestId = 1;
    
    return vec2(min(plane, square), closestId);
}

float shadowScene(vec3 p){

    float square1 = sdBox(p, vec3(.1));
    
    float square = 1e10;
    
    float numSquares = 16.;
    for(float i=0.; i < numSquares; i++) {
        vec4 music = texture( iChannel0, vec2(i/numSquares,0.1));
		square = min(square, sdBox(p - vec3(.3 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x * .2,.05)));
        square = min(square, sdBox(p - vec3(.10 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x * .5,.05)));
        square = min(square, sdBox(p - vec3(-.1 + .3,0, -1.2 + i/numSquares * 2.2), vec3(.05,.05 + music.x,.05)));
    }
    
    return square;
}

// from iq
vec3 calcNormal(vec3 p) {
    float h = 0.001;
    vec2 k = vec2(1,-1);
    vec3 n = normalize( k.xyy*scene( p + k.xyy*h ).x + 
                  k.yyx*scene( p + k.yyx*h ).x + 
                  k.yxy*scene( p + k.yxy*h ).x + 
                  k.xxx*scene( p + k.xxx*h ).x );    
    return n;
}

// ro: ray origin, rd: ray direction
// returns t and the occlusion as a vec2
vec3 march(vec3 ro, vec3 rd) {
    float t = 0., i = 0.;
    for(i=0.; i < MaxSteps; i++) {
    	vec3 p = ro + t * rd;
        vec2 hit = scene(p);
        float dt = hit.x;
        t += dt;
        if(dt < MinDistance) {
        	return vec3(t-MinDistance, 1.-i/MaxSteps, hit.y);  
        }
    }
    return vec3(0.);
}

vec2 marchShadow(vec3 ro, vec3 rd) {
	float t = 0., i = 0., dt = 0., minDist = 1e10;
    for(i=0.; i < MaxSteps; i++) {
    	vec3 p = ro + t * rd;
        dt = shadowScene(p);
        minDist = min(minDist, dt);
        t += dt;
        if(dt < MinDistance) {
        	return vec2(t-MinDistance, dt);    
        }
    }
    return vec2(0., minDist);
}

// https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_shading_model
vec3 shadeBlinnPhong(vec3 p, vec3 viewDir, vec3 normal, vec3 lightPos, float lightPower, vec3 lightColor) {
    vec3 diffuseColor = vec3(0.5);
    vec3 specColor = vec3(1);
    float shininess = 32.;

    vec3 lightDir = lightPos - p;
    float dist = length(lightDir);
    dist = dist*dist;
    lightDir = normalize(lightDir);
    
    float lambertian = max(dot(lightDir, normal), 0.0);
    float specular = .0;
    
    if(lambertian > 0.) {
        viewDir = normalize(-viewDir);
        
        vec3 halfDir = normalize(viewDir + lightDir);
        float specAngle = max(dot(halfDir, normal), .0);
        specular = pow(specAngle, shininess);
    }
    
    vec3 color = /*ambientColor +*/
                 diffuseColor * lambertian * lightColor * lightPower / dist +
        		 specColor * specular * lightColor * lightPower / dist;
    
   	return color;
}

// p: point, sn: surface normal, rd: ray direction (view dir/ray from cam)
vec3 light(vec3 p, vec3 sn, vec3 rd) {

    vec3 L1 = shadeBlinnPhong(p, rd, sn, vec3(0,5,0), 5., vec3(1));

    vec3 ambient = vec3(.1);
    return L1 + ambient;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (2.*fragCoord-R)/R.y;
    vec3 col = vec3(.0);
    
    vec2 random = texture(iChannel0, fragCoord/R.y).xy;
    vec3 ro = vec3(0., 2.,-4. + random.y *.2); // ray origin
	
    
    vec3 rd = normalize(vec3(uv.x, uv.y, 0) - ro); // ray direction
    
    mat3 rot = rotateY(cos(iTime)*.2 + 1.);
    
    float w = texture(iChannel0, vec2(.01,0.1)).x;
    ro -= vec3(0,0,w*.6 - w*.6/2.);
    
    ro *= rot;
    rd *= rot;
    
    vec3 hit = march(ro, rd); // returns t and the occlusion value 
    float t = hit.x;
    float occl = hit.y;
    
    if(t > eps) {
        vec3 p = ro + t * rd;
    	vec3 n = calcNormal(p);
        
        // bars
        if(hit.z == 0.) {
            col = vec3(.3, 1., .3);
        }
        
        // floor
        if(hit.z == 1.) {
         	col = vec3(.2); 
            
            col += light(p, n, rd);
            
            // reflection
            
            vec3 randxz = vec3(random.x, 0, random.y);
            vec2 shadowHit = marchShadow(p, normalize(reflect(rd, n)));
            float refl = shadowHit.x;
            if(refl < eps) refl = 1e10;
            col += clamp(vec3(.4,1.,.4) * (.1 / refl), 0., 1.);              
        }
        
        // glow
        vec2 sh = marchShadow(ro, rd);
        float glow = sh.y;
        col += 1.2*vec3(.4,1,.4) * (1.-3.*glow);
                
        // green lightning
        float lightDistance = shadowScene(p);
        col += clamp(vec3(0,1,0) * 0.1 / lightDistance, 0., 1.) * .8;

		// post
        col -= occl;
        float fog = 1. / (1. + t * 0.25);
        col = mix(vec3(0), col, fog);
        
        if(hit.z == 0.) {
        	col *= occl;    
        }
        
        
    }

    fragColor = vec4(col,1.0);
}