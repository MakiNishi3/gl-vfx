

/**
 * rgba(229, 84, 84, 0.5) 
 * 
 * r = 229/255 -> r = 0.89
 * b =  84/255 -> b = 0.32
 * g =  84/255 -> g = 0.32
 * 
 * scale down by 1.25
 * 
 * r /= 1.25 -> r = 0.712
 * b /= 1.25 -> b = 0.25
 * g /= 1.25 -> g = 0.25
 */

const vec3 BLACK_VEC4 = vec3(0.0, 0.0, 0.0);
const vec3 WHITE_VEC4 = vec3(1.0, 1.0, 1.0);
const vec3 RED_VEC4   = vec3(1.0, 0.0, 0.0);
const vec3 GREEN_VEC4 = vec3(0.0, 1.0, 0.0);
const vec3 BLUE_VEC4  = vec3(0.0, 0.0, 1.0);

const vec3 MY_RED_VEC4 = vec3(0.89, 0.32, 0.32);


// fraction
struct frac { int n, d; };


float random(vec2 j) {
    return fract(sin(dot(j ,vec2(12.9898,78.233))) * 43758.5453);
}

float random(float i) {
    return random(vec2(i, i));
}

vec4 graident(vec2 coord, float base_p, float rand_p, float sico_p, float rate) {
    vec2 uv = coord / iResolution.xy;
    float base = base_p;
    float rand = rand_p * random(iTime);
    float sico = sico_p * sin(iTime * rate) * cos(iTime * rate);
	return vec4(uv,base + rand + sico,1.0);
}

float distance_percent(vec2 coord) {
    vec2 center = iResolution.xy / 2.0;
    float a_dist = distance(center, coord);
    return a_dist / iResolution.y;   
}

float percent(frac f) {
    return (1.0 / float(f.d)) * float(f.n);
}

float freq_per(frac f) {
    float per = percent(f);
    float freq_pos = floor(iChannelResolution[0].y * per);
    vec2 audio_pos = vec2(freq_pos, iTime);
    
    vec4 sound_pos = texture(iChannel0, audio_pos);
    return sound_pos.r;
}

vec4 whitten(vec4 colour, frac f) {
    float white_per = percent(f);
    float colour_per = 1.0 - white_per;
    colour = (colour * colour_per) + white_per;
    return colour;
}

float random_percent(frac min, frac max) {
    return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord) {
    vec2 position = fragCoord.xy;
    vec3 featureColour = MY_RED_VEC4;
    
    float dist = distance_percent(position);
    
    float ampilify = 1.5;

    float hihi = freq_per(frac(9, 10)) * 0.75;
    float hi = ((freq_per(frac(4, 5)) * 0.50) - 0.10) * ampilify;
    float mi = ((freq_per(frac(1, 3)) * 0.70) - 0.15) * ampilify;
    float lo = ((freq_per(frac(1, 5)) * 0.90) - 0.20) * ampilify;
    
    if (dist < lo) {
        vec4 c = vec4(featureColour, 1.0);
        vec4 colour = vec4(BLACK_VEC4, 1.0);
        
        if (dist < hi) {
            colour += c;
        }
        else if (dist < mi) {
            colour += whitten(c, frac(1, 3));
        }
        else {
            colour += whitten(c, frac(1, 2));
        }
        fragColor = colour;
    }
    else {
        vec4 colour = vec4(WHITE_VEC4, 1.0);
        vec4 anit = vec4(WHITE_VEC4 - featureColour, 0.0);
        if (random(position) * 0.4 > 1.0 - hihi) {
            colour -= anit * 0.5;
        }
        if (random(position) * 0.6 > 1.0 - hihi) {
            colour -= anit * 0.5;
        }
        fragColor = colour;
    }
}

