
// Try these for more or less fun:
#define REFLECT 
//#define RADIAL 
#define SCALE_ON_MOUSE_X


// wavelet-ish visualizer

// Iain Melvin 2014

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  // create pixel coordinates
  vec2 uv = fragCoord.xy / iResolution.xy;
  
  // reflect over center point 
  // comment this line to get basic effect:
#ifdef REFLECT
  uv=abs(uv*2.0-vec2(1.0,1.0));
#endif

#ifdef SCALE_ON_MOUSE_X
  uv *= 1.0-min(0.9,iMouse.x/iResolution.x);
#endif
	
#ifdef RADIAL
  float theta = 1.1*(1.0/(3.14159/2.0))*atan(uv.x,uv.y);
  float r = length(uv);
  uv = vec2(theta,r);	
#endif
	
	
	
  // first texture row is frequency data
  float fft  = texture( iChannel0, vec2(uv.x*1.0,0.25) ).x;

  // second texture row is the sound wave
  float wave = texture( iChannel0, vec2(uv.x,0.75) ).x;

  // note: 512 samples is not a lot to work with

  const float pi = 3.14159;

  // my wavelet 
  //float width = 1.0-uv.y; 
  //float width = (1.0-sqrt(uv.y));
  float width = 1.0-(pow(uv.y,(1.0/3.0) ));
  const float np = 10.0; //num periods
  const int numsteps = 100; // more than 100 crashes windows (would love to know why)
  const float stepsize = 1.0/float(numsteps);
  
  float yr=0.0;
  float accr = 0.0;
  float accn=0.0;
    
  for (float x=-1.0; x<1.0; x+=stepsize){
	
	// the wave in the wavelet
    float yr = sin(((uv.x*2.0)+x)*np*2.0*pi); 
    
    // get a sample - center at uv.x, offset by width*x
    float si = uv.x + width*x;
	  if (si>0.0 || si<1.0){
        
		// sample
		float s = texture( iChannel0, vec2(si,0.7)).x; 
    
		// move sample to -1.0 -> +1.0
    	// I don't know why I need the extra 13/256
    	s+=-0.5+(12.5/256.0); 
    	s*=2.0;

		// multiply with the wave in the wavelet
	    float sr=yr*s;
         
	    // apply packet 'window'
        //float w =  0.5*(1.0-sin(pi*(x+1.0)+pi*0.5));
		float w = 1.0-abs(x); //faster
	    sr*=w;

		// accumulate
        accr+=sr;
        accn+=w*abs(yr);
	  }
  }

  float y= 100.0*sqrt(accr*accr)/float(accn);


  vec3 col = vec3(0,0,0); // zero

  if (uv.y<0.0){
    // chrome fft
    col += vec3(fft,fft,fft);

  }else{
    // our wavelet thing
	  
    y=clamp(y,0.0,1.0); // screen goes red in ubuntu/chrome

    //   b g r
    //   /\/\/
    //  / /\/\
	  
	// yes, I am still learning glsl

    float b = 0.0;
    if (y<0.33)      b = 3.33*y;
    else if (y<0.66) b = 1.0-(3.33*(y-0.33));

    float g = 0.0;
    if (y<0.33)
       g=0.0;
    else if (y<0.66)
        g = (3.33*(y-0.33));
    else
        g = 1.0-(3.33*(y-0.66));

    float r = 0.0;
    if (y>0.66) r = 3.33*(y-0.66);


    col += vec3(r,g,b);
  }
	
  // add wave form on top     
  //col += 1.0 -  smoothstep( 0.0, 0.01, abs(wave - uv.y) );
 
  // output final color
  fragColor = vec4(col,1.0);
}

