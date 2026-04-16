const float freq_step = 1.0 / (64.0 * 8.0);
const float frame0 = 0.05;
const float frame1 = 0.15;
float texture_fftw(float uvx)
{
    float freq = 0.0;
    for (float offset = 0.0; offset < freq_step * 8.5; offset += freq_step)
    {
        freq += texture(iChannel0, vec2(offset + uvx, 0.0)).r;
    }
    freq /= 9.0;
    freq = freq * freq;
    return freq;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;   
    
    float uvx = uv.x * 64.0;
    float grid_x = fract(uvx);
    grid_x = smoothstep(frame0, frame1, grid_x) - smoothstep(1.0 - frame1, 1.0 - frame0, grid_x);
    
    uvx = (floor(uvx)) / 64.0;
    float freq = texture_fftw(uvx);
    //freq = pow(freq, 2.0 - uvx);
    float grid_y = fract(uv.y * 32.0);
    float grid_y_offset = floor(uv.y * 32.0) / 32.0;
    grid_y = smoothstep(frame0, frame1, grid_y) - smoothstep(1.0 - frame1, 1.0 - frame0, grid_y);
    //grid_y *= max(sign(freq - grid_y_offset), 0.0);
    
    vec3 color0 = vec3(0.0, 0.0, 1.0);
    vec3 color1 = vec3(0.0, 1.0, 1.0);
    vec3 color2 = vec3(0.0, 1.0, 0.0);
    vec3 color3 = vec3(1.0, 1.0, 0.0);
    vec3 color4 = vec3(1.0, 0.0, 0.0);
    
    vec3 color = color0 * (1.0 - smoothstep(0.0, 0.2, freq));   
    color +=     color1 * (smoothstep(0.0, 0.2, freq) - smoothstep(0.2, 0.4, freq));   
    color +=     color2 * (smoothstep(0.2, 0.4, freq) - smoothstep(0.4, 0.6, freq));   
    color +=     color3 * (smoothstep(0.4, 0.6, freq) - smoothstep(0.6, 0.8, freq));   
    color +=     color4 * (smoothstep(0.6, 0.8, freq));
   
    fragColor = mix(vec4(0.0), vec4(color, 1.0), grid_y * grid_x *max(sign(freq - grid_y_offset), 0.0) );
    
    fragColor = mix(fragColor, vec4(0.0, 0.2, 0.0, 1.0), 1.0 - grid_y * grid_x);
}
