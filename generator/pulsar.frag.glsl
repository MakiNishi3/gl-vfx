float PI=3.14159265;


vec4 obj_union(in vec4 obj0, in vec4 obj1)
{
  if (obj0.w < obj1.w)
  	return obj0;
  else
  	return obj1;
}

vec4 obj_sub(vec4 a, vec4 b)
{
	if(-a.w > b.w)
		return a;
	else
		return b;
}


vec4 obj_inter(vec4 a, vec4 b)
{
	if(a.w > b.w)
		return a;
	else
		return b;
}

float sphere(in vec3 p, float r)
{
  return length(p)-r;
}

float round_box(vec3 p, vec3 dims, float r)
{
  return length(max(abs(p)-dims,0.0))-r;
}


vec3 repeat( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}


#define numBins  15.0
#define sampleSize  0.1
#define binSize  1.0/numBins
	
float sampleMusic(vec3 p)
{
	
	float r = 0.0;
	//Figure out bin number
	vec3 repNumber = mod(abs(p/5.0+0.5), numBins);
	float binNumber = float(int(max(max(repNumber.x, repNumber.y), repNumber.z)));

	float binStart = binSize*binNumber;
	
	for(float s = 0.0; s < binSize; s += binSize * sampleSize) {
		// Shader toy shows loudness at a given frequency at (f, 0) with the same value in all channels
		r += texture(iChannel0, vec2(binStart + s, 0.0)).r;
	}
	
	return r*sampleSize;//normalized average
}

float sampleWave(vec3 p)
{
	
	float r = 0.0;
	//Figure out bin number
	vec3 repNumber = mod(abs(p/5.0+0.5), numBins);
	float binNumber = float(int(max(max(repNumber.x, repNumber.y), repNumber.z)));

	float binStart = binSize*binNumber;
	
	
	return texture(iChannel0, vec2(binStart + binSize/2.0, 1.0)).r;
}

vec4 map(in vec3 p)
{
	float r = 1.0*sampleMusic(p);
	vec3 dp = 2.0*vec3(sin(iTime),0.0,cos(iTime))
		*(sampleWave(p)-0.5);
	
  	//return obj_union(
	//	vec4(2.0*r, 0.0, 1.0-r, sphere(repeat(p-dp-2.0*vec3(1.0,1.0,1.0),vec3(5.0,5.0,5.0)),r)),
	//	vec4(2.0*r, 0.0, 1.0-r, sphere(repeat(p+dp-2.0*vec3(1.0,1.0,1.0),vec3(5.0,5.0,5.0)),r)));
	
  	return vec4(2.0*r, 0.0, 1.0-r, sphere(repeat(p-dp-2.0*vec3(1.0,1.0,1.0),vec3(5.0,5.0,5.0)),r));
		
}

// Primitive color
vec3 prim_c(in vec3 p)
{
  return vec3(0.6,0.6,0.8);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 vPos = fragCoord.xy/iResolution.xy - 0.5;

  // Camera up vector.
  vec3 vuv=vec3(0,1,0); 
  
  // Camera lookat.
  vec3 vrp=vec3(0,0,0);

  float mx=iMouse.x/iResolution.x*PI*2.0;
  float my=iMouse.y/iResolution.y*PI/2.0;
  vec3 prp=vec3(cos(my)*cos(mx),sin(my),cos(my)*sin(mx))*6.0; 

  // Camera setup.
  vec3 vpn=normalize(vrp-prp);
  vec3 u=normalize(cross(vuv,vpn));
  vec3 v=cross(vpn,u);
  vec3 vcv=(prp+vpn);
  vec3 scrCoord=vcv+vPos.x*u*iResolution.x/iResolution.y+vPos.y*v;
  vec3 scp=normalize(scrCoord-prp);

  // Raymarching.
  const vec3 e=vec3(0.02,0,0);//
  const float maxd=100.0; //Max depth
  vec4 d=vec4(0.0,0.0, 0.0, 0.1);//(last step size,material id)
  vec3 c,p,N;//Impact color, position, and Normal

  float f=1.0;//Depth
  for(int i=0;i<256;i++)
  {
    if ((abs(d.w) < .001) || (f > maxd)) 
      break;
    
    f+=d.w;
    p=prp+scp*f;
    d = map(p);
  }
  
	
	//Lighting computations
  if (f < maxd)
  {
    c = d.xyz;
    
    vec3 n = vec3(d.w-map(p-e.xyy).w,
                  d.w-map(p-e.yxy).w,
                  d.w-map(p-e.yyx).w);
    N = normalize(n);
	  
	vec3 L = vec3(sin(iTime)*20.0,10,cos(iTime)*20.0);
    float b=dot(N,normalize(prp-p+L));
    //simple phong lighting, LightPosition = CameraPosition
    fragColor=vec4((b*c)*(1.0-f*.01),1.0);
  }
	
  else 
    fragColor=vec4(0,0,0,1); //background color
}
