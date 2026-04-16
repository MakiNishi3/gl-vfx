// Honey from Leon

// music from: https://soundcloud.com/sofoclemusic/milk-honey

// text
#define grid 16.
#define cell 1./16.
const int kA=177,kB=178,kC=179,kD=180,kE=181,kF=182,kG=183,kH=184,kI=185,kJ=186,kK=187;
const int kL=188,kM=189,kN=190,kO=191,kP=160,kQ=161,kR=162,kS=163,kT=164,kU=165,kV=166;
const int kW=167,kX=168,kY=169,kZ=170,kSpace=80;

vec2 getSymbol (int key)
{
	return vec2(mod(float(key),grid),floor(float(key)/grid));
}

vec2 getLetterUV (vec2 target, vec2 offset)
{
    vec2 uvLetter = target;
    uvLetter.x = uvLetter.x * 0.45 + 0.017;
    uvLetter += offset / grid;
    float crop = step(target.x, cell) * step(target.y, cell);
    crop *= step(0., target.x) * step(0., target.y);
    return uvLetter * crop;
}

float getText (vec2 target)
{
    int symbols[] = int[] ( kH,kO,kN,kE,kY );
    int count = symbols.length();
    vec2 space = vec2(0.5,1);
    vec2 textUV = vec2(0);
    for (int i = 0; i < count; ++i) {
        vec2 offset = vec2(i,0)/grid;
        offset.x -= float(count)/grid/2.;
        offset.y -= cell/2.;
    	textUV += getLetterUV(target - offset, getSymbol(symbols[i]));
    }
    return texture(iChannel1, textUV).r;
}

float signal (vec2 uv, float thin, float freq1, float freq2)
{
    const float height = 0.2;
    uv.y += sin(uv.x*freq1+iTime)*0.2;
    return abs(thin/(sin(uv.x*freq2-iTime)-uv.y/height));
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 color = vec3(0);
    float unit = 1./iResolution.y;
    vec2 uv = 2.*(fragCoord-.5*iResolution.xy)*unit;
    float time = iTime;
    vec3 honey = vec3(0.9, 0.45, 0.2);
    vec3 light = vec3(1.,0.9,0.8);
    
    float thin = .5;
    float freq1 = 4.;
    float freq2 = 3.;
    vec2 prev = vec2(uv.x-unit, signal(uv-vec2(unit,0), thin, freq1, freq2));
    vec2 next = vec2(uv.x+unit, signal(uv+vec2(unit,0), thin, freq1, freq2));
    vec2 tangent = normalize(next - prev);
    vec2 normal = vec2(tangent.y, -tangent.x);
    vec2 soundUV = vec2(abs(atan(normal.y, normal.x)/3.1459),0.);
    float bounce = texture(iChannel0, soundUV).r;
    freq1 = 4.+bounce*4.;
    
    vec2 uvText = (fragCoord-.5*iResolution.xy)*unit;
    uvText *= 0.1*vec2(2,1);
    vec2 uvTexture = 0.8*fragCoord/iResolution.xy;
    float lum = texture(iChannel2, uvTexture).r;
    float angle = lum * 3.14159 * 2. + time;
    vec2 offset = vec2(cos(angle), sin(angle));
    uv += offset*0.2*getText(uvText);
    
    uv.xy += normal * sin(uv.y*3.);
    float plotter1 = signal(uv, thin, freq1, freq2);
    float shade = 0.5+0.5*dot(normal, normalize(vec2(uv.x,plotter1)-(prev+next)/2.));
        
    thin = .25;
    freq1 = 4.+bounce*10.;
    freq2 = 8.+sin(time);
    float plotter2 = signal(uv, thin, freq1, freq2);
    
    color = mix(color, honey, clamp(plotter1,0.,1.));
    color = mix(color, honey, shade);
    color = mix(color, light, clamp(plotter2,0.,1.));
    
	fragColor = vec4(color,1.0);
}
