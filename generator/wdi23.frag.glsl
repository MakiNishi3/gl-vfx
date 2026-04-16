// #version 410 core

#define f float
#define v2 vec2
#define v3 vec3

#define N normalize
#define H(v) fract(sin(100.*v)*435758.5354)
#define T iTime

// fake beat accumulation workaround
#define BI (0.005*T+0.004*texture(iChannel0, v2(0.0, 0.5)).x)
#define BS (0.002*texture(iChannel0, v2(0.0, 0.5)).x)
#define BB (0.001*texture(iChannel0, v2(0.0, 0.5)).x)


f gG = 10e8;
f gG1 = 10e8;

v3 cA = v3(0.2, 0.6, 1.2);

/*
uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything
*/


f plas( vec2 v, float time ) {
	float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
	vec4 d = vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
  return dot(d.xyz, d.xyz);
}

mat2 rot(f a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

f box(v3 p, v3 b) {
  v3 q = abs(p) -b;
  return length( max(q, v3(0.))) + min(  max(max(q.x, q.y),q.z), 0. );
}

f map(v3 p) {
  f s = p.y +0.5 +0.3*plas(p.xz, T) +0.1*plas(0.05*p.xz, T);
  p.z -= 12. + 2.*sin(100.*BI);
  p.y -= 200.*BS;
  
  for (f b = 0.; b < 3.; ++b) {   
    v3 p2 = p;
    p2.y += 80.*BS ;
    p2.zy *= rot(20.*T*H(b));
    p2.x -= 0.1*H(b);
    f s4 = length(p2) -0.2 -170.*BS;
    s = min(s, s4);
    gG = min(gG, s4);
  }
  
  v3 p1 = p;
  p1.z += 20.*BI + 10.*T;
  p1.x = abs(p1.x);
  p1.x -= 1.9;
  p1.z = mod(p1.z + 1.0, 2.) - 1.0;
  p1.xy *= rot(0.7);
  s = min(s, box(p1, v3(0.3, 5., 0.3)));

 for (f b = 0.; b < 5.; ++b) {   
    p = abs(p);
    p -= v3(.9, 0.1, 1.4);
    p.yz *= rot(40.*BI);
    p.xy *= rot(T);
    f s3 = length(p) -0.01 -50.*BB -0.01*b;
   f  s1 = box(p, v3( 0.01 +50.*BS, 15.*BS, 25.*BS )) ;
    f s2 = box(p, v3(0.001, 10., 0.005));
    gG1 = min(gG1, s2);
    if (b > 3.) {
      gG = min(gG, s1);
    }
    s = min( s, s3 );
    s = min( s, s2 );
    s = min( s, s1 );
  }
  
  // s = max(-s4, s-0.2);
  
  return s;
}

// void main(void) {
void mainImage( out vec4 out_color, in vec2 fragCoord ) {
	vec2 uv = gl_FragCoord.xy/iResolution.xy;
	uv -= 0.5;
	uv /= vec2(iResolution.y / iResolution.x, 1);

  v3 col = v3(0.);
  out_color.xyz = col;
  
  if (abs(uv.y) > 0.4) return;
  
  v3 ro = v3(0.2*sin(20.*BI + T), 0., 0.);  
  v3 rd = N(v3(uv, 4.));
  rd.xy *= rot(0.2*cos(20.*BI + T));
  
  
  f t = 0.;
  f tt = 10e8;
  v3 tint = v3(1.);
  
  for (f bi = 0.; bi < 3.; ++bi) {
    for (f i = 0.; i<64.; ++i) {
        t += map(ro+rd*t);
        if (t < 0.001 || t> 40.) break;      
    }
    tt = bi == 0. ? t : tt; 
    v3 p = ro+rd*t;
    v2 e = 0.001*v2(-1., 1.);
    v3 n = N(
        e.xxx * map(p + e.xxx)
      + e.yxx * map(p + e.yxx)
      + e.xyx * map(p + e.xyx)
      + e.xxy * map(p + e.xxy)
    );
    
    f fre = pow(dot(rd, n) + 1., 6.);
    col += 0.1*cA*fre;
    tint *= fre;
    
    rd = N(reflect(rd, n) + 0.1*H(p));
    ro = p + 0.1*rd;
    
  }
  // v3 p = ro+rd*t;
  // col = fract(p);
  col = mix(1.2*cA.zyx, 0.2*col, exp(-0.005 * tt*tt));  
  
  f sb = .1 + 40.*BS;
  col += sb * cA * exp(-50. * gG);
  col += sb * cA * exp(-1.  * gG);
  
  sb *= 2.;
  col += sb * cA.yxz * exp(-50. * gG1);
  col += sb * cA.yxz * exp(-10. * gG1);
  col += sb * cA.yxz * exp(-5.  * gG1);
  col += sb * cA.yxz * exp(-1.  * gG1);
  
  col += 50.*BB;
  
  out_color.xyz = col;
 
  /*
	vec2 m;
	m.x = atan(uv.x / uv.y) / 3.14;
	m.y = 1 / length(uv) * .2;
	float d = m.y;

	float f = texture( texFFT, d ).r * 100;
	m.x += sin( fGlobalTime ) * 0.1;
	m.y += fGlobalTime * 0.25;

	vec4 t = plas( m * 3.14, fGlobalTime ) / d;
	t = clamp( t, 0.0, 1.0 );
	out_color = f + t;
  */
}
