// Coded by Anton (2017)
// Inspiered by an unkown demo
// Tweaked for "humans are such an easy prey" by Perturbator


float rep(inout float p, float r)
{
    float hr = r/2.;
    p += hr;
    float id = floor(p * r);
    p = mod(p , r) - hr;
    return id;
}

#define PI 3.1415926
#define TAU (PI * 2.)
#define HPI (PI / 2.)

mat2 rot(float a)
{
    float c = cos(a);float s = sin(a);
    return mat2(c,-s,s,c);
}

float bounce(float p)
{

    float b = .25;
    
    return .5 - cos(p * PI) * .5 + sin(p * PI) * p * b ;
}

float multiplexer(float channel,float nbChannel,float t)
{
    float ft = floor(t);
    float mt = t- ft;
    mt *= nbChannel;
    channel = clamp(mt - channel,0.,1.);
    channel = bounce(channel) ;
    return ft + channel;
}

#define time mod( iChannelTime[0],endEnd)
float introDuration = 44.65;
float introKick = 12.;
float endStart = 237.9;
float endEnd = 262.5;
#define introKickProgression (clamp(time / introKick , 0. ,1.))
#define introProgression (clamp(max(time - introKick,0.) / (introDuration - introKick),0.,1.))

float map(vec3 pos)
{
    float nbChannel = 12.;
    
    float endProgression = clamp((time - endStart) / (endEnd - endStart),0.,1.);
    
    pos.z -= pow(1. - introProgression,2.) * 60.;
    
    float ti = max(0.,time - introDuration) ;
    ti +=  pow(endProgression,2.) * 100.;
    float bpm = 121.;
    
    ti *= (bpm / 60.) * 2.;
    
    float ts = ti / nbChannel;

    float dir =  mod(floor(ts),2.) * 2. - 1.;
    
    float multiTime = ti / nbChannel;
    
    float r1 = multiplexer(2.,nbChannel,multiTime) * PI / 2. * dir;
    pos.xz *= rot(r1);
    
    float r2 = multiplexer(6.,nbChannel,multiTime) * PI / 2. * dir;
    pos.yz *= rot(r2);
    
    float r3 = multiplexer(10.,nbChannel, multiTime) * PI / 2. * dir;
    pos.xy *= rot(r3);
    
    float dec = 4.;
    pos.xyz += dec / 2.;
    
    
    
    pos.z += multiplexer(0. ,nbChannel,multiTime) * dec * -dir;
    pos.x += multiplexer(4. ,nbChannel,multiTime) * dec * -dir;
    pos.y += multiplexer(8.,nbChannel,multiTime) * dec * -dir;
    
    
    
    rep(pos.x,dec);
    rep(pos.y,dec);
    rep(pos.z,dec);
    float r =max(max((abs(pos.x)), abs(pos.y)),abs(pos.z));
    r = texture(iChannel0,vec2(r *.25,.5)).r;
    
    r = (exp(r)) * .35 - .25;
    
    
    float grid = min(min(length(pos.xy),length(pos.yz)),length(pos.xz)) - r;
    
    return grid;
}

vec3 normal(vec3 p)
{
    vec2 e = vec2(.1,0);
    return normalize(vec3(
        map(p - e.xyy) - map(p + e.xyy),
        map(p - e.yxy) - map(p + e.yxy),
        map(p - e.yyx) - map(p + e.yyx)
    ));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = -1. + 2. * fragCoord / iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 ro = vec3(0.,0.,-0.);
    vec3 rd = normalize(vec3(uv, 1));
    vec3 cp = ro;
    
    float id =0.;
    float STEP = 64.;
    for(float st = 0.; st < 1.; st += 1./STEP)
    {
        float cd =  map(cp);
        if(cd < .01)
        {
            id = 1. - st;
            break;
        }
        cp += rd * cd;
    }
 
    vec3 norm = normal(cp);
 
    float li = clamp(dot(rd,norm),0.,1.);
    float qt =6.;
    li = floor(li * qt) / qt;
    
    vec4 bg = vec4(.0,0.,0.,0.) ; // back color
    vec4 lc = vec4(.7,.0,.05,1.); // light color
    vec4 gc = vec4(.1,.15,.15,1.); // grid color
    
    float f = id * introKickProgression;
 
    vec4 c = mix(gc,lc, pow(li,2.));
 
    fragColor = mix(bg,c,f) ;
}
