

float map(vec3 p)
{
    
    
    vec3 q = fract(p) * 2.0 - 1.0;
    q.y = q.y*0.6*cos(iTime);
    //q.x = texture( iChannel0, vec2(q.x,q.x) ).x;
    
    //q.x = q.z*0.1*cos(iTime);
    //q.x = q.x*.9;
    
    //return length(q) - 0.05;
    return length(q)-sin(iTime)/9.0-.3;
}


float trace(vec3 o, vec3 r)
{
    float t = 0.0;
    for(int i = 0; i < 32; i++) {
        vec3 p = o + r * t;
        float d = map(p);
        t += d * .5;
    }
    return t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv = uv*2.0 - 1.0;
    
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 r = normalize(vec3(uv, 1.0));
    //vec3 r = vec3(uv,1.0);
    
    float the = iTime * .1;
    r.xz *= mat2(cos(the), -sin(the), -sin(the), -cos(the));
    
    vec3 o = vec3(0.0, iTime, iTime);
    
    float t = trace(o, r);
    
    float fog_bright = 0.3;
    fog_bright = 1.0-smoothstep(.5,.9,(texture( iChannel0, vec2(1.0, 3.0) ).x));
    //fog_bright = texture(iChannel0, vec2(0.0,0.0)).x/3.0;
    float fog = 1.0 / (1.0 + t * t * fog_bright);
    
    vec3 fc = vec3(fog);
    
    fc.x =  fc.x * sin(iTime);
    fc.z = fc.z * cos(iTime+9.4);
    //fc.z = smoothstep(.3, .9, abs(fc.z*sin(iTime)));
    //fc.z = fc.z * -sin(iTime);
    //fc.z+=1.0;
	fragColor = vec4(fc,1.0);
    //fragColor = vec4(0.0);
}