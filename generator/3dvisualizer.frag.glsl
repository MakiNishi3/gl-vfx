
//---------------------------------------------------------
// Shader:   3d visualizer.glsl                      5/2015
//           a try to visualize sound data in 3d...    
//---------------------------------------------------------

//---------------------------------------------------------
#define ANIMATE true
#define ROTATE true
#define flag true

float time = 0.0;
float aTime = 0.0;
float sinTime = 0.0;
vec2 uv;
vec2 mouse;
//---------------------------------------------------------
vec3 rotateY(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(ca * p.x + sa * p.z, p.y, -sa * p.x + ca * p.z);
}

//---------------------------------------------------------
float length6( vec2 p )  // (x^6+y^6)^(1/6)
{
  p = p*p*p; 
  p = p*p;
  return pow( p.x + p.y, 1.0/6.0 );
}
//---------------------------------------------------------
//  primitives
//---------------------------------------------------------
float sdPlane( vec3 p )
{
  return p.y;
}

float sdWaveSphere(vec3 p, float radius, float waves, float waveSize) 
{
  // deformation of radius
  float d = waveSize*(radius*radius-(p.y*p.y));
  radius += d * cos(atan(p.x,p.z) * float(waves));
  return 0.5 * (length(p) - radius);
}

// h.xy = base rectangle size,  h.z = height
float sdCylinder6( vec3 p, vec3 h )
{
  return max( length6(p.xz) - h.x, abs(p.y) - h.z );
}

//---------------------------------------------------------
// distance operations
//---------------------------------------------------------
// Union: d1 + d2
vec2 opU( vec2 d1, vec2 d2 )
{
  return (d1.x < d2.x) ? d1 : d2;
}

//---------------------------------------------------------
vec2 map( in vec3 pos )
{
  vec2 res = vec2( sdPlane( pos), 1.0 );
  float color = 50.0+ 40.0 * cos(0.2 * time);
  
  // get frequency and sound wave data 
  float soundFFT  = texture( iChannel0, vec2(0.5, 0.25) ).x; 
  float soundWave = texture( iChannel0, vec2(0.0, 0.95) ).y;
  float fftHeight  = 0.02 + soundFFT;
  float waveHeight = 0.02 + soundWave;
    
  vec3  r1 = rotateY (pos - vec3( 1.0, 0.0,  1.0), aTime*-0.5);
  res = opU( res, vec2( sdCylinder6( r1, vec3(0.1, 0.05, fftHeight) ), color + 44.) );
    
        r1 = rotateY (pos - vec3(-1.0, 0.0, -1.0), aTime*-0.5);
  res = opU( res, vec2( sdCylinder6( r1, vec3(0.1, 0.05, fftHeight) ), color + 44.) );

        r1 = rotateY (pos - vec3(-1.0, 0.0,  1.0), aTime*0.5);
  res = opU( res, vec2( sdCylinder6( r1, vec3(0.1, 0.05, waveHeight) ), color + 88.) );

        r1 = rotateY (pos - vec3( 1.0, 0.0, -1.0), aTime*0.5);
  res = opU( res, vec2( sdCylinder6( r1, vec3(0.1, 0.05, waveHeight) ), color + 88.) );
    
  res = opU( res, vec2( sdWaveSphere  ( pos - vec3(0.0, 0.1, 0.1), 0.8, 12., (soundFFT-0.4)*0.6), color ) );
  return res;
}
//----------------------------------------------------------------------
vec2 castRay( in vec3 ro, in vec3 rd )
{
  float tmin = 0.8;
  float tmax = 8.0;

  float precis = 0.0001;
  float t = tmin;
  float m = -1.0;
  for ( int i=0; i<50; i++ )
  {
    vec2 res = map( ro+rd*t );
    if ( (res.x < precis) || (t > tmax) ) break;
    t += res.x;
    m = res.y;
  }
  if ( t>tmax ) m=-1.0;
  return vec2( t, m );
}

//----------------------------------------------------------------------
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
  float res = 1.0;
  float t = mint;
  for ( int i=0; i<14; i++ )
  {
    float h = -0.01+map( ro + rd*t ).x;
    res = min( res, 8.0*h/t );
    t += clamp( h, 0.02, 0.10 );
    if ( h<0.001 || t>tmax ) break;
  }
  return clamp( res, 0.0, 1.0 );
}

