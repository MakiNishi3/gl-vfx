float bump(float x) {
	return abs(x) > 1.0 ? 0.0 : 1.0 - x * x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy);
	
	float c = 3.0;
	vec3 color = vec3(1.0);
	color.x = bump(c * (uv.x - 0.75));
	color.y = bump(c * (uv.x - 0.5));
	color.z = bump(c * (uv.x - 0.25));
	

	float line = abs(0.01 / abs(0.5-uv.y) );
	uv.y = abs( uv.y - 0.5 );
	
	vec4 soundWave =  texture( iChannel0, vec2(abs(0.5-uv.x)+0.005, uv.y) ).rrrr;
	color *= line * (1.0 - 2.0 * abs( 0.5 - uv.xxx ) + pow( soundWave.y, 10.0 ) * 30.0 );
	
	fragColor = vec4(color, 0.0);
}