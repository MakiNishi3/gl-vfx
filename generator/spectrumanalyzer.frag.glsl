float specbins[16];

float distfunc(vec3 pos) {
	float dist = min(min(pos.y, -abs(pos.z) + 2.0), -abs(pos.x) + 2.0);
    for(int specbin = 0; specbin < 512; specbin+=32) {
        float specx = float(specbin) / 512.0;
        float specgram = specbins[specbin/32];
        float boxdist = length(max(abs(pos - vec3(-1.0 + specx * 2.0, 0.0, 0.0)) - vec3(0.065, pow(specgram, 2.5) * 2.0, 0.015), 0.0)) - 0.01;
        dist = min(dist, boxdist);
    }
    return(dist);
}


vec3 color(float inVal) {
	vec3 a = vec3(0.5, 0.5, 0.5);
	vec3 b = vec3(0.5, 0.5, 0.5);
	vec3 c = vec3(1.0, 1.0, 0.5);
	vec3 d = vec3(0.8, 0.9, 0.3);
	return(a + b * cos(6.28318 * (c * inVal + d)));
}

// For ray fuzzing, from some other shader
vec3 hash33(vec3 p){ 
    float n = sin(dot(p, vec3(7, 157, 113)));    
    return fract(vec3(2097152, 262144, 32768)*n); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coords = (2.0 * fragCoord.xy  - iResolution.xy) / max(iResolution.x, iResolution.y);
    
    // grab highest from each bin
    for(int specbin = 0; specbin < 512; specbin+=32) {
        float specgram = 0.0;
    	for(int specbinoff = 0; specbinoff < 32; specbinoff++) {
            float samples = texture(iChannel0, vec2(float(specbin+specbinoff) / 512.0, 0.0)).r;
        	specgram = samples > specgram ? samples : specgram;
        }
        specbins[specbin/32] = specgram;
    }
    
    // cut off some of the shared baseline amplitude, and multiply everything a little instead
    float lowest = 99999.0;
    for(int specbin = 0; specbin < 16; specbin++) {
        lowest = specbins[specbin] < lowest ? specbins[specbin] : lowest;
    }
    lowest /= 3.0;
    for(int specbin = 0; specbin < 16; specbin++) {
        specbins[specbin] -= lowest;
        specbins[specbin] *= 1.125;
    }
    
    float breaktime = iTime;
    breaktime += texture(iChannel0, vec2(0.8, 0.0)).r * 0.3;
    vec3 eye = vec3(sin(breaktime) * -1.75, cos(iTime * 0.2) + 1.7, cos(breaktime) * -1.75);
    vec3 lookat = vec3(0.0, 0.5, 0.0);
    vec3 lookdir = normalize(lookat - eye);
    vec3 left = normalize(cross(lookdir, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(left, lookdir));
    vec3 lookcenter = eye + lookdir;
	vec3 pixelpos = lookcenter + coords.x * left + coords.y * up;
    vec3 ray = normalize(pixelpos - eye);
    
    ray += hash33(ray) * 0.03 * pow(length(coords), 2.5) * pow(texture(iChannel0, vec2(0.0, 0.0)).r * 2.0, 3.0);
    
    vec3 pos = eye;
    float dist = 1.0;
    float iters = 32.0;
    for(int i = 0; i < 32; i++) {
        dist = distfunc(pos);
        pos += ray * dist;
        if(dist < 0.001) {
        	iters = float(i);
            break;
        }
    }
   	vec2 d = vec2(0.001, 0.0);
    vec3 normal = normalize(vec3(
        distfunc(pos - d.xyy) - distfunc(pos + d.xyy),
        distfunc(pos - d.yxy) - distfunc(pos + d.yxy),
        distfunc(pos - d.yyx) - distfunc(pos + d.yyx)
    ));
    vec3 lightd = normalize(vec3(1.0, -2.0, 1.0));
    float light = max(0.0, dot(normal, lightd)) + 0.21;
    float itershade = 1.0 - iters / 32.0;
    
    vec3 colorVal = color(light + itershade * 0.2);
    fragColor = vec4(colorVal.xyz, 0.0);
    fragColor = fragColor * clamp(mod(fragCoord.y, 2.0),  .7, 1.0) * (1.2 - pow(length(coords), 4.0)); 
}