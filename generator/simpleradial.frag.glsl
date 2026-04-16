const vec3 BAR_COLOR = vec3(0.8, 0.2, 0.3);
const float BAR_COUNT = 20.0;
const float BAR_WIDTH = 0.6;

const float BAR_START = 0.15;
const float BAR_END = 0.5;

// first row is frequency data (48Khz/4 in 512 texels, meaning 23 Hz per texel)
const float FREQ_COUNT = 512.0;

const float PI = 3.14159265359;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float aspect = iResolution.x / iResolution.y;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    uv -= 0.5;
    uv.x *= aspect;

    float side = sign(uv.x);
    float angle = -(atan(uv.y, uv.x * side) + PI/2.0) * side + PI;
    float angleNormalized = angle / (2.0*PI);
    
    float dist = length(uv);

    float barIndex = floor(angleNormalized * BAR_COUNT);
    float barHeight = texelFetch(iChannel0, ivec2(barIndex * FREQ_COUNT / BAR_COUNT, 0), 0).r;
    float barEndDist = BAR_START + barHeight * (BAR_END - BAR_START);
    
    float horizontal = smoothstep(1.0 - BAR_WIDTH, 1.0 - BAR_WIDTH, abs(sin(angleNormalized * PI * BAR_COUNT)));
    float innerCircle = smoothstep(BAR_START, BAR_START, dist);
    float outerCircle = 1.0 - smoothstep(barEndDist, barEndDist, dist);

    // Output to screen
    fragColor = vec4(BAR_COLOR * horizontal * innerCircle * outerCircle, 1.0);
}
