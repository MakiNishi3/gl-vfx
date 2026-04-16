# define CLIP_FAR 1000.0
# define STOP_THRESHOLD 0.008
# define MAX_ITERATIONS 64
# define PI 3.14159265359
# define DEG_TO_RAD 3.14159265359 / 180.0
    
float dist_sphere (vec3 pos, float r) {
    return length(pos) - r;
}

float dist_field (vec3 pos) {
    float bigPlanetR = 1.35;
    float bigPlanet = dist_sphere(pos, bigPlanetR);
    float res = bigPlanet;
    
    const float l = 2.0;
    for (float i = 8.0; i >= 0.0; i -= 0.15) {
        vec3 imperfectionPos = vec3(pos);
        float imperfectionR = max(0.0001 * i, 0.00001);
        imperfectionPos.x = imperfectionR * (bigPlanetR + imperfectionR * 1.0);
        imperfectionPos.y = (i - l) * (imperfectionR) * (bigPlanetR + imperfectionR * 1.0);
        imperfectionPos.z -= imperfectionPos.y;
        float imperfection = dist_sphere(imperfectionPos, imperfectionR);
        res = min(res, imperfection);
    }
    
    
    for (float i = l; i >= 0.0; i--) {
        vec3 smallPlanetPos = vec3(pos);
        float smallPlanetR = min((l - i) / 70.0 + 0.04, 0.1);
        smallPlanetPos.x += cos(-iTime * 0.7 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.y += sin(-iTime * 0.3 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.z -= 1.3 + smallPlanetPos.y;
        float smallPlanet = dist_sphere(smallPlanetPos, smallPlanetR);
        res = min(res, smallPlanet);
    }
    
    for (float i = l; i >= 0.0; i--) {
        vec3 smallPlanetPos = vec3(pos);
        float smallPlanetR = min((l - i) / 70.0 + 0.04, 0.1);
        smallPlanetPos.x += sin(-iTime * 0.9 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.y += cos(-iTime * 0.8 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.z -= 1.3 - smallPlanetPos.y;
        float smallPlanet = dist_sphere(smallPlanetPos, smallPlanetR);
        res = min(res, smallPlanet);
    }
    
    for (float i = l; i >= 0.0; i--) {
        vec3 smallPlanetPos = vec3(pos);
        float smallPlanetR = min((l - i) / 70.0 + 0.04, 0.1);
        smallPlanetPos.x += sin(-iTime * 0.3 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.y += cos(-iTime * 0.1 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.z -= 1.3 - smallPlanetPos.y;
        float smallPlanet = dist_sphere(smallPlanetPos, smallPlanetR);
        res = min(res, smallPlanet);
    }
    
    for (float i = l; i >= 0.0; i--) {
        vec3 smallPlanetPos = vec3(pos);
        float smallPlanetR = min((l - i) / 70.0 + 0.04, 0.19);
        smallPlanetPos.x += sin(-iTime * 0.1 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.y += cos(-iTime * 0.15 + (i - l) * (smallPlanetR * 0.8)) * (bigPlanetR + smallPlanetR * 1.0);
        smallPlanetPos.z -= 1.3 - smallPlanetPos.y;
        float smallPlanet = dist_sphere(smallPlanetPos, smallPlanetR);
        res = min(res, smallPlanet);
    }
    
    
    return res;
}

float ray_march(vec3 ro, vec3 rd) {
    float depth = 0.0;
    
    for (int i = 0; i < MAX_ITERATIONS; i++) {
        float dist = dist_field(ro + rd * depth);
        
        if (dist < STOP_THRESHOLD) {
            return depth;
        }
        
        depth += dist;
        
        if (depth >= CLIP_FAR) {
            return CLIP_FAR;
        }
    }
    
    return CLIP_FAR;
}

// get ray direction
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, -z ) );
}


vec3 shading(vec3 pos, vec3 n, vec3 ro, vec2 uv) {
    vec3 lightPos = vec3(20.0, 20.0, 20.0);
    vec3 lightColor = vec3(uv,0.5+0.5*sin(iTime));
    
    vec3 Normal     = vec3(uv.x, uv.y, sqrt(n.z));

    float t = iTime;
	float U = 1.0-atan(Normal.z, Normal.x) / (2.0* PI);
	float V = 1.0-(atan(length(Normal.xz), Normal.y)) / PI;
 	vec3 Ground = pow(texture(iChannel0, vec2(U - t/4.0, V)).xyz, vec3(2.22));
    
    lightColor = mix(lightColor, vec3(1.0), Ground);
    
    vec3 vl = normalize(lightPos - ro);
    
    float ambient = 0.8;
    float diffuse = max(0.0, dot(vl, n));
    
    // specular
    vec3 ev = normalize(pos - ro);
    vec3 ref_ev = reflect(ev, n);
    float specular = max(0.0, dot(vl, ref_ev));
    
    return lightColor * (ambient + diffuse + specular);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	
    vec3 ro = vec3(0.0, 0.0, 10.0);
    vec3 rd = ray_dir(20.0 + sin(iTime * 2.0), iResolution.xy, fragCoord.xy );
    
    float depth = ray_march(ro, rd);
    
    if (depth >= CLIP_FAR) {
    	fragColor = vec4(vec3(0.0), 1.0);
        fragColor = vec4(vec3(uv,0.5+0.5*sin(iTime)), 1.0);
        return;
    }
    
    
    vec3 pos = ro + rd * depth;
    
    fragColor = vec4(shading(pos * 1.1, pos * 1.0, ro * 1.0, uv * 0.59), 1.0);
}

