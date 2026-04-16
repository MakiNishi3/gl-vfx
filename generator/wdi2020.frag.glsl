// #version 410 core

#define f float 
#define v2 vec2
#define v3 vec3

// #define R v2Resolution
// #define T fGlobalTime
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
#define BI(v) (0.05*T+0.02*texture(iChannel0, v2(v, 0.5)).x)
#define BS(v) (0.01*texture(iChannel0, v2(v, 0.5)).x)
#define B(v)  (0.01*texture(iChannel0, v2(v, 0.5)).x)

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

f gB = 10e8;

v3 colR = v3(1., 0, 0);
v3 colA = v3(0.2, 0.5, 1.4);
v3 colY = v3(1.0, 1.0, 0.0);

mat2 rot(f a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

f plas( vec2 v, float time )
{
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  vec4 p = vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
	return dot(p, p);
}

f box(v3 p, v3 b) {
  v3 q = abs(p) - b;
  f r = length( max(q, v3(0.))) + min( max(max(q.x, q.y), q.z), 0.);
  return r;
}

v3 cp;

f map(v3 p) {
    
  v3 p0 = p;
  p0.x = abs(p0.x);
  p0.x -= 4.0;
  f s = -p0.x + 0.05*plas(p.zy * 0.2 + 0.1*T, -1.+sin(T));
  
  p -= cp;
  p -= v3(0, 0, 14);
  s = min(s, length(p) -0.1 -200.0*BS(0.0));
  
  p0 -= v3(0, -1, 14.);
  p0.yz = mod(p0.yz + 4.0, 8.0) - 4.0;  
  s = min(s, box(p0, v3(100.0, 0.4, 1.0)));
  
  f sbl = box(p0, v3(0.01, 100.0, 0.01) - 0.01);
  gB = min(gB, sbl);
  s = min(s, sbl); 
  
  for (f i = 0.; i < 3.; ++i) {
    p -= v3(0.1, 0.2 + abs(sin(BS(0.0))), 0.5);
    p.xy *= rot(  10.0*BI(0.0) ); 
    p.yz *= rot( -20.0*BI(0.2) ); 
    p = abs(p);
  }
  
  f sl = box(p, v3(100.0, 0.01, 0.01));
  gB = min(gB, sl);
  s = min(s, sl);
  
  f bb = 0.1 +200.0*BS(0.0);
  s = min(s, 
        mix(length(p) -bb,
           box(p, v3(bb)),
           abs(sin(T))
      ));
    
  return s;
}

void mainImage( out vec4 out_color, in vec2 fragCoord )
{
    v2 q = (2. * F.xy - R.xy) / R.y;
  
  v3 c = v3(0);
  out_color = vec4(c, 1);
  if (abs(q.y) > 0.75) return;
  // v3 c = v3(q, 0);
  
  f pph = H(F.x + H(F.y + H(T)));
  
  v3 ro = v3( 2.0*sin(20.0*BI(0.0)), 2. + 10.0*B(0.0), 20.0*B(0.0));
  ro.y += sin(20.0*BI(0.0));
  ro.z += 15.0*T;
  cp = ro;
  v3 rd = N(v3(q, 2.));
  rd.xy *= rot (1.0 * sin(5.0*BI(0.0)) );
  
  f tt = 10e8;
  for (f bi = 0.; bi < 3.; ++bi) {
    f t = 0.1;
    for (f i = 0.; i < 64.; ++i) {
      f d = map(ro + rd * t);
      if ( t < 0.0001 || t > 40.) break;
      t += d;
    }    
    tt = bi == 0. ? t : tt;
    if (t > 0.2 && t < 40.) {
      v3 p = ro + rd * t;
      // c = fract(p);
      v2 e = 0.01 * v2(-1, 1);
      v3 n = N( e.xxx * map(p + e.xxx)
              + e.yxx * map(p + e.yxx)
              + e.xyx * map(p + e.xyx)
              + e.xxy * map(p + e.xxy));
      f str = smoothstep(0.5, 0.51, fract(p.y));      
      f str1 = smoothstep(0.5, 0.51, fract(0.13*p.y));      
      f str0 = smoothstep(0.5, 0.51, texture(iChannel1, 0.1*floor(10.*p.xy)).x);
      f str2 = smoothstep(0.98, 0.981, fract(0.01*p.z + 0.1*T));      
      // c = n;      
      c += 0.2*colR*(str+str1);
      c += colA*str2;
      
      rd = N(reflect(rd, n) + 0.01 * pph);
      ro = p;
    }
  }    
  // c  = v3(1. - t / 32.);  
  

  
  c = mix(c, 0.1*colR, 1.0 - exp(-0.005 * tt*tt));
  c = mix(c, 0.1*colR, 1.0 - exp(-0.0001 * tt*tt*tt));
  
  tt += pph;
  
  f sb = 0.2 + 20.0*BS(0.0);
  c += sb * colY * exp(gB * -20.0);
  c += sb * colY * exp(gB * -10.0);
  c += sb * colY * exp(gB *  -1.0);
  c += colA * 20.0*B(0.0);
	    
  c = c / (1. + c);
  c = smoothstep(-0.01, 0.9, c);
  c = pow(c, v3(0.4545));
  out_color = vec4(c, 1);
}