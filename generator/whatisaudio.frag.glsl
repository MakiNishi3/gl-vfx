vec3 hsv2rgb_smooth( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing
	return c.z * mix( vec3(1.0), rgb, c.y);
}

float rand(float n)
{
    return fract(sin(n) * 43758.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float valueS = 10.0;
    float t = iTime;
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    float xScale = iResolution.x;
	
    float fft = texture(iChannel0, vec2(pow(uv.y, 1.5), 0))[0];
    float rt = mod(t/(10.0), 1.0);
    
    if (uv.x > rt && abs(uv.x - rt)*xScale < 3.0) {
      	float value;
        
        if (fft < 0.1) {
            value = 0.0;
        } else {
            // value = (pow(valueS, fft) - 1.0) / (valueS - 1.0);
            value = sqrt(fft);
            // value = 0.8;
        }
        
        vec3 rgb = hsv2rgb_smooth(vec3(0.6 + fft, 0.8, value));
        //vec3 rgb = vec3(0,fft,0);
    	fragColor = vec4(rgb,1);
    } else {
        //if (rand(t*uv.x*uv.y*7.0) > 0.01) {
            discard;
        //} else {
            //fragColor = vec4(vec3(0.0), 1);
        //}
    }
}