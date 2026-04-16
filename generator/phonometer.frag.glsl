//TDF2021 ShaderShowDown q-f : gyabo
//Ports to ShaderToy. original as follows,
//https://gist.github.com/kumaashi/eee4971857e6dd7a541d8dc455ebf2eb
//https://twitter.com/gyabo/status/1469569058811293696
#define time iTime
#define v2Resolution iResolution
#define gl_FragCoord fragCoord
#define texFFTSmoothed iChannel0
#define fragColor out_color

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

vec4 getf(vec2 uv) {
  uv = abs(uv * 0.15);
  //float m0 = texture(texFFTSmoothed, uv.x).x * 5.0; //Bonzomatic
  //float m1 = texture(texFFTSmoothed, uv.y).x * 5.0;  //Bonzomatic
  float m0 = texture(texFFTSmoothed, uv.xy * 2.0).x * 0.5;
  float m1 = texture(texFFTSmoothed, uv.yx * 2.0).x * 0.5;
  return vec4(
  m0 * m1,
  m0 - m1,
  m0 + m1, 1.0) * 2.0;
}

float box(vec3 p, vec3 s) {
  p = abs(p) - s;
  return max(p.x, max(p.y, p.z));
}

vec2 rot(vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  return vec2(
  p.x * c - p.y * s,
  p.x * s + p.y * c);
}

float map(vec3 p) {
  float t = length(mod(p, 2.0) - 1.0) - 0.45;
  float h = length(getf(mod(p.xz * 0.2, 1.0)).xyz) * 0.5;
  t = min(t, (h + 1.0) - dot(abs(p), vec3(0, 1, 0)));
  t = min(t, length(mod(p.xz, 2.0) - 1.0) - 0.1);
  t = min(t, length(mod(p.zy, 2.0) - 1.0) - 0.1);
  t = min(t, length(mod(p.xy, 2.0) - 1.0) - 0.1);
  vec3 ap = p;
  float bd = box(mod(ap, 2.0) - 1.0, vec3(0.4));
  t = max(-bd, t);
 
  return t;
}

vec3 getnor(vec3 p) {
  float t = map(p);
  vec2 d = vec2(0.001, 0.0);
  return normalize(vec3(
    t - map(p + d.xyy),
    t - map(p + d.yxy),
    t - map(p + d.yyx)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  vec2 auv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  auv = auv * 2.0 - 1.0;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  vec3 dir = normalize(vec3(uv, 1.0));
  dir.xz = rot(dir.xz, time * 0.01);
  //dir.zy = rot(dir.zy, time * 0.03);
  
  vec3 pos = vec3(0, 0, time);
  float t = 0.0;
  for(int i = 0 ; i < 100; i++) {
    t += map(pos + dir * t) * 0.75;
  }

  vec3 ip = pos + dir * t;  
  vec3 N = normalize(getnor(ip));
  vec3 V = normalize(ip);
  vec3 L = normalize(vec3(1,2,3));
  vec3 H = normalize(N + V);
  float D = max(0.0, dot(N, L));
  float S = max(0.0, pow(dot(H, N), 64.0));
 
  vec3 fog = vec3(2,2,3) * t * 0.02;
  float vvvv = 1.0 - dot(auv * 0.4, auv);
  out_color = vec4(map(ip + 0.5));
  out_color *= D;
  out_color *= S;
  out_color.xyz += fog;
  out_color += getf(uv) * 0.5;
  out_color *= vvvv;
}
