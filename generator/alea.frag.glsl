#define PI 3.14159265359
#define TWO_PI 6.28318530718

float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float random(float seed, float min, float max) {
	return floor(min + random(vec2(seed)) * (max/min));
}

vec2 rotate2D(vec2 _uv, float _angle){
    _uv =  mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) * _uv;
    return _uv;
}

float polygon(vec2 _uv, float size, float width, float sides) {
	// Angle and radius from the current pixel
	float a = atan(_uv.x,_uv.y)+PI;
	float r = TWO_PI/float(sides);

	// Shaping function that modulate the distance
	float d = cos(floor(.5+a/r)*r-a)*length(_uv);

	return smoothstep(0.005,0.0,abs(d-size)-width/2.);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;

    uv = uv*2.-1.;

	uv.x *= iResolution.x/iResolution.y;
   
    float bass = 0.;
    for (float i = 0.; i < 10.; i ++) {
    	bass+= texelFetch( iChannel0, ivec2(i,0), 0 ).x;
    }
    bass/=10.;
    
    float med = 0.;
    for (float i = 0.; i < 20.; i ++) {
    	med+= texelFetch( iChannel0, ivec2(240.-i,0), 0 ).x;
    }
    med/=20.;
    
    float high = 0.;
    for (float i = 0.; i < 20.; i ++) {
    	high+= texelFetch( iChannel0, ivec2(500.-i,0), 0 ).x;
    }

    high/=20.;
    float vol = (bass+med+high)/3.;
    uv = rotate2D(uv, iTime*0.1 +  bass);
	
    float seed = 8.; // = floor(bass * 5.);
    float size = .6 * bass;
    float width = .02+.3 * vol;
    float rgbShift = 0.02 * vol;
    float colorR = polygon(uv-vec2(rgbShift,0),size,width, random(seed,3.,10.));
    float colorG = polygon(uv,size,width, random(seed,3.,10.));
    float colorB = polygon(uv+vec2(rgbShift,0),size,width, random(seed,3.,10.));
	vec3 color = vec3(colorR, colorG, colorB);
    fragColor = vec4(color,1.0);
}