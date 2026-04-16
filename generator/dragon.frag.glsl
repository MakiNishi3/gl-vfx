#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .001
#define t iTime

float audio_freq( in sampler2D channel, in float f) { return texture( channel, vec2(f, 0.25) ).x; }
float audio_ampl( in sampler2D channel, in float t) { return texture( channel, vec2(t, 0.75) ).x; }

mat2 Rotate(float a)
{
    float s = sin(a);
    float c = cos(a);
    return mat2(c,-s,s,c);
}

float smin( float a, float b, float k )
{
    float res = exp2( -k*a ) + exp2( -k*b );
    return -log2( res )/k;
}

float GetDist(vec3 p, float modifier)
{
//Sphere1
    vec3 s = vec3(cos(t),0.,sin(t));
    p.xy *= Rotate(p.z/10.+t);
    vec3 sP = p-s; 
    sP = mod(sP,4.)-2.; // infinite mirroring
    float sd = length(sP)- 1. * modifier;
//Sphere2
    vec3 s2 = vec3(sin(t),1,5);
    vec3 sP2 = p-s2;
    sP2 = mod(sP2,4.)-2.;
    float sd2 = length(sP2)- 1. * modifier;
//Sphere3
    vec3 s3 = vec3(0.,sin(t),5);
    vec3 sP3 = p-s3;
    sP3 = mod(sP3,4.)-2.;
    float sd3 = length(sP3)- 1. * modifier;
//Combine Scene together   
    float d = smin(sd,sd2, 32.);
    d = smin(d,sd3,32.);
    
    return d;
}

float Raymarching(vec3 ro,vec3 rd,float m)
{
    float dO = 0.;
    for(int i = 0; i<MAX_STEPS; i++)
    {
        vec3 p = ro+dO*rd;
        float ds = GetDist(p, m);
        dO+=ds;
        if(ds<SURF_DIST || dO>MAX_DIST) break;
    }
    return dO;
}

vec3 Norm(vec3 p, float m)
{
    vec2 e = vec2(.01,0);
    float d= GetDist(p,m);
    vec3 n = d -vec3( 
    GetDist(p-e.xyy,m),
    GetDist(p-e.yxy,m),
    GetDist(p-e.yyx,m));
    return normalize(n);
}

float Light(vec3 p)
{
    vec3 lightpos = vec3(0.,0.,2.);
    lightpos = mod(lightpos,4.)-2.;
    vec3 l = normalize(lightpos - p);
    vec3 n = Norm(p,0.);
    
    float dif = clamp(dot(n,l),0.,1.);
    float d = Raymarching(p+n*SURF_DIST*2.,l,0.);
    return dif;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
// UV
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    vec2 st = uv;
//Audio
    float dist2 = dot(uv, -uv);
    float clamped_dist = smoothstep(0., 1.0, dist2);
    float sample1 = audio_freq(iChannel0, abs((uv.x-0.5)/2.) -0.001);
    float sample2 = audio_ampl(iChannel0, clamped_dist);
    
//Music Visualization
    vec2 uv0 = uv;
    vec2 uv1 = uv0;
    float c = length(uv0);
    float r = sample1;
    float offs = .8;
        uv0.y += uv0.x;
        c = smoothstep(r,r+0.01,uv0.y+offs);
        uv1.y -= uv1.x;
        float c2 = smoothstep(r,r+0.01,-uv1.y+offs);
        c *= abs(c2);
        
//Colors Pattern
    float circ = length(st)-.5;
    float r2 = .5;
    
//RayTracing 
    vec3 ro = vec3(cos(t) * .2,sin(t)*.2,t * 10.);
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    vec3 rd2 = normalize(vec3(uv.x,uv.y,1) + vec3(sin(t))* 0.01);
    vec3 rd3 = normalize(vec3(uv.x,uv.y,1) - vec3(cos(t))*0.01);
    float d = Raymarching(ro,rd, 1.);
    float d2 = Raymarching(ro,rd2, 1.);
    float d3 = Raymarching(ro,rd3, 1.);
    vec3 p = ro+rd*d;
    vec3 p2 = ro+rd2*d2;
    vec3 p3 = ro+rd3*d3;
    vec3 n = Norm(p,sample1);
    vec3 n2 = Norm(p2,sample1);
    vec3 n3 = Norm(p3,sample1);
//Shading
    float dif = Light(p);
    float dif2 = Light(p2);
    float dif3 = Light(p3);
    float fog = d /30.;
    float fog3 = d2 /30.;
    float fog2 = d3 /30.;
    float fogCol = cos(t - circ*4.)-1. * dif;
    float fogCol2 = cos(t - circ*3.)-1. + dif2;
    float fogCol3 = cos(t - circ*5.)-1. - dif3;
    float mainCol = abs(sin(t * 3. - circ*3.))-c;
    float mainCol2 = abs(sin(t * 2.4 - circ*2.))*c;
    float mainCol3 = abs(sin(t / 4. - circ*5.))+c;
// Assign Final Color
    float col = mix(mainCol,fogCol,1.-exp(-fog));
    float col2 = mix(mainCol2,fogCol2,1.-exp(-fog2));
    float col3 = mix(mainCol3,fogCol3,1.-exp(-fog3));
    vec3 abberated = vec3(col,col2,col3);
    abberated = max(vec3(0.),abberated);
// Output to screen
    fragColor = vec4(abberated,1.0);
}