
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float sin_factor = sin(-1.57);
    float cos_factor = cos(-1.57);
    vec2 p = (fragCoord -.5 * iResolution.xy ) / iResolution.y * mat2(cos_factor, sin_factor, -sin_factor, cos_factor);
    
    float a = atan(p.y, p.x) / 6.28 + .5 ;

    float fft = texelFetch( iChannel0, ivec2(a*512.,0), 0 ).x;
    
    vec4 startColor = vec4(0.953, 0.114, 0.071, 1.);
    vec4 finishColor = vec4(0.651, 0.047, 0.376, .5);
    
    vec4 diff = startColor - finishColor;
    
    fragColor = (startColor - diff*a) * step(length(p), .5*fft);
}