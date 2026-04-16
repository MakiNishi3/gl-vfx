
//functions from chronos: https://www.shadertoy.com/view/lsdGR8

float audio_freq( in sampler2D channel, in float f) { return texture( channel, vec2(f, .25) ).x; }
float audio_ampl( in sampler2D channel, in float t) { return texture( channel, vec2(t, 0.0075) ).x; }


float random(float s)
    {
    
    float f = fract(sin(s+iTime/5000.)*43278.);
    return f;
}

float random2(vec2 st)
{
 	float f = fract(sin(dot(st, vec2(12.212,72.2343)*43220.324))); 
    return f;
}

vec2 random22(vec2 st)
{
 	vec2 f = fract(sin(dot(st, vec2(12.212,72.2343))*vec2(452363., 22359.23))); 
    return f;
}

float musicRing(vec2 st, float rad, float inner, float outer)//inner and outer define if ring points in or out and it's length, set alternate one to 0.
    {
     
    float l = length(st) - rad;
    //l = smoothstep(0.5, 0.5, l)*(1.0-smoothstep(0.6, 0.6, l));
    

    float a = atan(st.y, st.x)+3.14159;
    //I don't want to pass a into sin, that would give me only agnles between -1 and 1
    //I want to adjust the brightness of the edges of each id, so I use step based on the fract of the angle*20.
    //I step the left and right side
    //I also use a triangle wave instead of just a fract because that helps?
    
    //ah but angle goes from 0 to 2PI so if I want cells from a to a*20. in steps of a, then I have steps of 2PI
    //so if I want to step those values based on a, then it's something like 0.2, to 2PI-0.2
    
    float lineNum = 29.3;//although that's not what it ends up being 
        //I think it's more like actuallinenum/2PI
        //and I don't use exaclty 30 I guess for that reaosn as well because with exaclty
        ///thirty we end up with an extra bit of a part in the leftside of the thing.
        
        //trying out audio now
        
        
    float idA = floor(a*lineNum ); 
    float sample3 = audio_freq(iChannel0, idA/290.+0.15);
        
        //yes! that works ..no it doesn't...I fix this towards the end.
   // float idA = floor(a*20.)+step(0.1,abs(fract(a*20.)*2.0-1.0))*(1.0-step(.9,abs(fract(a*20.)*2.0-1.0)));  //the wrong way
  
    //i either use sinways here or random, just to test that the cells move independantly
    float idR = random(idA);
    
    //I actually don't use an idea for the length because I'm really only interested in the cells based on angle.
    //I want to keep the length mobile so I can ajdust the length based on the angle cell and whatever signal is fed in.
    float idL = l*10.; //floor(l*10.);
    //I decide on a high and low end for the circle
    
    
    float low = 3.5+inner*sample3; 
	//and on the high end I add the random value based on each angle cell "idR"
    float high = 3.8+outer*pow(sample3, 15.)*40.;
    
    //I smoothstep the lower and higher bound of the circle based on the low and the varying high 
    
    idL = smoothstep(low, low, idL)*(1.0-smoothstep(high, high, idL));
    
   //then I just added this to the color ANNNND I ad the fract values of 
    //first smoothstep puts a bit of 0 before the cell
	//the second puts a bit of zero at the end of the cell
    //multiplying these means whenever either one is zero we cna ensure that the length of the cell will be zero.
    
   float f =idL*smoothstep(0.1, .2, fract(a*lineNum))*(1.0-smoothstep(.8, 0.9, fract(a*lineNum)));
    return f;//*sample3;
}

float stars(vec2 st)
{
    st = st*2.0-1.0;
    
 vec2 i = floor(st*50.);
    vec2 f = fract(st*50.)-0.5;

    float star = length(f+random22(i)/5.)+0.2;
    
    star = 1.0-pow(smoothstep(0., 00.+random2(i)/4., star), 20.);
    
    return star*20.;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 st = fragCoord.xy / iResolution.xy;
    st.x *=iResolution.x/iResolution.y;
    st.x-=0.40;
    vec3 color = vec3(1.);
    
    float atmos = 1.0-pow(1.0-min(st.y, 0.5), 3.104);
    //atmos = pow(atmos,  2.);
    float atmos2 =1.0- pow(1.0-max(st.y, 0.8), 0.112);
    //atmos2 = pow(atmos2, 2.);
    
    color = 0.5-0.5*sin(  6.57*(atmos*vec3(0.335,0.045,0.023)*.816 ));
    color = mix(color, vec3(0.900,0.513,0.365), atmos2);
	
  	
    color = mix(vec3(0.860,0.585,0.585), vec3(0.460,0.831,0.995), atmos)+0.1; //cool daylight colors
    //or with the black it becomes midevening colors
    
  	//color = mix(vec3(0.925,0.382,0.120), vec3(0.056,0.302,0.800), atmos)+0.1; //cool evening colors
    color *=1.0-st.y; //adding black to the top
    color+=vec3(0.0, 0.4, 0.0)*(1.0-st.y-0.492)*0.5; //adding some green aroud the middle
    
    st = st*2.0-1.0;
    
    float sample1 = pow(audio_ampl(iChannel0, 0.012), 1.7);
    
    vec2 pos=st/1.2;///(vec2(sample1))/2.;
    
    
   	color+=musicRing(pos, 0.1, 0.0, 0.9);//idL*smoothstep(0.0,0.5, fract(a*lineNum))*(1.0-smoothstep(6., 6.57, fract(a*lineNum)));
    color+=musicRing(pos, -0.01, 0.4, 0.);
    float ring = length(pos)+0.009;
    ring = smoothstep(0.41, 0.411, ring)*(1.0-smoothstep(0.415, .421, ring));
    
    
    color+=ring;//I add the basic white ring
    
    float sample3 = pow(audio_freq(iChannel0, (st.x*0.5+1.)/10.), 10.)*0.92;;
    //color+=sample3;//I add the cool light affect that I found by accident
    
    ring = length(st)-0.364;
    float size = -0.048;
    //ring = 1.0-smoothstep(size, size+0.01, ring)*(1.0-smoothstep(size+0.1, size+0.2, ring));
    //color+=ring;
    
    
    
    float blid = floor(st.x*50.);
    
    //getting the audio frequency
    
    float blLow = 0.0;
    float blHigh = 1.*pow(sample3, 1./2.)/2.;
    
    float bottomLines = (1.0-step( blHigh, st.y+1.));
    bottomLines*=smoothstep(0.1, 0.4, fract(st.x*50.))*(1.0-smoothstep(0.5, 1., fract(st.x*50.)));
    color+=bottomLines;
    
    
    //add stars
    color+=stars(st)*pow((st.y*0.5+0.5), 4.);
  
    //vignett by Ippokratis https://www.shadertoy.com/view/lsKSWR
    //with original comments
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv *=  1.0 - uv.yx;   //vec2(1.0)- uv.yx; -> 1.-u.yx; Thanks FabriceNeyret !   
    float vig = uv.x*uv.y * 40.0; // multiply with sth for intensity 
    vig = pow(vig, 0.25); // change pow for modifying the extend of the  vignette
	
    
    
    color*=vig;
    
    
    //color = firePalette(st.x);
   fragColor = vec4(color, 1.0);
}
