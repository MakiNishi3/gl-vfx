vec3 color1 = vec3(20,30,48)/255.;
vec3 color2 = vec3(36,59,85)/255.;

vec3 color11 = vec3(255,95,109)/255.;
vec3 color12 = vec3(255,195,113)/255.;

mat2 rotateAroundZ(float angle)
{
    return mat2(cos(angle), -sin(angle),
                sin(angle), cos(angle));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 aspect = vec2(iResolution.x/iResolution.y, 1.0);
    vec2 tUv = fragCoord.xy / iResolution.xy*aspect;
    vec2 uv;
	uv.y = (fragCoord.y / iResolution.y)*4. - 2.;
    uv.y = 1.0 - pow(abs(uv.y), 1.0);
    //uv.y = 1.0 - pow(abs(sin(3.14*uv.y)), 1.5);

    uv.x = fragCoord.x / iResolution.x * aspect.x*4. - 3.5;
        uv.x = 1.0 - pow(abs(uv.x), 1.0);

    fragColor = vec4(mix(color1, color2, sin(tUv.y)), 0.);
    float audio = texture(iChannel0, vec2(0.25,tUv.y)).x;
    for( int i = 0; i < 20; i++)
    {
        float pos = float(i+1);
        vec2 locUv = uv*rotateAroundZ(.314*pos);
		locUv.y += iTime/4.;
        locUv.x += abs(sin(iTime/4.))*0.1;

        float offset = audio;
        //float offset = cos(locUv.y*iTime/160.)*audio;
        float mainTrunk = sin(locUv.y*3.)*abs(cos(locUv.y*2.))*0.5;
        float func = 
            smoothstep(mainTrunk, mainTrunk +0.03, locUv.x - offset + 0.4*(1.- tUv.y)) - 
            smoothstep(mainTrunk, mainTrunk +0.03, locUv.x - offset);
        fragColor.a += func*0.2;
        
    }
    vec4 color = vec4(mix(color1, color2, tUv.y), 1.0);
    vec4 color1 = vec4(mix(color12, color11, length(uv*3.)), 1.0);
    fragColor = mix(color,color1,fragColor.a);

}