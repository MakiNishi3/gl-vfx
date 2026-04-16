//Ethan Shulman/public_int_i 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//thanks to iq for the great tutorials, code and information
//thanks to XT95 for the ambient occlusion function




#define FOV_SCALE 2.
#define ITERATIONS 86
#define EPSILON .01
#define NORMAL_EPSILON .012

#define VIEW_DISTANCE 64.

#define pi 3.141592

vec3 cameraLocation;
vec2 cameraRotation;


struct material {
    vec3 diffuse,specular,emissive;
    float metallic,roughness;
};
struct light {
    vec3 position, color;
    float size;
};
    

//#define global_illumination 1
#define gi_background 1
#define gi_trace_iter 16
const float global_illumination_strength = .3,
    		global_illumination_reach = 16.;

const vec3 ambient = vec3(0.25);


#define nLights 3

#if nLights != 0
light lights[nLights];
#endif    

void initLights() {
    #if nLights != 0
    lights[0] = light(vec3(30.,-30.,10.),
                      vec3(1.,.7,.85)*max(0., texture(iChannel0,vec2(.0,.25)).x*1.5-.5),
                      70.);
    
    lights[1] = light(vec3(-30.,-20.,10.),
                      vec3(0.75,.95,.83)*max(0., texture(iChannel0,vec2(.4,.25)).x*1.5-.5),
                      70.);
    
    lights[2] = light(vec3(0.,-20.,-30.),
                      vec3(0.75,.83,.95)*max(0., texture(iChannel0,vec2(.8,.25)).x*1.5-.5),
                      70.);
	#endif
}

//distance functions from iq's site
float sdTorus( vec3 p, vec2 t ) {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float udBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}

    
vec2 rot(in vec2 v, in float ang) {
    float si = sin(ang);
    float co = cos(ang);
    return v*mat2(si,co,-co,si);
}


float ground(in vec3 rp) {
    return abs(rp.y-5.);
}

float mainObject(in vec3 rp) {
 	
    vec3 p = rp+vec3(0.,4.,0.);
    float ts1 = texture(iChannel0, vec2(0.25,0.25)).x,
          ts2 = texture(iChannel0,vec2(0.05,.25)).x;
    
    p.xy = rot(abs(p.xy), iTime*.1);
    p.zx = rot(abs(p.zx), iTime*.4689-ts1*1.);
    p.zy = rot(abs(p.zy), iTime*.6344-ts2*4.);
        
    return min(sdTorus(p,vec2(7.,1.)), udBox(p, vec3(3.,5.+ts2*4.,4.)));
}


float df(in vec3 rp) {

    return min(ground(rp),mainObject(rp));
}
float df_hq(in vec3 rp) {
	return df(rp);
}



const vec3 ne = vec3(NORMAL_EPSILON,0.,0.);
vec3 normal2(in vec3 rp) {
    return normalize(vec3(df(rp+ne)-df(rp-ne),
                          df(rp+ne.yxz)-df(rp-ne.yxz),
                          df(rp+ne.yzx)-df(rp-ne.yzx)));
}


vec3 normal(in vec3 rp) {
    return normalize(vec3(df_hq(rp+ne)-df_hq(rp-ne),
                          df_hq(rp+ne.yxz)-df_hq(rp-ne.yxz),
                          df_hq(rp+ne.yzx)-df_hq(rp-ne.yzx)));
}


material mat(vec3 rp) {
    material m;
    
    if (mainObject(rp) < EPSILON) {
		m = material(vec3(.74,.54,.65), //diffuse
                     vec3(.74,.54,.65), //specular
                  	 vec3(0.), //emissive
                    0.0,//metallic
                     0.9);//roughness
    }
    
    if (ground(rp) < EPSILON) {
        m = material(vec3(1.), //diffuse
                     vec3(0.), //specular
                     vec3(0.), //emissive
                     0.,//metallic
                     0.9);//roughness
    }
    
    return m;
}



//rp = ray pos
//rd = ray dir
//maxDist = max trace distance
//returns -1 if nothing is hit
float trace(in vec3 rp, inout vec3 rd, float maxDist) {
    
    float d,s = 0.;
    for (int i = 0; i < ITERATIONS; i++) {
        d = df(rp+rd*s);
        if (d < EPSILON || s > maxDist) break;
        s += d;
        
        //rd = normalize(rd+vec3(.01,-.001,0.)*d);
    }
    
    if (d < EPSILON) return s;
    
    return -1.0;
}

