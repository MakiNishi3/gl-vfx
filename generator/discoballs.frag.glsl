#define res_     iResolution
#define time_    iTime
#define pi_      3.14159265

#define crot(a)  mat2(cos(a),-sin(a),sin(a),cos(a))

vec2  domain(vec2 uv, float s);

void mainImage(out vec4 fragColor, vec2 fragCoord) {
    // Initial calculations
    // ---------------------------------------------------------------------------
    vec2 p = domain(fragCoord, 2.);
    vec2 np = fragCoord / res_.xy;
    float sound = texture(iChannel0, vec2(-.2)).x;
    float sound_movement = 2.*smoothstep(0., 3., sound);
    // ---------------------------------------------------------------------------
    
    // Scene multiplication, depending on sound
    // ---------------------------------------------------------------------------
    if(sound_movement > .22) {
        p.x = mod(p.x, 3.6) - .1;
        p.y *= 2.1;
        p.x *= 1.05;
    	p.y = mod(p.y, 4.2) - 2.3;
    }
	// ---------------------------------------------------------------------------
    
    // Diagonal line
    // --------------------------------------------------------------------------
    float d_diagonal_line = abs(p.x - p.y) + .1*sound_movement*sin(21.*sound*p.x);
    // --------------------------------------------------------------------------
    
    float fq = 1.;
    
    // Pendulum string
    // --------------------------------------------------------------------------
    vec2 pendulum_string_domain = p;
    pendulum_string_domain -= vec2(2., 2.);
    pendulum_string_domain *= crot(sound_movement * sin(fq*time_));
    float d_vertical_line = abs(pendulum_string_domain.x) + .02*sin(11.*p.y);
    // --------------------------------------------------------------------------
    
    // Circle
    // --------------------------------------------------------------------------
    float movment_angle = (-3.*pi_/2. - 1. * sound_movement*sin(fq*time_));
    vec2 circle_domain = p;
    circle_domain  -= vec2(2., 1.7 + sound_movement * 2.);  
    circle_domain  += vec2(3.2 * cos(movment_angle), 3.2 * sin(movment_angle));
    float d_circle  = abs(length(circle_domain) - .5);
	float d_disk    = (length(circle_domain) - .5);
    // --------------------------------------------------------------------------
    
    // Light
    // ---------------------------------------------------------------------
    vec2 light = vec2(6., 2.); 
    float diffuse = 1. + max(0., dot(p, light));
    // ---------------------------------------------------------------------
    
    // Shading
    // ---------------------------------------------------------------------
    vec3 color = vec3(0.);
    
    vec3 lb = vec3(0.1, 0.4, 1.7)*.5 + .3;
    vec3 lg = vec3(0.1, 0.7, 0.1);
    
    color += fract(mix(lg, vec3(sin(14.*time_)*.5, .2, .4), p.x))*smoothstep(.06, .01, d_diagonal_line);
   	
    if(pendulum_string_domain.y > -3. + sound_movement * 2.) 
        color += mix(lg, vec3(sin(14.*time_)*.5, .2, .4), pendulum_string_domain.y)*smoothstep(.06, .01, d_vertical_line);
    
    color += mix(lg, vec3(sin(14.*time_)*.5, .2, .4), p.x) * smoothstep(.04, .01, d_circle);
    color += mix(lb, vec3(sin(14.*time_))*.5, 2.5*length(circle_domain + vec2(-.2)) - .001)
             * smoothstep(.02, .01, d_disk);
    
    if(p.y > 2.01) color= vec3(0.);
    // ---------------------------------------------------------------------
   
    color *= .12*diffuse * (vec3(250., 250., 175.) / 255.);
   
    fragColor = vec4(color, 1.);
}

vec2 domain(vec2 uv, float s) {
    return (2.*uv.xy-res_.xy) / res_.y*s;
}