//----------------------------------------------------------------------
vec3 calcNormal( in vec3 pos )
{
  const vec3 eps = vec3( 0.0001, 0.0, 0.0 );
  vec3 nor = vec3(
    map(pos+eps.xyy).x - map(pos-eps.xyy).x, 
    map(pos+eps.yxy).x - map(pos-eps.yxy).x, 
    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
  return normalize(nor);
}

//----------------------------------------------------------------------
// http://en.wikipedia.org/wiki/Ambient_occlusion
// http://joomla.renderwiki.com/joomla/index.php?option=com_content&view=article&id=140&Itemid=157
float calcAO( in vec3 pos, in vec3 nor )  // get ambient occlusion
{
  float occ = 0.0;
  float sca = 1.0;
  for ( int i=0; i<5; i++ )
  {
    float hr = 0.01 + 0.12*float(i) / 4.0;
    vec3 aopos =  nor * hr + pos;
    float dd = map(aopos).x;
    occ += -(dd-hr)*sca;
    sca *= 0.95;
  }
  return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}
//----------------------------------------------------------------------
vec3 render( in vec3 ro, in vec3 rd )
{ 
  aTime = ANIMATE ? time : 0.0;
  sinTime = sin(aTime);
  vec3 col = vec3(0.8, 0.9, 1.0);
  vec2 res = castRay(ro, rd);
  float t = res.x;
  float m = res.y;
  if ( m > -0.5 )
  {
    vec3 pos = ro + t*rd;
    vec3 nor = calcNormal( pos );
    vec3 ref = reflect( rd, nor );

    // material        
    col = 0.45 + 0.3*sin( vec3(0.05, 0.08, 0.10)*(m-1.0) );

    if ( m<1.5 )
    {
      float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
      col = 0.4 + 0.1*f*vec3(1.0);
    }

    // lighting        
    float occ = calcAO( pos, nor );
    vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
    float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
    float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
    float bac = clamp( dot( nor, normalize(vec3(-lig.x, 0.0, -lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y, 0.0, 1.0);
    float dom = smoothstep( -0.1, 0.1, ref.y );
    float fre = pow( clamp(1.0+dot(nor, rd), 0.0, 1.0), 2.0 );
    float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ), 16.0);

    dif *= softshadow( pos, lig, 0.02, 2.5 );
    dom *= softshadow( pos, ref, 0.02, 2.5 );

    vec3 brdf = vec3(0.0);
    brdf += 1.20*dif*vec3(1.00, 0.90, 0.60);
    brdf += 1.20*spe*vec3(1.00, 0.90, 0.60)*dif;
    brdf += 0.30*amb*vec3(0.50, 0.70, 1.00)*occ;
    brdf += 0.40*dom*vec3(0.50, 0.70, 1.00)*occ;
    brdf += 0.30*bac*vec3(0.25, 0.25, 0.25)*occ;
    brdf += 0.40*fre*vec3(1.00, 1.00, 1.00)*occ;
    brdf += 0.02;
    col = col*brdf;
    col = mix( col, vec3(0.8, 0.9, 1.0), 1.0-exp( -0.005*t*t ) );
  }
  return vec3( clamp(col, 0.0, 1.0) ); 
}
//----------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  time = iTime;
  mouse = iMouse.xy / iResolution.xy;
  uv = 2.0*(gl_FragCoord.xy / iResolution.xy) - 1.0;
  uv.x *= iResolution.x / iResolution.y;

  // camera  
  float angle = ROTATE ? 0.02*time : 0.0;
  float rx = 0.5 + 3.0*cos(angle + 6.0*mouse.x);
  float rz = 0.5 + 3.0*sin(angle + 6.0*mouse.x);
  vec3 ro = vec3( rx, 1.0 + 5.0*mouse.y, rz );
  vec3 ta = vec3( 0.0, 0.5, 0.0 );

  // camera tx
  vec3 cw = normalize( ta - ro );
  vec3 cp = vec3( 0.0, 1.0, 0.0 );
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  vec3 rd = normalize( uv.x*cu + uv.y*cv + 3.0*cw );

  // pixel color
  vec3 col = render( ro, rd );
  col = pow( col, vec3(0.4545) );
  fragColor=vec4( col, 1.0 );
}
