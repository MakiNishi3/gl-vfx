float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

void mainImage( out vec4 o, in vec2 p ) {
    p /= iResolution.xy;
    p -= 0.5;
    p.x *= iResolution.x / iResolution.y;
    
    p.y += 0.5;
    
    
    p.x /= 1.0 + abs(texture(iChannel0, vec2(0.0, p.x)).r - 0.5);
    
    float result = 1.0 - length(p);
    p.y += cos(p.x * 10.0 + iTime * 5.0) * 0.25;
    
    result = smin(result, p.y, 0.25);
    result -= abs(p.x) * 2.5;
    result = smoothstep(0.0, 0.01, result);
    
    
    o.rgb = vec3(0.0);
    o.rgb += result * vec3(p.y + 0.1, 0.35, 0.25);
    o.rgb += result * vec3(mod(p.x, 0.5) * vec3(0.0, 1.0, 0.0));
    o.rgb += (1.0 - result) * vec3(abs(p.x * 2.0 + sin(iTime) * 0.25), abs(p.x * 1.25), 0.25);
	o.rgb += (1.0 - result) * vec3(0.0, abs(mod(p.y, 0.25)), 0.0);
    o.rgb += (1.0 - result) * vec3(abs(mod(p.x * 2.0 + iTime, 0.05))) * 3.0;
}