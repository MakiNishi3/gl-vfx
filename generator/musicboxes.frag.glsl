// Music Boxes 0.4.230415 by QuantumSuper
// auti-vj with a bunch of bouncing boxes
// Ray marching inspired by The Art of Code: youtu.be/PGtv-dBi2wE
// Lighting & shadows based on iq's work: https://www.shadertoy.com/view/lsKcDD
//
// - use with music in iChannel0, floor texure in iChannel1 & cubemap in iChannel2 -

#define aTime .2133333*iTime 
#define MAX_STEP 70
#define MAX_DIST 80.
#define MIN_DIST 0.02
#define AA 1. 

struct object{
	int type; //0: plane; 1: box
    vec3 pos; //position
	vec4 param; //horizontal plane (height,0,0,0); box (width, height, depth, 0);
};
object[6] objects; //stores geometry definitions
vec4 fft, ffts; //compressed frequency amplitudes


void compressFft(){ //compress sound in iChannel0 to simplified amplitude estimations by frequency-range
    fft = vec4(0), ffts = vec4(0);

	// Sound (assume sound texture with 44.1kHz in 512 texels, cf. https://www.shadertoy.com/view/Xds3Rr)
    for (int n=1;n<3;n++) fft.x  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //bass, 0-517Hz, reduced to 86-258Hz
    for (int n=6;n<8;n++) ffts.x  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech I, 517-689Hz
    for (int n=8;n<14;n+=2) ffts.y  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech II, 689-1206Hz
    for (int n=14;n<24;n+=4) ffts.z  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech III, 1206-2067Hz
    for (int n=24;n<95;n+=10) fft.z  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //presence, 2067-8183Hz, tenth sample
    for (int n=95;n<512;n+=100) fft.w  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //brilliance, 8183-44100Hz, tenth2 sample
    fft.y = dot(ffts.xyz,vec3(1)); //speech I-III, 517-2067Hz
    ffts.w = dot(fft.xyzw,vec4(1)); //overall loudness
    fft /= vec4(2,8,7,4); ffts /= vec4(2,3,3,21); //normalize
    //fft.x = step(.9,fft.x); //weaken weaker sounds, hard limit
}

mat2 rotM2(float a){float c = cos(a), s = sin(a); return mat2(c,s,-s,c);}

float sdPlane(vec3 p, float h){return p.y-h;}

