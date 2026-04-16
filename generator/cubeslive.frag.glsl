// This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0
// Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ 
// or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
// =========================================================================================================

float _time;
#define FFT(a) pow(sat(texture(iChannel0, vec2(a,0.)).x*100.),1.)

#define sat(a) clamp(a, 0., 1.)
mat2 r2d(float a) { float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
float _cube(vec3 p, vec3 s)
{
  s.xz -= (sin(p.y*20.)*.2+.8)*.05;
  vec3 l = abs(p)-s;
  return max(l.x, max(l.y, l.z));
}

vec2 _min(vec2 a, vec2 b)
{
  if (a.x < b.x)
    return a;
  return b;
}

vec3 getCam(vec3 rd, vec2 uv)
{
  vec3 r = normalize(cross(rd, vec3(0.,1.,0.)));
  vec3 defr = r;
  defr.xy *= r2d(uv.y*10.);
  r = mix(r, defr, sin(_time));
  vec3 u = normalize(cross(rd, r));
  return normalize(rd+(r*uv.x+u*uv.y)*(asin(sin(_time))*.2+.8));
}
vec2 map(vec3 p)
{
  p.y = -abs(p.y);
  vec3 vp = p;
  vec2 acc = vec2(1000.,-1.);
  
  float rep = 0.4;
  float w = .1;
  //p.y = texture(tex
  p.xz *= r2d(sin(p.y+_time)*.2);
  vec2 idx = floor((p.xz+rep*.5)/rep);
  p.xz = mod(p.xz+rep*.5,rep)-rep*.5;
  float cubes = _cube(p, vec3(w, 1.+FFT(length(idx)*.2), w));
  
  float repv = .3*length(idx);
  vp.y = mod(vp.y+repv*.5-_time*length(idx)*.15,repv)-repv*.5;
  cubes = max(cubes, _cube(vp, vec3(10.,.1,10.)));
  
  acc = _min(acc, vec2(cubes, floor(length(idx)+_time)));
  
  //acc = _min(acc, vec2(-p.y, 0.));
  
  
  
  return acc;
}
vec3 getNorm(vec3 p, float d)
{
  vec2 e = vec2(0.01,0.);
  return normalize(vec3(d)-vec3(map(p-e.xyy).x, map(p-e.yxy).x, map(p-e.yyx).x));
  return normalize(cross(dFdx(p), dFdy(p)));
}


float accAO;
vec3 accCol2;
vec3 trace(vec3 ro, vec3 rd, int steps)
{
  accAO = 0.;
  accCol2 = vec3(0.);
  vec3 p = ro;
  for (int i = 0; i < steps; ++i)
  {
    vec2 res = map(p);
    if (res.x < 0.01)
      return vec3(res.x, distance(p, ro), res.y);
    accAO += sat(res.x/0.01)*.002;
    accCol2 += vec3(sin(p.x+_time*10.)*.2+.5,.2,.5)*pow(sat(res.x/.05),1.)*.01;
    p+=rd*res.x*.15;
  }
  return vec3(-1.);
}

vec3 rdr(vec2 uv)
{
  vec3 col = vec3(0.);
 
  float dist = 5.;
  vec3 ro = vec3(sin(_time*.33)*dist,-5.*sin(_time*.1),cos(_time*.25)*dist);
  vec3 ta = vec3(0.,0.,0.);
  vec3 rd = normalize(ta-ro);
  
  rd = getCam(rd, uv);
  vec3 res = trace(ro, rd, 512);
  if (res.y > 0.)
  {
    vec3 p = ro +rd*res.y;
    vec3 n = getNorm(p, res.x);
    col = n*.5+.5;
    float fade = 1.;//(1.-sat((length(p.xz)-sin(_time+length(p.xz)))*1.));
    vec3 ldir = normalize(vec3(1.,1.,1.));
    col = vec3(1.)*pow(sat(-dot(n, normalize(ldir+rd))),.8)
    +vec3(.3,.25,.25);
    col *= fade;
    col = 1.-col;
    float ffti = _time;//texture(texFFTIntegrated, length(p.xz)*.1+_time).x*0.1;
    if (dot(n, vec3(0.,1.,0.)) < -0.5 && p.y < -0.1)
      col = vec3(sin(res.z)*.5+.5, .3, sin(res.z*10.)*.2+.8)*sat(sin(length(p.xz)*5.-_time*10.))*1.5;
    col *= 1.-accAO;
    col += accCol2;
  }
  
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy -.5*iResolution.xy)/iResolution.xx;
  _time = iTime+texture(iChannel1, fragCoord.xy/8.).x*1.*sat(length(uv));
  //uv *= r2d(texture(texFFTIntegrated, 1.).x*.25);
  vec3 col = rdr(uv);
  col.xy *= r2d(_time);
  col.xy = .2+.8*abs(col.xy);
  fragColor = vec4(col, 1.);
}