vec3 randomHemiRay(in vec3 d, in vec3 p, in float amount) {
    return normalize(d+cos(p*245.245-d*cos(p*9954.345)*3532.423)*amount);
}
//ambient occlusion function is XT95's from https://www.shadertoy.com/view/4sdGWN
float ambientOcclusion(in vec3 rp, in vec3 norm) {
    float sum = 0., s = 0.;
    vec3 lastp;
    
    for (int i = 0; i < 32; i++) {
        vec3 p = rp+randomHemiRay(norm,lastp,.4)*s;
        sum += max(0., (s-df(p))/(s*s));//randomHemiRay(norm,rp,.5)*s);
        lastp = p;
        s += .2;
    }
    
    return clamp(1.-sum*.05, 0., 1.);
}

float softShadowTrace(in vec3 rp, in vec3 rd, in float maxDist, in float penumbraSize, in float penumbraIntensity) {
    vec3 p = rp;
    float sh = 0.;
    float d,s = 0.;
    for (int i = 0; i < ITERATIONS; i++) {
        d = df(rp+rd*s);
        sh += max(0., penumbraSize-d)*float(s>penumbraSize*4.);
        s += d;
        if (d < EPSILON || s > maxDist) break;
    }
    
    if (d < EPSILON) return 0.;
    
    return max(0.,1.-sh/penumbraIntensity);
}

vec3 background(in vec3 rd) {
	vec3 c = vec3(0.);
    #if nLights != 0
    for (int i = 0; i < nLights; i++) {
        c += lights[i].color*max(0., dot(rd, normalize(lights[i].position)))*.6;
    }
    #endif
    return c;
}
vec3 background_gi(in vec3 rd) {
    return background(rd);
}

vec3 locateSurface(in vec3 rp) {    
    vec3 sp = rp;
    for (int i = 0; i < 3; i++) {
        float sd = abs(df(rp));
        if (sd < EPSILON) return sp;
        sp += normal2(sp)*sd*.5;
    }
    return sp;
}
void lighting(in vec3 td, in vec3 sd, in vec3 norm, in vec3 reflDir, in material m, inout vec3 dif, inout vec3 spec) {
    float ao = ambientOcclusion(td,norm);
    dif = ambient*ao;
    spec = vec3(0.);
        
    #if nLights != 0
    for (int i = 0; i < nLights; i++) {
        vec3 lightVec = lights[i].position-td;
        float lightAtten = length(lightVec);
        lightVec = normalize(lightVec);
        float shadow = softShadowTrace(sd, lightVec, lightAtten, 0.3, 1.5);
        lightAtten = max(0., 1.-lightAtten/lights[i].size)*shadow;
        
    	dif += max(0., dot(lightVec,norm))*lights[i].color*lightAtten;
        spec += pow(max(0., dot(reflDir, lightVec)), 4.+(1.-m.roughness)*78.)*shadow*lights[i].color;
    }
	#endif
    
    //dif *= .5+ao*.5;
}