float sdBox(vec3 p, vec3 b){ //source: https://iquilezles.org/articles/distfunctions/
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float getDistance(vec3 p){	
	float minDist = MAX_DIST; //max minDist
	
	for (int n=0; n<objects.length(); n++){ //get the distance to each object	
             if (objects[n].type == 0) minDist = min( minDist, sdPlane(p-objects[n].pos,objects[n].param.x)); //horizontal Plane
        else if (objects[n].type == 1) minDist = min( minDist, sdBox(p-objects[n].pos,objects[n].param.xyz)); //box     
    }
    
	return minDist;
}

float rayMarch(vec3 rayOrigin, vec3 rayDirection){ //cf. The Art of Code's ray marching tutorial: youtu.be/PGtv-dBi2wE
	float rayLength = MIN_DIST; 
	float radSphere;
	
	for (int n=0; n<MAX_STEP; n++){
		radSphere = getDistance(rayOrigin+rayLength*rayDirection); //get sphere
		rayLength += radSphere; //march
		if (rayLength>MAX_DIST || abs(radSphere)<MIN_DIST) break;
	}
	
	return rayLength;
}

vec3 guessNormal(vec3 pos){ //estimate the surface normal at pos
	vec2 tangent = vec2(.01*MIN_DIST, 0); //sensitive!
	
	vec3 normal = getDistance(pos) - vec3(
		getDistance(pos-tangent.xyy),
		getDistance(pos-tangent.yxy), 
		getDistance(pos-tangent.yyx)
		);
		
	return normalize(normal);
}

float calcAO( vec3 pos, vec3 nor){ //see iq again: https://www.shadertoy.com/view/lsKcDD
	float occ = 0.;
    float sca = 1.;
    
    for (int i=0;i<5;i++){
        float h = .001 + .15*float(i)/4.;
        float d = getDistance( pos+h*nor);
        occ += (h-d)*sca;
        sca *= .95;
    }
    
    return clamp( 1.-1.5*occ, 0., 1.);    
}

float softShadow( vec3 ro, vec3 rd, float mint, float maxt, float w){ //source: https://iquilezles.org/articles/rmshadows/
    float res = 1.;
    float t = mint;
    
    for (int i=0;i<256 && t<maxt;i++){
        float h = getDistance(ro + t*rd);
        res = min( res, h/(w*t));
        t += clamp( h, .005, .5);
        if (res<-1. || t>maxt) break;
    }
    res = max(res,-1.);
    
    return .25*(1.+res)*(1.+res)*(2.-res);
}

vec3 render(vec3 pos, vec3 dir){
    // Light initialization
    vec3 lightPos = vec3(4,6,4);
    vec3 lightCol = .5*vec3(sin(aTime*1.123),sin(aTime*1.234),sin(aTime*1.345))
                    + .5 + step(.9,fft.x);
    
    // Depth calculation
    float rayDist = rayMarch(pos,dir); 
    vec3 rayPos = pos+rayDist*dir;   
    vec3 lightDir = normalize( lightPos-rayPos);
    
    // Texture
    lightCol *= (rayPos.y<ffts.w || rayPos.y<.03)? //global geometry hack rather than object based
                    (rayPos.y>0.03)? 
                        .7*texture( iChannel1, (rayPos.xz*rotM2(1.5708)+rayPos.y-ffts.w+.42)/5., 0.).x:
                        .5*texture( iChannel1, .1*rayPos.xz, 0.).x:
                    1.5;
    
    // Shadows
    vec3 surfNormal = guessNormal(rayPos);
    float amp = clamp( dot(lightDir, surfNormal), 0., 1.) * softShadow( rayPos, lightDir, MIN_DIST, MAX_DIST, .5);
    vec3 col = lightCol * amp;
    
    // Light speck
    vec3  halo = normalize( lightDir-dir );
    float speck = (.1+.9*pow( clamp( dot(surfNormal,halo),0.,1.), 16.)) * amp * (.04+.96*pow( clamp(1.0+dot(halo,dir),0.,1.), 5.));  
    speck = (rayPos.y<ffts.w || rayPos.y<.03)? //same global geo hack
                speck : (.005+15.*speck) * clamp( dot(textureLod( iChannel2, reflect(dir,surfNormal), 1.).rgb,halo), 0., 1.); //cubemap reflection
    col+= lightCol * speck;
    
    // Ambient light
    amp = clamp( .5+.5*surfNormal.y, 0., 1.) * calcAO( rayPos, surfNormal);
    col += lightCol * amp * vec3(.1,.05,.1);
        
    // Fog
    col *= exp(-0.0001*rayDist*rayDist*rayDist); //simple distance based attenuation
    
    // Utility
    //col = .06*vec3(rayPos); //depth map
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    compressFft(); //initializes fft, ffts
    
    // Camera initialization
    vec2 uv = (2.*fragCoord-iResolution.xy) / max(iResolution.x, iResolution.y); //long edge -1 to 1
    vec3 camPos = vec3(0,3.+1.5*sin(.5*aTime),0) + (6.*cos(2.*aTime)+9.) * vec3(sin(aTime), 0,-cos(aTime)); //ray origin, rotating on circle
    vec3 camDir = normalize( vec3( uv.x, vec2(uv.y,1)*rotM2(-.15+.1*cos(2.*aTime)-.2*sin(.5*aTime)))); //ray direction, static, slightly downwards
    camDir.xz *=rotM2(-aTime);
	
	// Object initializations
    objects = object[](
		object(0, vec3(0), vec4(0)), //horizontal plane
		object(1, vec3(1.5,0,1.5), vec4(1,4.*fft.x+ffts.w,1,0)), //box 1
        object(1, vec3(-1.5,0,1.5), vec4(1,4.*fft.y+ffts.w,1,0)), //box 2
        object(1, vec3(1.5,0,-1.5), vec4(1,4.*fft.z+ffts.w,1,0)), //box 3
        object(1, vec3(-1.5,0,-1.5), vec4(1,4.*fft.w+ffts.w,1,0)),//box 4
        object(1, vec3(0), vec4(3,ffts.w,3,0)) //pedestal
        );
    
    // Render
    vec3 col = vec3(0);
    for(float m=0.;m<AA;m++) //simple antialiasing (for AA>=2.)
        for(float n=0.;n<AA;n++)
            col += render(camPos+vec3(m,n,.0)*length(camPos.xy)/iResolution.x,camDir); //sloppy pixel estimation     
    col /= AA*AA;
    
    // Finalizations
    col = 1. - exp(-col); //tone mapping
	col = pow(col, vec3(.4545)); //gamma correction
    fragColor = vec4(col,1.);
}