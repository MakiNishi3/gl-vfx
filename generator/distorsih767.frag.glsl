// original code by shadertoyjiang
// edited by Zhonk Vision
// Simplex 2D noise function
vec3 permute(vec3 x) {
    return mod(((x * 34.0) + 1.0) * x, 289.0);
}

// Hash function
float s(vec2 v) {
    const vec4 C = vec4(0.511324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(8.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Rotation function with audio interaction
vec2 rotate(vec2 p, float a, float audioAmplitude) {
    float c = cos(a + audioAmplitude * 0.1); // Adjust the multiplier as needed
    float s = sin(a + audioAmplitude * 0.1); // Adjust the multiplier as needed
    return p * mat2(c, s, -s, c);
}


// Fractal shape function
float fractalShape(vec2 u, float t, float audioAmplitude, float rotationSpeed) {
    float n = sin(u.x) * cos(u.y);
    float b;
    
    u = abs(u * 2.0);
    b = u.x;
    
    vec2 a = vec2(2.0 - u);
    
    float param1 = 0.25 + audioAmplitude * 0.9; // Adjust the multiplier as needed
    float param2 = 0.62 + audioAmplitude * 0.9; // Adjust the multiplier as needed
    
    for (int i = 0; i < 15; i++) {
        a += u + cos(length(u));
        u.y += sin(a.x - b - 0.5 * t) * param1;
        u.x += sin(a.y + t) * param2;
        u -= (u.x + u.y) - n;
        a.x += u.x;
    }
    
    return length(u) * 0.1;
}

void mainImage(out vec4 O, in vec2 fragCoord) {
    vec2 R = iResolution.xy;
    vec2 u = (fragCoord * 2.0 - R) / R.y * 2.0 - vec2(0.0, 1.3);
    u = u.yx;
    
    float t = 1.93 + iTime * 0.5;
    
    // Get the audio amplitude from the input texture
    float audioAmplitude = texture(iChannel0, vec2(0.1)).r;
    
    // Calculate the fractal shape value
    float fractalValue = fractalShape(u, t, audioAmplitude, 0.5);
    
    // Calculate the rotation angle based on the audio amplitude for medium frequency
    float rotationAngle = audioAmplitude * 0.5; // Adjust the multiplier as needed
    
    // Apply rotation to the point
    u = rotate(u, rotationAngle, audioAmplitude);
    
    // Define parameters to control color change with audio interaction
    vec3 lowFrequencyColor = vec3(0.2, 0.0, 1.0); // Purple color for low frequency
    vec3 highFrequencyColor = vec3(1.0, 0.2, 0.8); // Pink color for high frequency
    
    // Calculate the color gradient based on the audio amplitude
    vec3 color = mix(lowFrequencyColor, highFrequencyColor, audioAmplitude);
    
    // Mix color gradient with black based on the fractal value
    vec3 finalColor = mix(vec3(0.0), color, fractalValue);
    
    O = vec4(finalColor, 1.0);
}






