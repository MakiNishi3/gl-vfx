// Fork: Sound Lanes 0.4.231001 by QuantumSuper
// Forked from Light Lanes 0.51.230927 by QuantumSuper 
// auto-vj with 2d pseudo-random lanes with light-"sparks" wandering along them reactive to sound
// note: The scale of ftt.x seems sensitive for this one (scale down in compressFft() if too agitated).
// 
// - use with music in iChannel0 -

#define aTime 150./60.*iTime
#define PI 3.14159265359
vec4 fft, ffts; //compressed frequency amplitudes


void compressFft(){ //v1.2, compress sound in iChannel0 to simplified amplitude estimations by frequency-range
    fft = vec4(0), ffts = vec4(0);

	// Sound (assume sound texture with 44.1kHz in 512 texels, cf. https://www.shadertoy.com/view/Xds3Rr)
    for (int n=0;n<3;n++) fft.x  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //bass, 0-517Hz, reduced to 0-258Hz
    for (int n=6;n<8;n++) ffts.x  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech I, 517-689Hz
    for (int n=8;n<14;n+=2) ffts.y  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech II, 689-1206Hz
    for (int n=14;n<24;n+=4) ffts.z  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //speech III, 1206-2067Hz
    for (int n=24;n<95;n+=10) fft.z  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //presence, 2067-8183Hz, tenth sample
    for (int n=95;n<512;n+=100) fft.w  += texelFetch( iChannel0, ivec2(n,0), 0 ).x; //brilliance, 8183-44100Hz, tenth2 sample
    fft.y = dot(ffts.xyz,vec3(1)); //speech I-III, 517-2067Hz
    ffts.w = dot(fft.xyzw,vec4(1)); //overall loudness
    fft /= vec4(3,8,8,5); ffts /= vec4(2,3,3,23); //normalize
	
	//for (int n=0;n++<4;) fft[n] *= 1. + .3*pow(fft[n],5.); fft = clamp(fft,.0,1.); //limiter? workaround attempt for VirtualDJ
}

float aaStep( float fun){return smoothstep( min(fwidth(fun),.001), .0, fun);} //simple antialiasing

mat2 rotM(float r){float c = cos(r), s = sin(r); return mat2(c,s,-s,c);} //2D rotation matrix

float hash21(vec2 p){ //pseudorandom generator, see The Art of Code on youtu.be/rvDo9LvfoVE
    p = fract(p*vec2(13.81, 741.76));
    p += dot(p, p+42.23);
    return fract(p.x*p.y);
}

float sdEquilateralTriangle(vec2 p){ //source: https://iquilezles.org/articles/distfunctions2d/
    const float k = sqrt(3.);
    p.x = abs(p.x) - 1.;
    p.y = p.y + 1./k;
    if (p.x+k*p.y > 0.) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.;
    p.x -= clamp( p.x, -2., 0.);
    return -length(p)*sign(p.y);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = (2.*fragCoord-iResolution.xy) / max(iResolution.x, iResolution.y); //long edge -1 to 1, square aspect ratio
    float amp = 0.;
	float delY = .1;
	float r, ox, fun;
    compressFft(); //initializes fft, ffts

    
    // Lane generation
	for (float m=-1.;m<=1.;m+=.05){
        ox = m;
        fun = uv.x-ox;
        for (float n=0.;n<2./delY;n++){ //uv.y -1..1
            r = floor(hash21(vec2(n+ceil(aTime/16.),ox+max(.98*step(fft.x,.96),fract(aTime/16.))))*3.-1.); //r {-1,0,1}
            fun += (r*(uv.y-(delY*n-1.))+ox+m) * step(delY*n-1.,uv.y+.001) * step(uv.y+.001,delY*(n+1.)-1.); //+.001 to avoid weird? singularities for negative uv.y
            ox = r*(delY*(n+1.)-1.) - (r*(delY*n-1.)-ox-m) - m; //? isnt that supposed to be: ox += r*delY ?
        } 
		amp += (.8+.5*ffts[int(m*m*3.)]) * ( //brightness on voice
            aaStep(abs(fun)-.009*iResolution.y/iResolution.x) //lane
            * (.1+.9*aaStep(abs(fragCoord.y/iResolution.y-fract(aTime/8.+m*(.6+.4*ffts.w)))-.005*(1.+17.*step(.95,fft.x))*iResolution.y/iResolution.x)) //step "spark"
            + 1e-3 / length(vec2(fun, fragCoord.y/iResolution.y-fract(aTime/8.+m*(.6+.4*ffts.w))))); //glow "spark"
	} 


    // Color design
    vec3 col = vec3(clamp(amp,.0,1.)); 
    col += col * max(.0,1.-5.*fragCoord.y/iResolution.y*(1.-fft.x*fft.x*fft.x)) //bass level dependend brightness, y-axis
        + smoothstep(.0,1.,.2-amp) * fft.w; //lighten darker background
    col *= abs( cos( .06*aTime + PI/vec3(.5,2.,4.) + ffts.xyz)); //color shift 
    col *= mix( .2+.8*(1.-length(uv)), 1., fft.z); //vignette

    
    // Center symbol
    uv *= .8+.5*(1.-fft.x*fft.x); 
    fun = mix(
        abs(length(uv)-.23)-.07, //circle
        (sin(aTime/4.+fft.y-.5)<.0)? //switch when unused
            abs(dot(abs(uv*rotM(PI/4.)),vec2(1))-.25)-.1 : //square
            abs(sdEquilateralTriangle(uv*4.))-.27, //triangle
        clamp( sin(aTime/2.+fft.y-.5), .0, 1.));
        
    col = vec3(ffts.x<=ffts.y,ffts.y<=ffts.z,ffts.z<=ffts.x) * fft.z * .08 //overall tint 
        + abs(1.-col) * aaStep(fun) * fft.y * .13 //symbol
        + col * (1.-step(length(col),.9)*aaStep(fun)) * .8; //background
      
    fragColor = vec4(col,1);
}
