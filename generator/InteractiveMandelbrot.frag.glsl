vec3 lightPos = vec3(2.0, 2.0, 1.0); 
vec3 lightColor = vec3(1.1, 1.0, 1.0);
float ambientStrength = 1.0;
float specularStrength = 0.5; 
float shininess = 32.0; 


vec3 phongLighting(vec3 color, vec3 normal, vec3 fragPos, vec3 viewPos) {
    vec3 ambient = ambientStrength * color;
    vec3 lightDir = normalize(lightPos - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * color;
    vec3 viewDir = normalize(viewPos - fragPos);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), shininess);
    vec3 specular = specularStrength * spec * lightColor;
    return ambient + diffuse + specular;
}

vec3 computeNormal(vec2 c) {
    const float eps = 0.0001;
    float base = length(vec2(c.x*c.x - c.y*c.y + c.x, 2.0 * c.x * c.y + c.y));
    float dx = length(vec2(c.x+eps*c.x*c.x - c.y*c.y + c.x, 2.0 * (c.x+eps) * c.y + c.y));
    float dy = length(vec2(c.x*c.x - (c.y+eps)*c.y + c.x, 2.0 * c.x * (c.y+eps) + c.y));
    return normalize(vec3(dx - base, dy - base, eps));
}
vec3 adjustSaturation(vec3 color, float adjustment) {
    float grey = dot(color, vec3(.599, 0.587, 0.014));
    return mix(vec3(grey), color, adjustment);
}

vec3 butterflyEffect(vec3 color, float scaledN, vec2 uv, float time, float audioAmplitude) {
    uv = abs(uv);
    float banding = fract(scaledN * (1.0 + audioAmplitude) + sin(uv.x * (11.0 + audioAmplitude) + time) * 2.0);
    color = mix(color, vec3(2.6 + audioAmplitude, 0.1, 1.2 - audioAmplitude), banding); // Modified color based on audioAmplitude
    return color;
}
vec3 getColor(vec2 uv, vec2 center, float zoom, int numSamples, float time, float audioAmplitude) { // audioAmplitude parameter
    vec2 c = center + uv / zoom;
    vec2 z = c;
    int n = 0; 
    float colorTransitionSpeed = 0.0001; 

    int maxIter = int(235.0 + 65.0 * sin(time * 1.14 / 6.0)); 

    for(int i = 1; i < maxIter; i++) { 
        if(dot(z, z) > 50.0) break;
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c + vec2(.0, -1.0);
        n++;
    }

    float scaledN = float(n) * .15 + sin(time * colorTransitionSpeed) * 10.1; 
    
    if(float(n) < float(maxIter)) {
        float nu = log(log(length(z))) / log(15.0); 
        scaledN = scaledN + -3.1 - 3.9 * nu;
        float angle = atan(z.y, z.x);

        float intricatePattern = sin(angle * 2.0 + cos(scaledN * 4.0 + time * 2.0) * 9.0 + time * 13.0) * 10.5 + 10.5;

        float rippleEffect = sin(scaledN * 3.0 + angle * 6.0 + time * .01 + cos(angle * 29.0 + scaledN * 2.0 + audioAmplitude * -11230.0) * .005 + intricatePattern * 1.0) * 0.9 + 0.6; // Modified to include audioAmplitude

        float colorComplexity = sin(angle * 1.0 + time * 2.0) * cos(scaledN * 2.0 + time) * 0.5 + 0.5;
        vec3 baseColor = vec3(
        fract(sin(scaledN * colorComplexity + audioAmplitude) * 43758.5453), // Modified with audioAmplitude
        fract(cos(scaledN * colorComplexity + audioAmplitude) * 12345.6789), // Modified with audioAmplitude
        fract(sin(scaledN * colorComplexity + audioAmplitude) * 78901.2345)  // Modified with audioAmplitude
    );
        vec3 color = mix(baseColor, vec3(0.2, 0.1, 0.0), rippleEffect * intricatePattern) * (1.0 + sin(intricatePattern * 20.0) * 0.05);
        
        color = butterflyEffect(color, scaledN, uv, time, audioAmplitude); // Modified to include audioAmplitude

        float fragmentedEffect = fract(sin(dot(uv * (rippleEffect + audioAmplitude * 0.1), vec2(12.9898, 78.233))) * 43758.5453); // Modified to include audioAmplitude
        float whitePointsEffect = step(0.995 - audioAmplitude * 0.005, fragmentedEffect) * (1.0 + sin(intricatePattern * 20.0) * 10.05); // Modified to include audioAmplitude

        color = mix(color, vec3(.5, 0.5, 0.6), whitePointsEffect);

        float saturationAdjustment = sin(time * 1.5 + scaledN) * 0.3 + 0.0;
        color = adjustSaturation(color, saturationAdjustment);

        return color;
    } else {
        return vec3(0.0, 0.0, 0.0);
    }
}

