#define freq(f) texture(iChannel0, vec2(f, 0.25)).x * 0.8


float avgFreq(float start, float end, float step) {
    float div = 0.0;
    float total = 0.0;
    for (float pos = start; pos < end; pos += step) {
        div += 1.0;
        total += freq(pos);
    }
    return total / div;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
       
    float aspect = iResolution.y/iResolution.x; //aspect ratio of viewport
    float value; //var
	vec2 uv = fragCoord.xy / iResolution.x; //vec ratio of fragment coordinate to width of viewport
 
    float bassFreq = pow(avgFreq(0.0, 0.1, 0.01), 0.85);
    float medFreq = pow(avgFreq(0.1, 0.6, 0.01), 0.85);
    float topFreq = pow(avgFreq(0.6, 1.0, 0.01), 0.85);
    
    
    float rot = radians(90.); // radians(45.0*sin(iTime)); //radians(45.0)
    float rot2 = radians(45.0*sin(iTime)); // radians(45.0*sin(iTime)); //radians(45.0)
    
    uv -= vec2(0.5, 0.5*aspect); //transform


    mat2 m = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
   	uv  = m * uv;
    uv *= vec2(0.05, aspect);
    uv /= vec2(0.5, uv.x*200.);

    vec2 pos = 150.0*uv;
    vec2 rep = fract(cos(rot2)-0.9*tan(rot2)+cos(rot2/2.0)*pos);
    float dist = min(min(rep.x, 1.0-rep.x), min(rep.y, 1.0-rep.y));
    float squareDist = length((floor(pos)+vec2(0.05)) - vec2(1.0) );
    
    float edge = 3.*sin(squareDist*0.5)*0.5;
    
    //edge = ((10.+iTime)/20.-edge *(iTime/5.))*0.5;
    edge = 1.0*fract(edge);
    //value = 2.0*abs(dist-0.5);;
    //value = pow(dist, 2.0);
    value = fract (iTime*2.0);
    value = mix(value, 1.0-edge, step(1.0, edge));
    //value *= 1.0-0.5*edge;
    //edge = pow(abs(1.0-edge), 2.0);
    
    edge = (medFreq*bassFreq)/fract(value-edge);
    value = smoothstep( edge-0.05, edge, 0.95*value);
    
    
    value += squareDist*.2;
    //fragColor = vec4(value);
    fragColor = mix(vec4(1.0,edge/2.,value/4.,1.0)*(cos(rot2)/4.0),vec4(0.5,0.75,1.0,1.), edge);
    fragColor.a = 0.25*clamp(edge, 0.0, 1.0);
}