//ranges to split
vec2 spec_split = vec2(0.0,0.01);
int steps = 1;//possibility to skip values for performance if steps > 1

float f_range = 0.475;
float a_range = 0.1;

// return 1 value at the time
float spectrum(vec2 spec_split, int steps){
    float ret = 0.0;
    int splitStart = int(floor(spec_split.x*512.0));
    int splitEnd = int(floor(spec_split.y*512.0));
    for(int i = splitStart; i<=splitEnd;i+=steps){
        // first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
        float fft  = texelFetch( iChannel0, ivec2(i,0), 0 ).x;
        ret+=fft;
    }
    if(splitStart!=splitEnd){
        ret/=floor(float((splitEnd-splitStart)/steps));
    }
    return smoothstep(0.5-a_range,0.5+a_range,f_range*ret);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if(ceil(fragCoord.x) == iResolution.x && ceil(fragCoord.y) == iResolution.y){//only on last texel
        fragColor.r = spectrum(spec_split,steps);
    }
}