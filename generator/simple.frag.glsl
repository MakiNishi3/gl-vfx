const vec3 BAR_COLOR = vec3(0.8, 0.2, 0.3);
const float BAR_COUNT = 20.0;
const float BAR_WIDTH = 0.75;

// first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
const float FREQ_COUNT = 512.0;

const float PI = 3.14159265359;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    float barIndex = floor(uv.x * BAR_COUNT);
    float barHeight = texelFetch(iChannel0, ivec2(barIndex * FREQ_COUNT / BAR_COUNT, 0), 0).r;
    
    float horizontal = smoothstep(1.0 - BAR_WIDTH, 1.0 - BAR_WIDTH, abs(sin(uv.x * PI * BAR_COUNT)));
    float vertical = smoothstep(1.0 - barHeight, 1.0 - barHeight, 1.0 - uv.y);
    
    // Output to screen
    fragColor = vec4(BAR_COLOR * horizontal * vertical, 1.0);
}
