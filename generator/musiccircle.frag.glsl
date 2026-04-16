#define radius .25
#define ep .005

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    	vec2 uv2 = fragCoord.xy / iResolution.xy;
    
    vec4 effect = vec4(0);
    vec2 center = vec2(.5+(iResolution.x-iResolution.y)/(2.*iResolution.y),.5);
    float center_dist = distance(uv, center);
    float wave = texture(iChannel0,vec2(cos(dot(normalize(uv-center),vec2(cos(iTime),sin(iTime))))/3.14159,1.)).r/4.;
    float analyz = texture(iChannel0,vec2(cos(dot(normalize(uv-center),vec2(sin(iTime),cos(iTime))))/3.14159,0.)).r;
        float analyz2 = texture(iChannel0,vec2(cos(dot(normalize(uv-center),vec2(cos(.9*iTime+.5),sin(.9*iTime+.5))))/3.14159,0.)).r;
    analyz*=analyz/8.;
    analyz2*=analyz2/8.;
    vec4 color = vec4(texture(iChannel1,center/2.+(uv2-center/2.) * (.8+0.5*wave*wave*2.)).r,
                      texture(iChannel1,center/2.+(uv2-center/2.) * (.8+wave*wave*2.)).g,
                      texture(iChannel1,center/2.+(uv2-center/2.) * (.8+1.5*wave*wave*2.)).b,
                      texture(iChannel1,center/2.+(uv2-center/2.) * (.8+wave*wave*2.)).a)*(4.*analyz2);
    if (center_dist<radius+wave && center_dist >(radius-ep)+wave)effect = vec4(.5,.1,.7,1.);
    if (center_dist<radius+analyz && center_dist >(radius-ep)+analyz)effect = vec4(.5,.1,.7,1.)/2.;
    if (center_dist<(radius-ep)+wave && center_dist >radius+analyz)effect = vec4(.5,.1,.7,1.)/3.;
     if (center_dist<radius+wave*wave*4. && center_dist >(radius-ep)+wave*wave*4.)effect = vec4(.5,.1,.7,.8)/1.5;

    color = mix(color, effect, 2.*effect.a);
 	color /= max(.8,distance(uv2,vec2(.5))*distance(uv2,vec2(.5))*5.);
	fragColor = color;
}