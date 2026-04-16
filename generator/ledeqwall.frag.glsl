/**
    Simple audio EQ  

    Each one has a different color / zoom - sample level based
    off grid position.
    
    The EQ is based off of some of the quick and easy ones
    done for backgrounds in some of my shaders. Was more just 
    playing around while doing other shaders.


    Looks nice full screen / play some music or use soundclound!

    @byt3_m3chanic | 60/18/2021
    
    
    //////////////////////////////////////////////////////////////
    
    Was looking at this to make the tv/ trying to emulate 
    photoshop layers
    
    https://we.graphics/blog/create-a-detailed-vintage-tv-from-scratch-in-photoshop/

*/


#define R   iResolution
#define M   iMouse
#define T   iTime
#define PI  3.14159265359
#define PI2 6.28318530718

float mtime;

float sampleFreq(float freq) { return texture(iChannel0, vec2(freq, 0.25)).x;}
float hash21(vec2 p){ return fract(sin(dot(p,vec2(23.86,48.32)))*4374.432); }
float hash(in float n){return fract(sin(n)*43.54); }

float noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.-2.*f);
    float n = p.x + p.y*57.;
    float res = mix(mix( hash(n+  0.1), hash(n+  1.1),f.x),
                    mix( hash(n+ 57.1), hash(n+ 58.1),f.x),f.y);
    return res;
}

