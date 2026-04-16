{
  float u_aspect = iResolution.x / iResolution.y;
  vec2 v_texcoord = fragCoord.xy / iResolution.xy;
  vec2 u_mouse = iMouse.xy / iResolution.xy;
  float u_time = iTime;

  vec2 center = vec2(.5, .5); 
  vec2 pos = vec2(v_texcoord.x*u_aspect, v_texcoord.y);
  pos.x+=-1.0;
  vec2 scaledMouse = vec2(u_mouse.x*u_aspect, u_mouse.y);

  float freq = texture(iChannel0, v_texcoord).x;

  float d = distance(pos, center);  
  d*=1.3*abs(sin(.5));
  d = 1.-d;

  vec3 vignette = vec3(d,d,d);

  float scalar = 10.0*texture(iChannel0, vec2(0,0)).x;; 
  float scalar2 = 10.0*texture(iChannel0, vec2(.1,0)).x;; 
  float scalar3 = 10.0*texture(iChannel0, vec2(.2,0)).x;; 
  float scalar4 = 10.0*texture(iChannel0, vec2(.3,0)).x;; 
  float scalar5 = 10.0*texture(iChannel0, vec2(.4,0)).x;; 
  float scalar6 = 10.0*texture(iChannel0, vec2(.5,0)).x;; 
  float scalar7 = 10.0*texture(iChannel0, vec2(.6,0)).x;; 
  float scalar8 = 10.0*texture(iChannel0, vec2(.7,0)).x;; 
  float scalar9 = 10.0*texture(iChannel0, vec2(.8,0)).x;; 
  float scalar10 = 10.0*texture(iChannel0, vec2(.9,0)).x;; 
  float scalar11 = 10.0*texture(iChannel0, vec2(1.0,0)).x;; 

  vec2 s = vec2(sin(scalar*pos.x+sin(u_time+scalar2)),cos(scalar*pos.y+cos(u_time+scalar3)));
  float amp = distance(s,vec2(0.,0.));

  fragColor = vec4(vignette/amp, 1.0); 
}