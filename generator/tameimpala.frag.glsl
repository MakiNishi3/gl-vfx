// Created by Ottavio Hartman - hartmano@sas.upenn.edu - https://github.com/omh1280

#define PI 3.1415927
#define NUM_STREAKS 12.
#define STREAK_SIZE .15
#define STREAK_WIDTH .3

// HSV to RGB created by inigo quilez - iq/2014
vec3 hsv2rgb( in vec3 c )
{
    vec3 _rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	return c.z * mix( vec3(1.0), _rgb, c.y);
}

// Cartesian and Polar conversions
vec2 c2p(vec2 c) {
    return vec2(length(c), atan(c.y, c.x));
}
vec2 p2c(vec2 p) {
    return p.x*(vec2(cos(p.y), sin(p.y)));
}

// Rand and noise function. Credit to patriciogonzalezvivo
float rand(float n){return fract(sin(n) * 43758.5453123);}
float noise(float p){
    float fl = floor(p);
  	float fc = fract(p);
    return mix(rand(fl), rand(fl + 1.0), fc);
}

// Basic circle function
float circle(vec2 uv, vec2 center, float radius) {
    float delta = abs(noise(iTime))/30. + .01;
    return smoothstep(radius + delta, radius - delta, length(uv - center));
}

float head(vec2 uv, vec2 center, float radius) {
    vec2 uv2 = uv - center;
    uv2.x /= .78;
    
    // Create cool "expanding head" technique
    float sound = texture(iChannel0, vec2(abs(uv2.x*sin(uv2.y)), .25)).x;
    uv2 *= 2.*noise(iTime*.5 + sound);
    
    // Create the head itself
    vec2 rtheta = c2p(uv2);
    float angle = rtheta.y;
    float neck = 1.*pow(angle + .2, 2.) + .66;
    float chin = .08*sin(7.*angle) + .92;
    float face = .98 + sin((angle+.45)*7.)/22.;
    
    if ((angle < PI/10.) && (angle > -PI/4.)) {
        uv2 /= neck;
    } else if ((angle > PI/1.64) || (angle < -PI/1.03)) {
		uv2 /= face;
    } else if (angle < -PI/2.) {
        uv2 /= chin;
    } else if ((angle < PI/1.64) && (angle > PI/10.)) {
        // Cranium
        uv2 /= .94;
    }
    
    return circle(uv2 + center, center, radius);
}

float streak(vec2 uv, vec2 center, float radius) {
    vec2 rtheta = c2p(uv);
    vec2 center_p = c2p(center);
    
    // Make streaks skinny
    rtheta.y -= (center_p.y - rtheta.y)/STREAK_WIDTH;
    
    // Waviness
    rtheta.y += .1*noise(rtheta.x*60. + sin(rtheta.y));
    
    return circle(p2c(rtheta), center, radius);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord.xy / iResolution.yy;
    float maxX = iResolution.x/iResolution.y;

    vec2 center = vec2(.5*maxX, .5);
    vec2 rtheta = c2p(uv - center);
    
    // STREAKS
    float radius = PI/(NUM_STREAKS*.5);
    // Streaks' displacement away from head center
    float disp = mod(.25*iTime, 1.);
    // Repeat streaks in a circle
    rtheta.y = mod(rtheta.y - .3*iTime, radius) - radius/2.;
    vec2 uv2 = p2c(rtheta);
    float i = streak(uv2, vec2(disp, 0.), STREAK_SIZE);
    
    // HEAD
    float h = head(uv, center, .3);

    // TRIPPY
    vec3 pixel = vec3(0.08, 0.08, 0.15);
    
    // Streak colors (change as disp increases)
    pixel = mix(pixel, hsv2rgb(vec3(disp, .73, 1.)), i*(length(uv2)));
    
    // Head color
    vec3 pale = vec3(1.0, .88, .70);
    pixel = mix(pixel, pale, h);
    
    // Trippy background
	float sound = texture(iChannel0, vec2(abs(uv2.x*sin(uv2.y)), .25)).x;

    for (float i = 0.; i < 5.; i++) {
    	uv2 = p2c(c2p(uv2) + vec2(sin(.1*iTime), sin(.4*iTime*i)));
    	pixel += .1*(noise(iTime + noise(iTime*sin(uv2.x/uv2.y))*sin(uv2.x*10.)*rtheta.y)+ 
             noise(iTime*i + noise(iTime*sin(uv2.x+uv2.y))*sin(uv2.y*20.*i)*sound*i));
    }
    // More colors
    pixel *= vec3(3.*noise(.1*iTime*(uv2.x * uv2.y)), 2.*noise(sound), sound);
    
    fragColor = vec4(pixel, 1.0);
}