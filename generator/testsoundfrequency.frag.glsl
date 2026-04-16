float bdBar(in vec2 p, in vec4 r, float s) {
    vec4 v4 = vec4(r.xy, 1. - (r.xy + r.zw));
    vec4 f = smoothstep(v4 - s, v4 + s, vec4(p, 1. - p));
    return f.x * f.y * f.z * f.w;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (2. * fragCoord - iResolution.xy) / iResolution.y;

    const float st = 1. / 32.;
    vec3 col = vec3(0.);
    
    for (int i = 0; i < 32; i++) {
        float freq = clamp(pow(texture(iChannel0, vec2(float(i) / 32., 0.)).x, 1.5), 0., 1.);
        float cst = float(i) * st;
        float bar = bdBar(uv + .5, vec4(cst, 0., .01, freq), .002);
        col += vec3(freq, cst, 0.) * bar;
    }
    
    col = pow(col, vec3(.454545));
    
    fragColor = vec4(col, 1.);
}