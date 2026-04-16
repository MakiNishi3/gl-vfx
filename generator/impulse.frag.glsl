// CC0: Impulse 2023!
// Silliness on sunday morning. 
// Music by Lotek Style, hope he doesn't mind I put his music to this silliness

// If you struggle getting the music to play the reason is often that the browser 
// refuse to play unless you interacted with the controls. 
// So usually pausing and rewinding tend to unlock the music.

#define THAT_CRT_FEELING

#define PI  3.141592654
#define TAU (2.0*PI)

// Font rendering macros (ASCII codes)
#define _SPACE 32
#define _EXCLAMATION 33
#define _COMMA 44
#define _DASH 45
#define _PERIOD 46
#define _SLASH 47
#define _COLON 58
#define _AT 64
#define _A 65
#define _B 66
#define _C 67
#define _D 68
#define _E 69
#define _F 70
#define _G 71
#define _H 72
#define _I 73
#define _J 74
#define _K 75
#define _L 76
#define _M 77
#define _N 78
#define _O 79
#define _P 80
#define _Q 81
#define _R 82
#define _S 83
#define _T 84
#define _U 85
#define _V 86
#define _W 87
#define _X 88
#define _Y 89
#define _Z 90

#define _a 97
#define _b 98
#define _c 99
#define _d 100
#define _e 101
#define _f 102
#define _g 103
#define _h 104
#define _i 105
#define _j 106
#define _k 107
#define _l 108
#define _m 109
#define _n 110
#define _o 111
#define _p 112
#define _q 113
#define _r 114
#define _s 115
#define _t 116
#define _u 117
#define _v 118
#define _w 119
#define _x 120
#define _y 121
#define _z 122

#define _0 48
#define _1 49
#define _2 50
#define _3 51
#define _4 52
#define _5 53
#define _6 54
#define _7 55
#define _8 56
#define _9 57

const int numLetters = 13;
const int letterArray[numLetters] = int[](
  _I,_M,_P,_U,_L,_S,_E,_EXCLAMATION,_SPACE,_2,_0,_2,_3
);


#define TIME        iTime
#define RESOLUTION  iResolution

// License: MIT OR CC-BY-NC-4.0, author: mercury, found: https://mercury.sexy/hg_sdf/
vec2 mod2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size*0.5)/size);
  p = mod(p + size*0.5,size) - size*0.5;
  return c;
}

