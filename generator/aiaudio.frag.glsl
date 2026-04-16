// Retorna a intensidade dos agudos e médios
float getIntensity() {
    float intensity = 0.0;
    for(int i = 80; i < 200; i++) { 
        intensity += texture(iChannel0, vec2(float(i)/200.0, 0.5)).r;
    }
    return intensity / 120.0;
}

vec3 generateStars(vec2 coord, float intensity) {
    coord *= 1.0 + 0.5 * intensity; 
    float starValue = fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
    float threshold = 0.998 - intensity * 0.002;
    return vec3(step(threshold, starValue));
}

vec3 generateTexture(vec2 coord) {
    float bassIntensity = 0.0;
    for(int i = 0; i < 100; i++) {
        bassIntensity += texture(iChannel0, vec2(float(i)/100.0, 0.5)).r;
    }
    bassIntensity /= 100.0;

    float col = bassIntensity * (0.5 + 0.5*sin(iTime + coord.y*10.0) + 0.5*cos(iTime + coord.x*10.0));
    return vec3(col);
}

vec3 getSphereNormal(vec2 coord) {
    float lon = mix(-3.14159265, 3.14159265, coord.x);
    float lat = mix(-1.57079633, 1.57079633, coord.y);
    vec3 normal;
    normal.x = cos(lat) * sin(lon);
    normal.y = sin(lat);
    normal.z = cos(lat) * cos(lon);
    return normal;
}

void mainImage( out vec4 fragColor, vec2 fragCoord )
{
    vec2 p = fragCoord/iResolution.xy;

    vec3 normal = getSphereNormal(p);

    float angleX = (iMouse.x / iResolution.x) * 3.14159265;
    float angleY = (iMouse.y / iResolution.y) * 3.14159265;

    mat2 rotationX = mat2(
        cos(angleX), -sin(angleX),
        sin(angleX), cos(angleX)
    );

    mat2 rotationY = mat2(
        cos(angleY), -sin(angleY),
        sin(angleY), cos(angleY)
    );

    normal.xz = rotationX * normal.xz;
    normal.yz = rotationY * normal.yz;

    vec2 sphereCoord = vec2(
        0.5 + atan(normal.z, normal.x) / (2.0 * 3.14159265),
        0.5 - asin(normal.y) / 3.14159265
    );

    vec3 col = generateTexture(sphereCoord);

    // Calcula a intensidade
    float intensity = getIntensity();
    
    // Calcula as estrelas baseadas na intensidade
    vec3 stars = generateStars(fragCoord, intensity);

    col += stars;

    col = clamp(col, 0.0, 1.0);

    fragColor = vec4(col, 1.0);
}

