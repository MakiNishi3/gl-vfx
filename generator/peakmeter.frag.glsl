vec4 over( in vec4 a, in vec4 b ) {
    return mix(a, b, 1.-a.w);
}

// https://www.shadertoy.com/view/MslGR8
vec3 dither(vec2 vScreenPos){
    vec3 vDither = vec3( dot( vec2( 171.0, 231.0 ), vScreenPos.xy ) );
    vDither.rgb = fract( vDither.rgb / vec3( 103.0, 71.0, 97.0 ) );
    return vDither.rgb / 255.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = (fragCoord-iResolution.xy*.5)/iResolution.y*8.;
    vec3 dith = dither(fragCoord);
    uv.y -= .5;
    vec2 id = floor(uv) + vec2(4., 1.);
	vec4 col = vec4(vec3(.1+uv.y*.008+dith*3.), 0.);
    uv = fract(uv)*2.-1.;
    float r = .75;
    float g = uv.y*uv.y*uv.y/-r;
	float a = step(0., id.y) * step(id.y, 0.) * step(0., id.x) * step(id.x, 7.);
    
    vec3 color = mix(vec3(.72, .78, .46), 
                     mix(vec3(.90, .74, .32),
                         vec3(.78, .14, .12),
                         step(7., id.x)), step(6., id.x));
    float fft  = (
        texture(iChannel0, vec2(.0,.25)).x +
        texture(iChannel0, vec2(.3,.25)).x +
        texture(iChannel0, vec2(.6,.25)).x +
        texture(iChannel0, vec2(.9,.25)).x
    );
    float amount = pow(fft*.43, 2.);

    // bottom
    col = over(vec4(vec3(.1+g*.08),smoothstep(.1,.0,length(uv)-r))*a,col);
    
    // plastic color
    col = over(vec4(color*.4+max(.0,g*.2)+max(.0,-g*.2), smoothstep(.03,.0,length(uv)-r*.8))*a,col);
    
    // active light
    col = over(vec4(color*1.1, smoothstep(.7, .0, length(uv)-r*.2))*smoothstep(amount*8., amount*6., id.x)*a, col);
    
    // high-light
    col = over(vec4(vec3(.75),smoothstep(.1,.0, distance(uv,vec2(.0,.4*r))-.02*r))*a,col);

    fragColor = col;
}