float box( in vec2 p, in vec2 b ) {
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

//https://www.shadertoy.com/view/Ms23DR
vec2 curve(vec2 uv){
	uv = (uv - vec2(.5,.5)) * 2.0;
	uv *= 1.1;	
	uv.x *= 1.0 + pow((abs(uv.y) / 4.), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 3.), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv *0.92 + 0.04;
	return uv;
}

vec3 getWood(vec3 p){
    const vec3 woodAxis = normalize(vec3(1,0,1));
    vec3 mfp = (p + dot(p,woodAxis)*woodAxis*13.5)*1.20;
    float wood = 0.;
    wood += abs(noise(mfp.xz*2.  )-.5);
    wood += abs(noise(mfp.xz*8.0 )-.5)/2.0;
    wood += abs(noise(mfp.xy*11.0)-.5)/4.0;
    wood += abs(noise(mfp.xy*12.0)-.5)/8.0;
    wood /= 1.15-1.5/18.0;
    wood = pow(1.0-clamp(wood,0.0,1.0),5.0);
    
    return mix(vec3(0.788,0.557,0.231),vec3(0.486,0.282,0.192),wood);
}

// @iq https://iquilezles.org/articles/palettes
// color(t) = a + b ⋅ cos[ 2π(c*t+d)]
vec3 hue(float t){ 
    vec3 c = vec3(0.984,0.878,0.980),
         d = vec3(0.796,0.655,0.341);
    return vec3(.65) + vec3(.45)*cos((T*.3)+PI2*(c*t+d)); 
}

void mainImage( out vec4 O, in vec2 F ) {   

    mtime = mod(T*.08,4.);
    // auto loop over some configurations
    // how many times to repeat 
    vec2 rpt = vec2(5.,3.);
    if(mtime<3.) rpt = vec2(2.,1.);
    if(mtime<2.) rpt = vec2(6.,4.);
    if(mtime<1.) rpt = vec2(3.,2.);
    
    vec3 wood = vec3(0.424,0.278,0.118);
    
    vec3 C = vec3(0);
    // reset coords 0 to 1
    vec2 uv = F.xy/R.xy;
    uv.xy-=vec2(-T*.03,T*.02);
     
    vec2 vx = floor(uv*rpt);
    float hs = hash21(vx+iDate.z);
    
    vec2 vuv = uv;
    uv=fract(uv*rpt);

    uv.y*= 1.5;
    uv.y-=.25;
    vec2 xuv = uv;
      
    vec3 ledc = hue(hs*3.)*.15;//vec3(0.176,0.325,0.239);
    vec3 ledh = hue(hs*2.9);
    vec3 blk  = clamp(ledh-.025,0.,1.);
    vec3 clr=mix(ledc,ledh,(xuv.y)*1.75);

    vec3 screenColor = hue(hs)*.7;//vec3(0.173,0.529,0.243);
    vec3 screenLight = clamp(screenColor+.45,0.,1.) ;
    
    uv=curve(uv);
    float px = fwidth(vuv.x);

    float bkg  = box(uv-vec2(.5,.5),vec2(.46 ,.455));
    float shd  = box(uv-vec2(.5,.515),vec2(.46 ,.455));
    float inst = box(uv-vec2(.5,.5),vec2(.41 ,.3675));
    float scrn = box(uv-vec2(.5,.5),vec2(.44 ,.42 ));
    
    float rim = abs(abs(bkg)-.0015)-.00075;
    float rig = abs(abs(scrn)-.00175)-.001;
    
    float fde = smoothstep(.025+px,-px,shd);
    float sde = smoothstep(-px,.08+px,inst);
    float bde = smoothstep(.075+px,-px,bkg);

    rim = smoothstep(px,-px,rim);
    rig = smoothstep(.005+px,-px,rig);
    bkg = smoothstep(-px,px,bkg);
    inst= smoothstep(.115+px,-px,inst);
    scrn= smoothstep(px,-px,scrn);
    
    
    float fade = max(bkg,1.-((xuv.y-.1)*1.5))*1.4;
    vec3 grey = mix(vec3(.0),vec3(.3),fade);

    // paint screen
    C=mix(vec3(1.),wood,bkg);
    C=mix(C,grey,inst);
    C=mix(C,screenColor,scrn);
    C=mix(C,mix(screenColor,vec3(0.051,0.129,0.071),fade),scrn*.55);
    C=mix(C,mix(screenLight,C,fade),scrn);
    // audio eg
    uv*=2.;uv*=14.;uv-=vec2(0,.5);

    //
    vec2 f = fract(uv)-.5;
    vec2 fid = floor(uv)+.5;
    //start position and phase
    float zt = hs>.35 ? hs>.65 ? hs*.0025 : hs*.0125: hs*.065;
    // get audio
    float ht = sampleFreq( (hs>.65?.02:.001)+(fid.x*zt) );

    ht+=.15;
    ht*=1.65;
    
    float ff = box(f,vec2(.25))-.075;
    float fm = abs(ff)-.045;
    ff=smoothstep(.075+px,-px,ff);
    fm=smoothstep(.075+px,-px,fm);
    
    float avg = (fid.y*.095);  
    float avw = (fid.x*.0165 );
    
    //draw dots
    if(fid.x>2. && fid.x<26.&& fid.y>2.) {
        if(ht>avg&&hs>.25)C=mix(C,clr,hs>.5?fm:ff);
        if ( ht>avg&&ht<avg+.1&& (hs<.65 ||hs>.9) ) C=mix(C,ledh,hs<.89?ff:fm);
    }

    //frame and overlay
    vec3 woodback =getWood(vec3(vuv,2.)).rgb;
       
    if(xuv.y>.3&&xuv.y<.7) woodback=(woodback)*.5;
    if(xuv.y>.32&&xuv.y<.68) {
        vec2 dv = xuv;
        dv = fract(dv*16.)-.5;
        float dt = length(dv)-.5;
        dt=abs(dt)-.025;
        dt=smoothstep(.1+px,-px,dt); 
        vec3 hlr = hue(hash21(vec2(vx.y,1.)*.5));
        woodback=mix(hlr,hlr*.75,dt);
     }
    
    C=mix(C,woodback,bkg);
    C=mix(C,C*.3,  min(fde,bkg)*.5 );  
    C=mix(C,C*.1, min(bde,bkg)*.35 ); 
    C=mix(C,C*.3, ((scrn)-(1.-sde))*.45 );
    C=mix(C,vec3(.2)*fade,rim+rig);
    //out put
    O = vec4(C,1.0);
}


