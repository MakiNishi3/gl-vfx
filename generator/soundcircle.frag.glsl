float pi = 3.14159265358979;

float w(float n) {
    return cos(n*pi)*0.5+0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float t = iTime;
    vec2 uv = fragCoord/iResolution.xy;
    vec2 suv = (2.*fragCoord-iResolution.xy)/min(iResolution.x,iResolution.y);
    
    
 


    vec2 tex = texture(iChannel0, vec2(uv.x/2.+1.,0.0)).xy;
    float tx = tex.x;
    float ty = tex.y;
    

    float d = length(suv);
    
    d /= tx;
    
    vec3 c = vec3(
        w(uv.x+t),
        w(uv.x+t+1.3),

        w(uv.x+t+1.6)
    );
    
    if (abs(d)>0.8) {
        c /= (d*d*d*d*d*d);
        //c = vec3(0.0);
    };

 
    fragColor = vec4(c,1.0);
}