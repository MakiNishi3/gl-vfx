/* Embellished audio visualizer by chronos
// 
// Recommended tracks:
// https://soundcloud.com/wearecastor/rad
// https://soundcloud.com/kubbi/pathfinder
// https://soundcloud.com/finn-bollongino/galactic-love-song-original
// https://soundcloud.com/zircon-1/augment
*/

#define DUST_MOTE_COUNT 10
#define WIDTH 1.0

float audio_freq( in sampler2D channel, in float f) { return texture( channel, vec2(f, 0.25) ).x; }
float audio_ampl( in sampler2D channel, in float t) { return texture( channel, vec2(t, 0.75) ).x; }

vec3 dust_mote(vec3 color, vec2 pos, vec2 center, float radius, float alpha, float focus){
    vec2 disp = pos - center;
    float dist = dot(disp,disp);
    vec3 mote = (color+0.005)*alpha* vec3(smoothstep(radius * (1.0+focus), radius, dist));
    return (1.0-mote)*color + mote;
}

float rnd(float s) { return sin(2923.138674*s); }

vec3 dust_motes(vec3 color, vec2 pos, const int number, float t) {
    vec3 new_color = color;
    for(int i = 0; i < DUST_MOTE_COUNT; i++) {
        float fudge = rnd(float(i));
        float cycle = fract(t+fudge);
    	float fade = 2.0 * cycle * (1.0 - cycle);
        vec2 center = vec2(fudge+sin(t*fudge+fudge), 1.1-cycle*2.0+rnd(fudge));
        new_color = dust_mote(new_color, pos, center, 0.01+0.007*fudge, 0.5*fade, 0.6 + 0.4*fudge); 
    }
    return new_color;
}

vec3 B2_spline(vec3 x) { // returns 3 B-spline functions of degree 2
    vec3 t = 3.0 * x;
    vec3 b0 = step(0.0, t)     * step(0.0, 1.0-t);
	vec3 b1 = step(0.0, t-1.0) * step(0.0, 2.0-t);
	vec3 b2 = step(0.0, t-2.0) * step(0.0, 3.0-t);
	return 0.5 * (
    	b0 * pow(t, vec3(2.0)) +
    	b1 * (-2.0*pow(t, vec3(2.0)) + 6.0*t - 3.0) + 
    	b2 * pow(3.0-t,vec3(2.0))
    );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y += 0.02 * sin(3.0*uv.x+iTime / 2.0);
    vec2 centered = (uv - 0.5)/WIDTH;
    float intro = smoothstep(0.0, 30.0, iTime);
    centered.y -=  intro - 1.0;
    float sample0 = audio_ampl(iChannel0, 0.02);
    centered /= 1.0 + 0.03*(sample0-0.5);
    centered.x *= 0.97 + 0.01*(1.0 + cos(iTime));
    float mirrored = abs(centered.x);
    centered.x *= iResolution.x / iResolution.y;
    
    float dist2 = dot(centered, centered);
    float clamped_dist = smoothstep(0.0, 1.0, dist2);
    float arclength    = abs(atan(centered.y, centered.x) / radians(360.0))+0.01;
    float shine_shift = 0.15-centered.y;
    
    float sample1 = audio_freq(iChannel0, mirrored + 0.01);
    float sample2 = audio_ampl(iChannel0, clamped_dist);
    float sample3 = audio_ampl(iChannel0, arclength);
    float sample4 = audio_freq(iChannel0, 0.01+.05*mirrored/(shine_shift));

    // Color variation functions
    float t = iTime / 100.0;
    float polychrome = (1.0 + sin(t*10.0))/2.0; // 0 -> uniform color, 1 -> full spectrum
    vec3 spline_args = fract(vec3(polychrome*uv.x-t) + vec3(0.0, -1.0/3.0, -2.0/3.0));
    vec3 spline = B2_spline(spline_args);
    
    float f = abs(centered.y);
    vec3 base_color  = vec3(1.0, 1.0, 1.0) - f*spline;
    vec3 flame_color = pow(base_color, vec3(3.0));
    vec3 disc_color  = 0.20 * base_color;
    vec3 wave_color  = 0.10 * base_color;
    vec3 flash_color = 0.05 * base_color;
    
    float disp_dist = smoothstep(-0.2, -0.1, sample3-dist2);
    disp_dist *= (1.0 - disp_dist);
	
    vec3 color = vec3(0.0);
    
    float shine = (sample4)*smoothstep(1.5, 0.0, shine_shift)*smoothstep(0.05, 0.3, shine_shift);
    shine = pow(shine, 5.0);
    
    // spline debug
    // vec3 s = smoothstep(-0.01, 0.01, spline-uv.y); color += (1.0-s) * s;
    
    float v = abs(centered.y);
    color += flame_color * smoothstep(v, v*8.0, sample1);
    color += disc_color  * smoothstep(0.5, 1.0, sample2) * (1.0 - clamped_dist);
    color += flash_color * smoothstep(0.5, 1.0, sample3) * clamped_dist;
    color += wave_color  * disp_dist;
    color = dust_motes(color, centered+sample0*0.03-0.06, 10, t*10.0);
    color += intro * intro*flame_color * shine;
    color = pow(color, vec3(0.4545));
	fragColor = vec4(color, 1.0);
}