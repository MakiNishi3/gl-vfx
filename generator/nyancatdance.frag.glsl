vec4 WoodShader(vec4 col,vec2 uv){
    return vec4((texture(iChannel3,uv).rgb+col.rgb)/2.,col.a);
}

vec4 renderAnimation(vec2 uv){
    vec2 ruv=uv;
    float s;
    int tick = int(iTime*8.);
    tick%=6;
    
    ruv.x/=6.;
    ruv.x+=float(tick)*(40.0 / 256.);
    
    return WoodShader(texture(iChannel1,ruv),ruv); 
}

vec4 renderNaynBass(vec2 uv,float bass){
    vec2 fir = vec2(0.5) - (bass/4.) ;
    vec2 sec = vec2(0.5) + (bass/4.) ;
    if(fir.x<=uv.x)if(fir.y<=uv.y)if(uv.x<=sec.x)if(uv.y<=sec.y){
    return renderAnimation((uv-fir)*(2./bass));
    }
    return vec4(0);
}

vec3 SpaceShader(vec3 color,float bass){
    float bright=color.x*color.y*color.z;
    if(bright<bass)return vec3(0);
    return vec3(bright);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 sound = texture(iChannel0,vec2(0)).xy;
    float bass = (sound.x+sound.y)/2.;
    fragColor=vec4(0);
    fragColor=renderNaynBass(uv,bass*3.+0.5);
    if(fragColor.a<0.5){
        fragColor.rgb=SpaceShader(texture(iChannel2,fract(uv+vec2(iTime/2.,0.))).rgb,bass);
    }
    if(uv.y<texture(iChannel0,vec2(uv.x)).x/5.)fragColor.rgb=vec3(bass,0.,0);
}