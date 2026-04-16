void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	
	vec4 chan = texture(iChannel0, vec2(0.0, 0.0));
	float bass = texture( iChannel0, vec2(20./256.,0.25) ).x*.75+texture( iChannel0, vec2(50./256.,0.25) ).x*.25;
    
    mat2 m = mat2(vec2(1., -0.15 * sin(iTime * 8. + bass*8.)*bass), vec2(0.15 * cos(iTime * 8.)*bass, 1.));
    float t = 0.5;
    mat2 rot = mat2(vec2(sin(t), cos(t)), vec2(-cos(t), sin(t)));
    
	vec3 color = vec3(0.0);
    vec2 uv = fragCoord.xy/iResolution.xy;
	vec2 position = (fragCoord.xy/iResolution.xy*2.-1.) * 32.;
    position.x *= iResolution.x/iResolution.y;
    position = rot*m*position;
    
    position.xy += iTime * 0.025 * bass + 38. + iTime*8.;

	color = vec3(chan.r, .4, .2);
	
    float pp = 1.0;
	for (int i = 0; i < 7; ++i) {
        float size = 0.0125;
		float total_squares = pp;
        pp = pp*3.;
		float sq_size = 50.0 / total_squares;
		
		float x = mod(position.x / sq_size, 3.0+size);
		float y = mod(position.y / sq_size, 3.0+size);
		
		if (int(x) == 1 && int(y) == 1) {
			color = vec3(.0);
			break;
		}
	}
	fragColor = vec4( color, 1.0 );
    
    //fragColor.rgb = mix(vec3(0.0), fragColor.rgb, smoothstep());

}