

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = (fragCoord-vec2(iResolution.x*0.08,0.0))/min(iResolution.x,iResolution.y);
    vec3 colblue = vec3(4./255.,163./255.,230./255.);
    vec3 colpink = vec3(235./255.,20./255.,143./255.);
    colpink = vec3((sin(iTime)/2.0)+1.0,(sin(iTime)/2.0)+0.3,0.0);
    colblue = vec3(0.0,(sin(iTime)/2.0)+0.3,(sin(iTime)/2.0)+1.0);
    vec3 col = mix(vec3(1.,1.,1.), mix(colblue,colpink,uv.y), uv.x);
    
    vec2 uvjames = (uv-0.5);
    uv-=length(uvjames)*normalize(uvjames)*texelFetch(iChannel0,ivec2((((atan(-abs(uvjames.x),uvjames.y)/(2.0*3.141592))+1.0)/1.0)*512.0,0),0).x;
    uv = uv-vec2(0.5,0.5);
    
    if(distance(abs(uv.x)+abs(uv.y),0.4)<0.01) col = vec3(0.0);
    if(distance(abs(uv.x)+abs(uv.y),0.45)<0.005) col = vec3(0.0);
    if(distance(abs(uv.x)+abs(uv.y),0.35)<0.005) col = vec3(0.0);
    
    
        
    // Output to screen
    fragColor = vec4(col,1.0);
}
