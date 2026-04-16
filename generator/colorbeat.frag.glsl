void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy/2.0) / iResolution.yy;
    vec2 sp = fragCoord.xy / iResolution.xy;

    float beat = texture(iChannel0, vec2(0.1,0.25)).x;
    float time = iTime;
    
    vec2 rd = vec2(atan(uv.x,uv.y), length(uv));
    
    rd = vec2(rd.x+time*0.0, rd.y*(1.4-beat));
    

    float ljud = texture(iChannel0, vec2(rd.y*0.75, 0.25)).x;
  
    vec2 xygrid = 1.0-clamp(abs(sin(vec2(sin(rd.x),cos(rd.x))*rd.y*3.14159*10.0))*4.0, 0.0,1.0);
    vec2 rdgrid = 1.0-clamp(abs(sin(rd*vec2(0.5,1.0)*16.0))*16.0*min(1.0,rd.y), 0.0,1.0);
    
	fragColor.xyz = vec3(1.0-step(ljud, abs(cos(rd.x)*rd.y)))*ljud*ljud*8.0;
    


	fragColor.x += rdgrid.x+rdgrid.y;
    fragColor.y += xygrid.x+xygrid.y;
    
    
    vec2 srd = vec2(ivec2(sin(rd.x*(1.0+float(int(mod(iTime*3.0,4.0)))))*3.14159*1.0+iTime*4.0));
    fragColor.xyz += vec3(sin(srd.x),cos(srd.x),-sin(srd.x));
    fragColor.a = 0.0;
}