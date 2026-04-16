float Distline(vec3 ro, vec3 rd, vec3 p) {//distance from a point to a line    
    return length(cross(p-ro,rd))/length(rd);
}
float Drawpoint(vec3 ro, vec3 rd, vec3 p) {
    float d = Distline(ro,rd,p);
    d =smoothstep(.3,.01,d);
    return d;
}    
float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio   

float noise(in vec2 xy, in float seed){
       return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}
float bitwiseXOR(in vec2 p) // thanks to https://www.shadertoy.com/view/4tt3z2
{
    float result = 0.0;
    for(float n = 0.0; n < 6.0; n+=1.0)
    {
        vec2 a = floor(p);
        result += mod(a.x+a.y,2.0);
        p/=2.0;
        result/=2.0;
    };    
    return result;
}


void DrawScanline( inout vec3 color, vec2 uv )
{
    float scanline 	= clamp( 0.5 + 0.5 * cos( 3.14 * ( uv.y + 0.1 * iTime ) * 4.5 * 1.0 ), 0.0, 1.0 );
    float grille 	= 0.5 + 0.5 * clamp( 1.5 * cos( 3.14 * uv.x * 10.0 * 1.0 ), 0.0, 1.0 );    
    color += abs(scanline * grille * 1.2);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iTime;
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    float wave = texture( iChannel0, vec2(uv.x,0.75) ).x;
    uv -= .5; // center is 0,0      
    uv.x *= iResolution.x / iResolution.y; // make it square    
    uv.x *= 1.0 -  smoothstep( 0.0, 0.9, abs(wave/(15. *(sin(t/3.)+1. )+5.) - uv.y/2.) );     

    vec3 ro = vec3(5.*cos(t/10.15),5.*sin(t/10.13),6.+3.*cos(t/30.)); //camera position   
    vec3 lookat = vec3(.5,.5,.5);
    vec3 f = normalize(lookat - ro); 
    vec3 r = cross(vec3(0., 1., 0.),f);
    vec3 u = cross(f,r);
    float zoom = sin(t/4.)/2.-2.;
    vec3 c = ro + f*zoom;   
    vec3 i = c + uv.x*r + uv.y*u;
    vec3 rd = i - ro; //screeeen
    // Time varying pixel color
    vec3 col = cos(iTime/20.+uv.xyx+vec3(0,8,4));
    DrawScanline(col, uv);
    vec3 p = vec3(sin(iTime),0.,cos(iTime));
    float d = 0.;      
    for(float i=-1.01;i<1.01;i+= .25){
        d += Drawpoint(ro,rd,vec3(i,1.,1.));   
        d += Drawpoint(ro,rd,vec3(i,-1.,1.)); 
        d += Drawpoint(ro,rd,vec3(i,1.,-1.));
        d += Drawpoint(ro,rd,vec3(i,-1.,-1.)); 
        
        d += Drawpoint(ro,rd,vec3(1.,i,-1.));   
        d += Drawpoint(ro,rd,vec3(1.,i,1.));
        d += Drawpoint(ro,rd,vec3(-1.,i,-1.));
        d += Drawpoint(ro,rd,vec3(-1.,i,1.));
        
        d += Drawpoint(ro,rd,vec3(-1.,-1.,i));
        d += Drawpoint(ro,rd,vec3(1.,-1.,i));
        d += Drawpoint(ro,rd,vec3(-1.,1.,i));
        d += Drawpoint(ro,rd,vec3(1.,1.,i));
    }    
        
        d += bitwiseXOR(vec2(d,col.x));
        float fft  = texture( iChannel0, vec2(uv.x,0.25) ).x;    

        

    d -= noise(-vec2(d, col.y), 1.);  
    d= mod(d,.8) + .1;  
    //d*=1000.;
    col *= vec3(d,d/2.,d ) ; 
    vec3 four = vec3( fft, 4.0*fft*(1.0-fft), 1.0-fft ) * fft;

    // Output to screen.
    fragColor = abs(vec4(col/1.7 + 0.1,1)) ;
}