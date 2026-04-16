vec3 render(vec2 p) 
{
    float s=(texture(iChannel0,vec2(.5)).x-.2)*5.;
    float d=length(p*.8)-pow(2.*abs(.5-fract(atan(p.y,p.x)/3.1416*2.5+iTime*.3)),2.5)*.1;
    vec3 col=.01/(d*d)*vec3(.5,.7,1.5)*(1.+s);
    d=sin(length(p*2.)*10.-iTime*3.)-sin(atan(p.y,p.x)*5.)*1.;
    col+=.1/(.2+d*d)*vec3(1.,.0,1.);
    for(int i=0;i<6;i++) p=abs(p)/dot(p,p)-1.;
    col+=.001/dot(p,p);
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord-iResolution.xy*.5)/iResolution.y;
    
    // Time varying pixel color
    vec3 col = render(uv);

    // Output to screen
    fragColor = vec4(col,1.0);
}