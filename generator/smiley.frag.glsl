float circle(vec2 px_pos, vec2 pos, float radius){
  return float(distance(px_pos, pos) < radius);
}
float ampAt(float pos){
  return texture(iChannel0, vec2(pos, 0.)).x;
}

void smiley( out vec4 fragColor, in vec2 fragCoord )
{
  float u_aspect = iResolution.x / iResolution.y;
  vec2 v_texcoord = fragCoord.xy / iResolution.xy;
  vec2 u_mouse = iMouse.xy / iResolution.xy;
  float u_time = iTime;

  vec2 pos = (v_texcoord * 2. - 1.) * vec2(u_aspect, 1.);

  float fade = 0.;
  fade += circle(pos, vec2(0., 0.), .7 + ampAt(.6) * .2);
  fade -= circle(pos, vec2(0., 0.), .5 + ampAt(.5) * .2);
  fade -= float(pos.y > 0.);
  fade = max(fade, circle(pos, vec2(-.5, .5), .1 + ampAt(.2) * .4));
  fade = max(fade, circle(pos, vec2(.5, .5),  .1 + ampAt(.4) * .4));

  fragColor = vec4(mix(
    vec3(0.),
    vec3(1., 1., 0.),
    fade
  ), 1.);
}