// License: MIT, author: Inigo Quilez, found: https://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm
float box(vec2 p, vec2 b) {
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

vec4 atariBee(vec2 p, float aa, float csz, vec3 bgCol, vec3 fgCol) {
  const int[] rows = int[16](
    0x00007c3e
  , 0x282c7f7f
  , 0x6a52ffff
  , 0x1b22ffff
  , 0x7b02ffff
  , 0x0686ffff
  , 0x3fcc7fff
  , 0x1ab87ffe
  , 0x07603ffc
  , 0x2ad87ffc
  , 0x5198ffff
  , 0x2163ffff
  , 0x4360fff7
  , 0x4600fff8
  , 0x3c10ff38
  , 0x00107e38
  );

  vec2 cp = p;
  float r  = 0.125*csz; 
  vec2 cn = mod2(cp, vec2(csz));
  cn += 7.0;
  
  
  if (cn.x < 0.0 || cn.x > 15.0) {
    return vec4(0.0);
  }
  
  if (cn.y < 0.0 || cn.y > 15.0) {
    return vec4(0.0);
  }

  float d = box(cp, vec2(0.5*csz-r))-r;
  // Praying bit tests aren't _too_ bad performance wise.
  int row = rows[int(cn.y)];
  bool bg = (row & (1 << int(cn.x))) != 0;
  if (!bg) {
    return vec4(0.0);
  }
  vec3 col = bgCol;
  bool fg = (row & (1 << (int(cn.x)+16))) != 0;
  if (fg) {
    col = fgCol;
  }
  float t = smoothstep(aa, -aa, d);
  return vec4(col, t);
}

vec4 atariBomb(vec2 p, float aa, float csz, vec3 bgCol, vec3 fgCol) {
  const int[] rows = int[16](
    0x03800380
  , 0x0fe00fe0
  , 0x1df01ff0
  , 0x3bf83ff8
  , 0x3bf83ff8
  , 0x7ffc7ffc
  , 0x7ffc7ffc
  , 0x3fb83ff8
  , 0x3ff83ff8
  , 0x1ff01ff0
  , 0x07c007c0
  , 0x07c407c4
  , 0x01090109
  , 0x00800080
  , 0x004a004a
  , 0x00300030
  );

  vec2 cp = p;
  float r  = 0.125*csz; 
  vec2 cn = mod2(cp, vec2(csz));
  cn += 7.0;
  
  
  if (cn.x < 0.0 || cn.x > 15.0) {
    return vec4(0.0);
  }
  
  if (cn.y < 0.0 || cn.y > 15.0) {
    return vec4(0.0);
  }

  float d = box(cp, vec2(0.5*csz-r))-r;
  // Praying bit tests aren't _too_ bad performance wise.
  int row = rows[int(cn.y)];
  bool bg = (row & (1 << int(cn.x))) != 0;
  if (!bg) {
    return vec4(0.0);
  }
  vec3 col = bgCol;
  bool fg = (row & (1 << (int(cn.x)+16))) != 0;
  if (fg) {
    col = fgCol;
  }

  float t = smoothstep(aa, -aa, d);
  return vec4(col, t);
}

vec4 text(in vec2 uv, int start, int count, bool repeat) {
  float fl = floor(uv + 0.5).x;
  float cursorPos = fl;
  int arrayPos = int(cursorPos);
  if (arrayPos < 0)
  {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }
  if (!repeat && arrayPos >= count)
  {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }

  arrayPos %= count;
  arrayPos += start;

  int letter = letterArray[arrayPos];
  vec2 lp = vec2(letter % 16, 15 - letter/16);
  vec2 uvl = lp + fract(uv+0.5)-0.5;

  // Sample the font texture. Make sure to not use mipmaps.
  // Add a small amount to the distance field to prevent a strange bug on some gpus. Slightly mysterious. :(
  vec2 tp = (uvl+0.5)*(1.0/16.0);
  return texture(iChannel1, tp, -100.0) + vec4(0.0, 0.0, 0.0, 0.000000001);
}

vec3 competitionWinnerEffect(vec3 col, vec2 p, float tm) {
  vec2 tp = p;
  tp.x += sin(p.y+tm);
  tp.y += sin(tm)*sin(p.x+sqrt(0.5)*tm);
  tp *= 3.0;
  tp.x -= -float(numLetters)*0.5;
  tp.y += 0.4*tm;
  if (tp.y < 0.5+18.0) {
    return col;
  }
  vec4 tcol = text(tp, 0, numLetters, false);
  
  vec3 ecol = vec3(0.0);
  vec3 fcol = vec3(1.0);

  float ry = p.y-tm;
  fcol = (1.0+cos(2.0*vec3(0.0, 1.0, 2.0)+ry));
  fcol = floor(fcol*16.0)/16.0;
  fcol = step(tcol.w, 0.5)*fcol;
  float t = step(tcol.w, 0.55);
  
  return mix(col, fcol, t);;
}

vec3 background(vec2 p, vec2 q, float sz) {
  const vec3 atariBg = vec3(148.0, 236.0, 70.0)/255.0;
  vec3 col = atariBg;
  if (1.0-q.y < sz*8.0 ) {
    col = vec3(0.0);
  }
  if (1.0-q.y < sz*7.0 ) {
    vec2 tp =p;
    tp *= 8.0;
    tp.x += float(numLetters)*0.5;
    tp.y += 0.5;
    vec4 tcol = text(tp, 0, numLetters, false);
    col = step(0.52,tcol.w)*vec3(1.0);
  }
  return col;
}

vec3 bombsAway(vec3 col, vec2 p, float sz, float r, float aa) {
  vec2 bp = p;
  bp.x -= -1.0*r+8.0*sz;
  bp.y += -1.0+8.0*sz;
  vec2 bn = mod2(bp, vec2(16.0*sz));

  float bombs = texture(iChannel0, vec2(clamp((0.0125*(1.0-bn.y)), 0.0, 1.0), 0.25)).x;
  bombs -= 0.2;
  bombs = max(bombs, 0.0);
  bombs *= bombs;
  bombs *= 20.0;

  if (bn.x > bombs || bn.y > -1.0) {
    return col;
  }

  col = vec3(1.0);
  vec4 bcol = atariBomb(bp, aa, sz, vec3(1.0), vec3(0.0));
  return mix(col, bcol.xyz, bcol.w);
}

vec3 busyBee(vec3 col, vec2 p, vec2 m, float aa, float sz) {
  vec2 ap = p;
  if (iMouse.z != 0.0) {
    ap -= m;
  }

  vec4 acol = atariBee(ap, aa, sz, vec3(1.0), vec3(0.0));
  return mix(col, acol.xyz, acol.w);
}

vec3 beatingNik(vec3 col, vec2 p, float aa, float sz, float tm) {
  sz *= 4.0;

  float ry = 1.0*p.y+tm;
  vec3 fcol = (1.0+cos(1.6*vec3(0.0, 1.0, 2.0).yzx+ry));
  fcol = floor(fcol*16.0)/16.0;
  fcol = mix(vec3(1.0), fcol, smoothstep(54.0, 56.0, tm));
  p.y += 3.0*smoothstep(15.0, 9.0, tm);
//  p *= 1.0-0.5*length(p-sin(1.133*TAU*vec2(1.0, sqrt(0.5))*(tm)));
  for (float i = 0.0; i < 10.0; ++i) {
    vec2 bp = p;
    bp += sin(0.33*TAU*vec2(1.0, sqrt(0.5))*(tm+0.25*i));
    vec4 bcol = atariBee(bp, aa, sz, fcol, vec3(0.0));
    col = mix(col, bcol.xyz, bcol.w);
  }
  return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 q = fragCoord/RESOLUTION.xy;
  vec2 p = -1. + 2. * q;
  vec2 pp = p;
  vec2 m = -1. + 2. * (iMouse.xy)/RESOLUTION.xy;
  float r = RESOLUTION.x/RESOLUTION.y;
  p.x *= r;
  m.x *= r;
  float tm = mod(TIME, 4.0*60.0+11.0);
//  tm += 10.0;
  float aa = 2.0/RESOLUTION.y;
  const float dsz = 0.01;
  float sz = aa*floor(dsz/aa);

  vec3 col = background(p, q, sz);
  col = bombsAway(col, p, sz, r, aa);
  col = beatingNik(col, p, aa, sz, tm);
  col = competitionWinnerEffect(col, p, tm);
  col = busyBee(col, p, m, aa, sz);
  col = clamp(col, 0.0, 1.0);
#ifdef THAT_CRT_FEELING
  col *= 1.1*smoothstep(2.1, 0.75, length(pp));
  col *= mix(vec3(0.71), vec3(1.0),smoothstep(-0.9, 0.9, sin(TAU*p.y/sz+TAU*vec3(0.0, 1., 2.0)/3.0)));
#endif

  fragColor = vec4(col, 1.0);
}
