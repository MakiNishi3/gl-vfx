void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	vec3 color = vec3(0.0, 0.0, 0.0);
	float piikit  = texture(iChannel0, vec2(uv.x, 1.0)).r;
	
	float flash = texture(iChannel0, vec2(0.3, 0.0)).r;
	float glow = (0.01 + flash*0.02)/abs(piikit - uv.y);
	color = vec3(0.0, glow*0.5, glow);
	color += vec3(sqrt(glow*0.2));
	
	
	fragColor = vec4(color, 1.0);
}