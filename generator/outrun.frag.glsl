vec3 fade(vec3 fg, vec3 bg, float alpha) {
    return mix(bg, fg, alpha);
    return bg*(1.0-alpha) + fg*(min(1.0,alpha));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float a = 0.0;
    float h = iResolution.y;
    float w = iResolution.x;
    float distort = abs(sin(iTime/10.0));
    float scale = h/450.0;
	
    vec2 uv = fragCoord/iResolution.xy;
	float mic = texture( iChannel0, vec2(uv.x,1.0)).x;
    vec3 col = vec3(0.15,0.0,0.15)*(uv.y+0.05)*distort;
    
    //sun drop
    float distSun = distance(fragCoord, iResolution.xy*0.5-vec2(0.0,(-50.0)));
    if (distSun < h*(2.5) && distSun > h*0.0) {
        col = fade(col, vec3(0.4,0.24,0.4), distSun/h*(distort*6.0));
    }
    
    //sun
    if (distance(fragCoord, iResolution.xy*0.5-vec2(0.0,10.0)) < h*max(0.25+(distort/4.0), 0.1)) {
        if (fragCoord.y < h/2.0 - 1.5*scale || fragCoord.y > h/2.0 + 3.0*scale) {
            if (fragCoord.y < h/2.0 + 5.0*scale || fragCoord.y > h/2.0 + 22.0*scale) {
                if (fragCoord.y < h/2.0 + 25.5*scale || fragCoord.y > h/2.0 + 35.5*scale) {
                    if (fragCoord.y < h/2.0 + 42.0*scale || fragCoord.y > h/2.0 + 47.0*scale) {
                        if (fragCoord.y < h/2.0 + 53.0*scale || fragCoord.y > h/2.0 + 55.5*scale) {
                            if (fragCoord.y < h/2.0 + 62.0*scale || fragCoord.y > h/2.0 + 64.5*scale) {
                                float maxSun = max(distort, 0.25);
                                col = vec3(maxSun, maxSun, maxSun-0.2)*(uv[1]*5.0);
                                
                            }
                        }
                    }
                }
            }
        }
   	}
    
    // waves
    if (fragCoord.y*0.5 < cos(fragCoord.x*0.01)+h*(max(0.25, 0.225+mic/10.0))) {
        col = vec3((1.0-distort)*0.3, 0.0, (1.0-distort)*0.3);
		//vec3 lineCol = 0.9-(uv.y*(min(0.6, max(0.5, distort)))*2.0)-vec3(distort, 0.85, 0.2);
        vec3 lineCol = 0.7-(1.0*uv.y*(min(0.5, max(0.3, distort/2.0))))-vec3(distort/5.0, 0.65, 0.1);
        float roadMod = 0.7 + (mic*2.0);
        
        // fg vert
        //if (uv.x > (0.498+uv.y/250.0) && uv.x < (0.503-uv.y/250.0) && mod(uv.y+mod(iTime/5.0, 0.4), 0.15) > 0.1) {
        if (uv.x > (0.498+uv.y/250.0) && uv.x < (0.503-uv.y/250.0)) {
			col = lineCol * roadMod;
        } else if (mod(fragCoord.x-w/2.0, h/1.89-fragCoord.y) < 2.25 && (uv.x < 0.25+uv.y/2.0 || uv.x > 0.79-uv.y/1.76)) {
            col = lineCol;
        }
        
		// fg hoz
        float c = 0.5*pow(0.5, (uv.y-0.1)*10.0);
        float s = 0.625*pow(2.0, (uv.y-0.1)*10.0);
        float d = min(0.02, c/8.0);
        if (mod(uv.y+mod(iTime/s, c), c) < d && (uv.x < 0.2+uv.y/1.75 || uv.x > 0.8-uv.y/1.76)) {
        	col = lineCol;
        }
        if (mod(uv.y+mod(iTime/s, c), c) < d && uv.x > 0.2+uv.y/1.75 && uv.x < 0.8-uv.y/1.76) {
            col = lineCol * roadMod;
        }
        
    }

    fragColor = vec4(col,a);
}

