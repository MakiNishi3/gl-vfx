#define MAX_DIST 10.0

// 0.309017
// 0.9510565
mat3 twistor = mat3(0.9510565, -0.309017, 0.0,
                    0.309017, 0.9510565, 0.0,
                    0.0, 0.0, 1.0);

vec3 thicks = vec3(0.01);

float s_min(in float x, in float y, in float s) {

    float bridge =
        clamp(abs(x-y)/s, 0.0, 1.0);
    return min(x,y) - 0.25 * s * (bridge - 1.0) * (bridge - 1.0);
}

float s_max(in float x, in float y, in float s) {
    float bridge =
        clamp(abs(x-y)/s, 0.0, 1.0);
    return max(x,y) + 0.25 * s * (bridge - 1.0) * (bridge - 1.0);
}

float cyl_sdf(in vec3 p, in vec3 dir, in float radius, in float scale) {
    float l = length(p - dir * dot(p, dir));
    return l * max(0.2, 1.0 - 1.5 * scale) -  radius;
}

float bundle(in vec3 p, in float slope_sign) {
    vec3 ptmp = p;
    float result = MAX_DIST;

    float lookup = 0.0;
    for (int i = 0; i < 20; ++i) {
    	ptmp = twistor * ptmp;
        
        result = min(result, cyl_sdf(ptmp - vec3(0.5, 0.0, 0.0),
                                     vec3(0.0, slope_sign * 0.6, 0.8),
                                     0.001, 
                                     texture(iChannel0, 
                                             vec2(lookup, 0.0)).r));
        
        
        lookup += 0.05;
        
    }
    return result;
}


    

float sdf(in vec3 p) {
    float s = MAX_DIST;
    
    s = bundle(p, 1.0);
    // s = s_min(s, bundle(p * vec3(-1.0, -1.0, 1.0), -1.0, 0.01 + thicks.y), thicks.z);
 
    // s = s_max(s, abs(p.z) - 1.25, 0.01);
    return s;
}

vec3 normal_to_sdf(in vec3 p) {
    float f = sdf(p);
    return normalize(vec3(sdf(p + vec3(0.1, 0.0, 0.0)) - f,
                          sdf(p + vec3(0.0, 0.1, 0.0)) - f,
                          sdf(p + vec3(0.0, 0.0, 0.1)) - f));
}

float trace(in vec3 pt, in vec3 dir, out float closest) {
    float d = sdf(pt);
    float accum = 0.0;
    closest = d;
    vec3 p = pt;
    for (int i = 0; i < 100; ++i) {
        accum += 1.0 * d;
        p = pt + accum * dir;
        d = sdf(p);
        closest = min(closest, max(d, 0.0));
        if (d < 1.0e-2 || accum > MAX_DIST) {
            return accum;
        }
    }
    return MAX_DIST + 1.0;
}

vec3 color(in vec3 p, in vec3 dir) {
    float closest;
    float d = trace(p, dir, closest);
    if (d > MAX_DIST) {
        float weight = 1.0 / (1.0 + 5.0 * closest);
        return weight * (0.5 + 0.5 * dir);
    }
    vec3 at = p + d * dir;
    vec3 n = normal_to_sdf(at);
    vec3 b = reflect(dir, n);
    return 0.5 + 0.5 * b;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    
	vec3 dir = normalize(vec3(uv, sqrt(3.0))).zxy;
    
    vec3 orig = vec3(0.0);
    float len = 1.0;
    vec3 off = vec3(-2.0 * len, 0.0, 0.0);

    
    float theta = 2.0 * 3.141592654 * iMouse.x / iResolution.x;
    theta = theta + iTime;
    float st = sin(theta);
    float ct = cos(theta);
 
    mat3 rot = mat3(ct, st, 0.0,
                    -st, ct, 0.0,
                    0.0, 0.0, 1.0);
    dir = rot * dir;
    off = rot * off;

    orig = orig + off;
    
    vec3 col = color(orig, dir);

    // Output to screen
    fragColor = vec4(col,1.0);
}