//copy of shade without reflection trace
vec3 shadeNoReflection(in vec3 rp, in vec3 rd, in vec3 norm, in material m) {
    vec3 sd = rp+norm*EPSILON*10.;//locateSurface(rp)-rd*EPSILON*2.;
    
    //lighting
    vec3 reflDir = reflect(rd,norm);

    vec3 lightDif,lightSpec;
    lighting(rp,sd,norm,reflDir,m,lightDif,lightSpec);

    return (1.-m.metallic)*lightDif*m.diffuse +
        	(.5+m.metallic*.5)*lightSpec*m.specular +
        	m.emissive ;
}
vec3 giTrace(in vec3 rp, in vec3 rd) {
    float s = 0., d;
    for (int k = 0; k < gi_trace_iter; k++) {
        d = df(rp+rd*s);
        if (d < EPSILON) break;
        s += d;
    }
    if (d < EPSILON) {
        vec3 hp = rp+rd*s;
        return shadeNoReflection(hp, rd, normal(hp), mat(hp))*max(0.,1.-s/global_illumination_reach);
    }
    #ifdef gi_background
    return background_gi(rd);
    #endif
    return vec3(0.);
}
vec3 shade(in vec3 rp, in vec3 rd, in vec3 norm, material m) {
    vec3 sd = rp+norm*EPSILON*10.;//locateSurface(rp)-rd*EPSILON*2.;
    
    //lighting
    vec3 dlc = vec3(0.);
    
    #ifdef global_illumination
    vec3 ray = norm;
    vec3 majorAxis = abs(ray);
    if (majorAxis.x > majorAxis.y) {
        if (majorAxis.x > majorAxis.z) {
            majorAxis = vec3(1.,0.,0.);
            if (ray.x == 1.) ray = vec3(0.999,0.001,0.0);
        } else {
            majorAxis = vec3(0.,0.,1.);
            if (ray.z == 1.) ray = vec3(0.,0.001,0.999);
        }
    } else {
        if (majorAxis.y > majorAxis.z) {
            majorAxis = vec3(0.,1.,0.);
            if (ray.y == 1.) ray = vec3(0.,0.999,0.001);
        } else {
            majorAxis = vec3(0.,0.,1.);
            if (ray.z == 1.) ray = vec3(0.,0.001,0.999);
        }
    }
    
    vec3 rayRight = normalize(cross(majorAxis,ray))*.5;
    vec3 rayUp = normalize(cross(ray,rayRight))*.5;

    vec3 gi = giTrace(sd, norm);
    gi += giTrace(sd, normalize(norm+rayRight));
    gi += giTrace(sd, normalize(norm-rayRight));
    gi += giTrace(sd, normalize(norm+rayUp));
    gi += giTrace(sd, normalize(norm-rayUp));
    dlc += gi*global_illumination_strength;
    #endif
    
    vec3 slc = vec3(0.);
    vec3 reflDir = reflect(rd,norm);
    vec3 tReflDir = normalize(reflDir+cos(rp*245.245-rd*cos(rp*9954.345)*3532.423)*m.roughness*0.25);
    tReflDir *= sign(dot(tReflDir,reflDir));
    
    float rtd = trace(sd,tReflDir,VIEW_DISTANCE);
    if (rtd < 0.) {
        slc = background(tReflDir);
    } else {
        vec3 rhp = sd+tReflDir*rtd;
        slc = shadeNoReflection(rhp,reflDir,normal(rhp),mat(rhp));
    }
    
    vec3 lightDif,lightSpec;
    lighting(rp,sd,norm,reflDir,m,lightDif,lightSpec);
    dlc += lightDif;
    slc += lightSpec;
    
    float fres = 1.-max(0., dot(-rd,norm));
    
    return (1.-m.metallic)*dlc*m.diffuse +
        	slc*m.specular*((.5-m.metallic*.5)*fres+m.metallic*(.5+m.metallic*.5)) +
        	m.emissive ;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 R = iResolution.xy;
	vec2 uv = (fragCoord.xy - R*.5)/R.x;

    initLights();
    
  
    vec2 mxy = (iMouse.xy/iResolution.xy);
    mxy.y -= 1.;
    mxy *= 6.28;
    if (iMouse.w < 1.) {
        mxy = vec2(iTime*.2,-3.9);
    }
    cameraRotation = vec2(-mxy.x-1.71,mxy.y/4.+2.4);//x = yaw ,   y = pitch
    cameraLocation = vec3(sin(mxy.x)*30.,
                          -6.,
                          cos(mxy.x)*30.);

    
    vec3 rp = cameraLocation;
    vec3 rd = normalize(vec3(uv*vec2(1.,-1.)*FOV_SCALE,1.));

    rd.yz = rot(rd.yz,cameraRotation.y);
    rd.xz = rot(rd.xz,cameraRotation.x);
    
    rp += rd*5.;
    
	float itd = trace(rp,rd,VIEW_DISTANCE);
    if (itd < 0.) {
        fragColor = vec4(background(rd),1.);
        return;
    }
    

    vec3 hp = rp+itd*rd;
    #ifndef PATH_TRACE
    fragColor = vec4(mix(shade(hp,
                      rd,
                      normal(hp),
                      mat(hp)), background(rd), max(0.,itd/VIEW_DISTANCE)),1.);
	#else
    
    #endif
}