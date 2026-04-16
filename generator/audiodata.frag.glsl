
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
// start with black
    fragColor=vec4(0);

// normalise x,y coords
    vec2 uv = fragCoord/iResolution.xy;

// i goes 0 to +1 from left to right
    float i=uv.x;

// v goes -1 to +1 from bottom to top
    float v=(uv.y-0.5)*2.0;

// a simple horizontal octave measuring scale in dark red 
    fragColor.r += fract(log(i*iSampleRate/32.70)/log(2.0))*0.25;
// each black to red horizontal band is an octave in the FFT
// the right edge of the screen is 11025hz and the left edge 0hz
// the unfinished octave on the far right is C9-E9ish
// the octave that is almost in the center is C8-C9
// to the left of that is C7-C8 then C6-C7 then C5-C6 etc

// read the fft bucket
    float fft=texture(iChannel0,vec2(i,0.25)).r;    

// add blue if we are closer to center than fft value
    if(abs(v)<=fft)
    {
	    fragColor.b += 1.0;
    }
    
// read the wav sample and convert from 0 to 1 into -1 to +1
    float wav=(texture(iChannel0,vec2(i,0.75)).r-0.5)*2.0;

// add green if we are closer to center than wav value
    if( ( (v<=0.0) && (v>=wav) ) || ( (v>=0.0) && (v<=wav) ) )
    {
	    fragColor.g += 1.0;
    }
    
}