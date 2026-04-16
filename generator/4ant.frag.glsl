vec4 b = vec4(0., 0., 0., 1.);
vec4 w = vec4(1., 1., 1., 1.);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 st = fragCoord.xy / iResolution.xy;
    float ar = iResolution.y / iResolution.x;
    
    vec2 c = vec2(0.5, 0.5);
	
    float bandHeight = 0.5;
    
    vec2 samplePoint = vec2(st.x, .1);
    float maxR = 200.0;
    float v = texture(iChannel0, samplePoint).x;
    float R = v * maxR;
    
    float r =  R;
    float d = distance(fragCoord.xy, iResolution.xy / 2.0);
    
    
    if (d + 1. < r){
        fragColor = 1.0/w + mix(vec4(d/R, 0.6, 0.5, 1), vec4(0.5, d/R, 0.5, 1), 0.3);
        return;
    }
    
    if (d - 2. < r) {
    	fragColor = 1.0/w + mix(vec4(d/R, 0.6, 0.5, 1), vec4(0.5, d/R, 0.5, 1), 0.3);
        fragColor.g = 0.5;
        return;
    }
    
    if (d - 3. < r) {
    	fragColor = 1.0/w + mix(vec4(d/R, 0.6, 0.5, 1), vec4(0.5, d/R, 0.5, 1), 0.3);
        fragColor.r = 0.5;
        return;
    }
    
	fragColor = w * vec4(st.y+0.2, st.x  + (sin(iTime)/2.0), v + (sin(iTime)), 0.2);
}