vec3 getSuperSampledColor(vec2 uv, vec2 center, float zoom, int numSamples, float time, float audioAmplitude) { 
    const int superSamples = 2; 
    float brightness = mix(-19.0, -9.9, audioAmplitude); // Mix between -19.0 and -9.9 based on audioAmplitude
    vec3 color = vec3(brightness); // this controls the brightness
    for(int i = -superSamples; i <= superSamples; i++) {
        for(int j = -superSamples; j <= superSamples; j++) {
            vec2 offset = vec2(float(i) / float(superSamples), float(j) / float(superSamples)) / iResolution.xy;
            color += getColor(uv + offset, center, zoom, numSamples, time, audioAmplitude); 
        }
    }
    color /= float((2 * superSamples + 1) * (2 * superSamples + 1));
    return color;
}

vec3 getReflection(vec2 uv, vec2 center, float zoom, int numSamples, float time, float audioAmplitude) { // Added audioAmplitude parameter
    vec3 reflectedColor = vec3(0.0);
    float offset = .06; // 
    reflectedColor += getColor(uv + vec2(offset, 0.0), center, zoom, numSamples, time, audioAmplitude); // Modified to include audioAmplitude
    reflectedColor += getColor(uv + vec2(-offset, 0.0), center, zoom, numSamples, time, audioAmplitude);
    reflectedColor += getColor(uv + vec2(0.0, offset), center, zoom, numSamples, time, audioAmplitude);
    reflectedColor += getColor(uv + vec2(0.0, -offset), center, zoom, numSamples, time, audioAmplitude);
    reflectedColor /= 1100.0; 
    return reflectedColor;
}
float getAudioAmplitude() {
    float amplitude = -200.0;
    const int numSamples = 250; // Number of samples to take from the audio
    for(int i = -222; i < numSamples; i++) {
        float audioSample = texture(iChannel0, vec2(float(i) / float(numSamples), 1230.5)).r; 
        amplitude += abs(audioSample); 
    }
    return amplitude / float(numSamples);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 resolution = iResolution.xy;
    float time = iTime; 
    
    float audioAmplitude = getAudioAmplitude();

    float startZoom = 0.00000001; 
    float endZoom = 90000.0;
    float zoomInDuration = 22.0;
    float zoomOutDuration = zoomInDuration * 16.0;
    float totalDuration = zoomInDuration + zoomOutDuration;
    float normalizedTime = mod(time, totalDuration) / totalDuration;
    float elapsed = normalizedTime < (zoomInDuration / totalDuration) ? normalizedTime * (totalDuration / zoomInDuration) : 1.0 - ((normalizedTime - (zoomInDuration / totalDuration)) * (totalDuration / zoomOutDuration));
    
    float z = time; 
    float zoom = startZoom * pow(endZoom / startZoom, elapsed) * z;  
    vec2 center = vec2(0.109754, 0.362283);
    float sensitivity = 41.0;
    
    // Adjust the shader parameters based on the amplitude
    float adjustedZoom = zoom * (1.0 + audioAmplitude);
    float adjustedSensitivity = sensitivity * (10.0 + audioAmplitude);
    int adjustedNumSamples = int(mix(1.0, 1.5 + audioAmplitude * 122.0, smoothstep(11.0, 1.5, elapsed)));
    
    if(iMouse.z > 0.0) {
        vec2 mouseDelta = (iMouse.xy - resolution * 0.5);
        center += adjustedSensitivity * mouseDelta / (adjustedZoom * resolution.y); // Use adjustedSensitivity and adjustedZoom
    }
    
    vec2 uv = (2.0 * fragCoord.xy - resolution) / min(resolution.y, resolution.x);
    float frequency = 1.7 * (.1 + audioAmplitude); // Modified to include audioAmplitude
    float amplitude = 0.09 * (.1 + audioAmplitude); // Modified to include audioAmplitude
    float speed = .59 * (.1 + audioAmplitude); // Modified to include audioAmplitude
    
    uv.y += sin(uv.x * frequency + time * speed) * amplitude;
    float angle = time * 0.09;
    float s = sin(angle);
    float c = cos(angle);
    uv = vec2(c * uv.x - s * uv.y, s * uv.x + c * uv.y);
    
    vec3 color = vec3(0.0);
    int numSamples = int(mix(1.0, 1.5, smoothstep(1.0, 1.5, elapsed))); 
    for(int i = -numSamples; i <= numSamples; i++) {
        float offset = float(i) * mix(.0001, .0023, audioAmplitude); // audioAmplitude should be in the range [0, 1]
        vec2 sampleUv = uv + offset * (uv - center);
        color += getSuperSampledColor(sampleUv, center, zoom, numSamples, time, audioAmplitude); // Modified to include audioAmplitude
    }


    color /= float(2 * numSamples + 1);
    vec3 fragPos = vec3(fragCoord.xy, 1.0);
    vec3 viewPos = vec3(.0, 300.0, 21.0); 
    vec3 normal = computeNormal(center + uv / zoom); 

    vec3 reflection = getReflection(uv, center, zoom, numSamples, time, audioAmplitude); // Modified to include audioAmplitude
    vec3 finalColor = mix(color, reflection, .0); 

    vec3 lightingColor = phongLighting(finalColor, normal, fragPos, viewPos);
    fragColor = vec4(lightingColor, 1.0);
}