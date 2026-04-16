vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv-=.5;
    uv.x*=iResolution.x/iResolution.y;
    uv+=.5;
    vec3 col = vec3(0);
    float v = 0.;
    
    float u = texture(iChannel0, vec2(.25*uv.x+uv.y*.17, 1.)+iTime).r;
    u+=texture(iChannel0, vec2(.17*uv.x+uv.y*.25, 1.)).r;
    u/=2.;
    v+=tan(u)/pow(u, 1.5);
    v*=min(1., sin(min(iTime,4.)/4.*3.14159/2.));
    col = hsv2rgb(fract(vec3(uv.x/5.-1.6, uv.y ,sin(iTime*2.-2.*u)/4.+.7)))*(1.-length(uv-.5));
    if (abs(length(uv-.5)-(.1+v/10.))<.002) {
		col = vec3(fract(u+uv.x*uv.y+.1*iTime), 1, 1);    	    
    }
    
	fragColor = vec4(hsv2rgb(col)/(abs(length(uv-.5)-(.1+v/10.))*1000.),1.0);
}
