
#define ITERS 6

float SCALE=2.0;
float MR2=0.0;

float mandelbox(vec3 position){
  vec4 scalevec = vec4(SCALE, SCALE, SCALE, abs(SCALE)) / MR2;
  float C1 = abs(SCALE + 7.0), C2 = pow(abs(SCALE), float(1-ITERS));
  vec4 p = vec4(position.xyz, 1.0) + pow(texture(iChannel0, vec2(length(position.xyz), 0.3) ).x, 0.4), p0 = vec4(position.xyz, 1.0) + pow(texture(iChannel0, vec2(length(position.xyz), 0.3) ).x, 0.4);  // p.w is knighty's DEfactor
  //vec4 p = vec4(position.xyz, 1.0) + pow(texture(iChannel0, vec2(length(position.xyz), 0.1) ).x, 0.1)/4., p0 = vec4(position.xyz, 1.0) + pow(texture(iChannel0, vec2(length(position.xyz), 0.1) ).x, 0.1)/4.5;  // p.w is knighty's DEfactor
  for (int i=0; i<ITERS; i++) {
    p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;  // box fold: min3, max3, mad3
    float r2 = dot(p.xyz, p.xyz);  // dp3
    p.xyzw *= clamp(max(MR2/r2, MR2), 0.0, 1.0);  // sphere fold: div1, max1.sat, mul4
    p.xyzw = p*scalevec + p0/6.;  // mad4
  }
  return (length(p.xyz) - C1) / p.w - C2;
}

float color(vec3 p){
    vec3 op = p;
    for (int i=0; i<ITERS; i++) {
        p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;  // box fold: min3, max3, mad3
        float r2 = dot(p.xyz, p.xyz);  // dp3
        p.xyz *= clamp(max(MR2/r2, MR2), 0.0, 1.0);  // sphere fold: div1, max1.sat, mul4
        p.xyz = p*SCALE/MR2 + op;  // mad4
//        p.xyz = p - pow(texture(iChannel0, vec2(length(p.xy), 0.) ).x/3., 0.01)*4.;

    }
  	return length(p/2.);
}

float trace(vec3 o,vec3 d){
    float v=0.0;
    for(int i=0;i<74;i++){
        vec3 p=o+d*v;
//        p=p + pow(texture(iChannel0, vec2(length(p.xy), 0.) ).x, 0.1);
        float mv=mandelbox(p);        
        if(mv<0.01){
            return v;
        }
        v+=mv *.9;
    }
    return 0.;
}

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord/iResolution.xy)*4.-2.;
    uv.x *= iResolution.x/iResolution.y;
    uv *= 4.0;
   //SCALE = 2.5 + iMouse.x * 2.0;
   // MR2 = iMouse.x * iMouse.x;
    //SCALE = 2.9 + sin(iTime*10.0)*.0;
    SCALE = 2.5;
    float mr = 0.6;
    MR2 = mr * mr;
    
      
    vec3 lookingTo = vec3(3.,2.,4.);
    float it = iTime / 5.;
    vec3 viewer = vec3(
        sin(iTime*.1) * 6.0,
        cos(iTime*.17) * 5.0,
        cos(iTime*.1) * 9.0
    );
    
    vec3 forward = normalize(lookingTo-viewer);
    vec3 rigth = cross(vec3(0.0,1.0,0.0),forward);
    vec3 up = cross(forward,rigth);
    
    vec3 direction = normalize(forward/0.1 * pow(texture(iChannel0, vec2(length(uv.y),.8) ).x, 0.005) + rigth * uv.x + up * uv.y);
    
    float dist = trace(viewer,direction);
    vec3 col=vec3(0.0);
    if(dist <=0.) {
        dist=dist + 2. * pow(texture(iChannel0, vec2(length(dist),0.005) ).x , .005);
    };    
     vec3 p = viewer + direction * dist ;
    
    
    if(dist!=0.) {
        
         float c = color(p);
        
   		 col = pal(c/50.0, 
                   vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20)
                   //vec3(0.8,0.5,0.4),vec3(0.2,0.4,0.2),vec3(2.0,1.0,1.0),vec3(0.0,0.25,0.25)
                   //vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25)
                  );

        //col = vec3(1.0);
    };

    
   
   
    float fog = 1. + .04 * pow(texture(iChannel0, vec2(length(p),.2) ).x, 0.005);
    fragColor.rgb = vec3(col * fog);
}