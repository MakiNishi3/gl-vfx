// #version 410 core

#define f float 
#define v2 vec2
#define v3 vec3

#define v2Resolution iResolution
#define fGlobalTime iTime
#define F gl_FragCoord
#define R iResolution
#define T iTime

#define C(v) clamp(v, 0., 1.)
#define N normalize
#define H(v) fract(sin(100.0*v) * 43758.5453)

// #define BI(v) (texture(texFFTIntegrated, v).x)
// #define BS(v) (texture(texFFTSmoothed, v).x)
// #define B(v) (texture(texFFT, v).x)
// fake beat accumulation, next time I will save it in buffer
#define B2(v) (0.05*T+0.005*texture(iChannel0, v2(v, 0.5)).x)
#define B1(v) (0.005*texture(iChannel0, v2(v, 0.5)).x)
#define B0(v)  (0.005*texture(iChannel0, v2(v, 0.5)).x)

#define texNoise iChannel1

// uniform float fGlobalTime; // in seconds
// uniform vec2 v2Resolution; // viewport resolution (in pixels)

v3 colA = v3(0.2, 0.5, 1.2);
v3 cP = v3(0.);

f gG = 10e8;

mat2 rot(f a) {return mat2(cos(a), -sin(a), sin(a), cos(a)); }

vec4 plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

f map(v3 p) {
  f s = 10e8;
  s = -abs(p.y) + 1.5;
  
  v3 p2 = p;
  p2.x = abs(p2.x) - 2.0;
  p2.z = mod(p2.z + 5.0, 10.0) - 5.0;
  p2.y = mod(p2.z +  .01, 0.02) - 0.01;
  s = min(s, length(p2) - 0.5);
  p2.x -= 2.;
  s = min(s, length(p2) - 0.5);
  
  v3 p3 = p;
  p3.y -= 0.5;
  p3.z -= 8.0;
  p3.z = mod(p3.z + .01, .02) - .01;
  p3.y += 0.5 + .5*sin(0.3*p.z);
  p3.x += 1.5*sin(0.1*p.z);  
  f s5 = min(s, length(p3) - 0.05);
  p3.z -= 10.0*B0(0);
  s5 = min(s5, length(p3) - 0.05);
  p3.x -= 10.0*B0(0.1);
  s5 = min(s5, length(p3) - 0.1);
  p3.x -= 10.0*B0(0.2);
  s5 = min(s5, length(p3) - 0.1);
  gG = min(gG, s5);  
  s = min(s, s5);  
  
  v3 p1 = p - cP;
  p1.y += 100.0*B1(0.0);
  p1.z -= 10.0 + 5.0*sin(10.0*B2(0));
  
  f s3 = 10e8;
  for (f i = 0.; i < 4.; ++i) {
    p1 -= v3(0.1, 0.3, 0.5);   
    p1.xz *= rot(10. * B2(0.));
    p1.zy *= rot(-9. * B2(0.));
    p1.xy *= rot(50. * B1(0.));
    // p1.zy *= rot(0.5 * B2(0.) );
    p1 = abs(p1);
    p1 *= 0.9;
    f s4 = length(p1) -0.1 -5.0*B0(0.);
    vec3 p4 = p1;
    if (i < 2. + B1(0.)) {
      p4.y = mod(p4.y +  .01, 0.02) - 0.01;
      f s2 = length(p4) -0.05 -1.0*B0(0.);
      s3 = min(s3, s2);
      s3 = min(s3, s4);
    }      
  }
  gG = min(gG, s3);  
  s = min(s, s3);
  return s;
}

void mainImage( out vec4 out_color, in vec2 fragCoord )
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  
  out_color = vec4(0);  
  if (abs(uv.y) > 0.35) return;
  
  vec3 ro = vec3(0, 0, 0);
  ro.x += sin(20.0*B2(0.));
  ro.y += 0.1*sin(20.0*B2(0.));
  ro.z += 20.0*T;
  cP = ro;
  vec3 rd = N(vec3(uv, 2.));
  rd.xy *= rot(0.5*sin(0.5* T));
  v3 c = v3(0.0);
  
  f t = 0.1;
  for (f i = 0.; i < 128.; ++i) {
    f d = map(ro + rd * t);
    if (abs(d) < 0.001 || t > 40.0) break;
    t += d;
  }
  
  if (t > 0.2 || t < 40.) {
    v3 p = ro + rd  * t;    
    f tex0 = texture(texNoise, floor(20.0*( vec2(1.0, 0.05) * p.xz + vec2(0, 1) * T))/20.0).x;
    f tex1 = texture(texNoise, floor(20.0*( vec2(0.5, 0.005) * p.xz + vec2(0, 0.5) * T))/20.0).x;
    c += 0.25 * colA.xyz * smoothstep(0.2, 0.7, tex0);
    c += 0.25 * colA.xyz * smoothstep(0.2, 0.7, tex1);
    
    c += 0.1 * colA.xzy * smoothstep(0.0, 1., sin(p.z + 10.*T));
    c += 0.5 * colA.xzy * smoothstep(0.9, 1., sin(0.5*p.z + 10.*T));
    c += 0.5 * colA.xzy * smoothstep(0.5, 1., sin(0.5*p.z + 10.*T)) * sin(p.z + sin(100.0*p.x) + 10.*T);
  }
  
  c = mix(c, 0.1*colA.yzx, 1.0 - exp(-0.005 * t*t));
  
  v3 colB = v3(1., 0.5, 0.5);
  f sb = 0.01 + 20.0*B1(0.);
  c += sb * colB.xyz * exp(gG * - 0.01);
  c += sb * colB.xyz * exp(gG * - 0.1);
  c += sb * colB.xyz * exp(gG * - 1.0);
  c += sb * colB.xyz * exp(gG * - 5.0);
  c += sb * colB.xyz * exp(gG * - 10.0);
  
  c += 10.0*B0(0);
  
  // c = v3(1) * (t/64.);
  c = C(c / (c + 1.));  
  c = pow(c, v3(1. -50.0*B1(0.), 1. -50.0*B1(0.25), 1. -50.0*B1(0.5)));
  c = smoothstep(0., .6, c);
  c = pow(c, v3(0.4545));
  out_color = vec4(c, 1);  
	// out_color = vec4(rd, 1);
}