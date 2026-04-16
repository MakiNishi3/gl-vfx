#define tSize 0.05
#define blobPower 0.45

float samp1()
{
	return blobPower * (
		texture( iChannel0, vec2( 0.05, 0.25 ) ).x + 
		texture( iChannel0, vec2( 0.3, 0.25 ) ).x);
}

float blob(vec2 uv, vec2 triPos, float flip)
{
	float len = length(uv - triPos);
	
	float r = min(0.7, ((1.-tSize*2.)/(3.*len)*0.1*samp1()));
	return r;	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0 + 2.0 * fragCoord.xy / iResolution.y;
	
	vec3 col = vec3(0.);
	
	for (float i = 0.; i < 80.; i++)
	{
		float b = blob(uv+ vec2(0.75-tSize*i, sin(i)*0.05), vec2(0.,-1.5+mod(iTime*(cos(i)), 2.+i*0.1)), floor(cos(i)+0.99));
		col += vec3(b);
	}
	col = mix(vec3(1.),vec3(0.), floor(ceil(col.r) - 1.0));
	col = vec3( min(col.x, col.x*0.6*(0.5/abs(uv.y))));

	fragColor = vec4(col,1.0);
}