#define LINE_WIDTH 2.


void mainImage( out vec4 O, in vec2 I ) {
    
    vec2 uv = I/iResolution.xy;
        
    float dx = 1./iResolution.x;
    
    float v = texture(iChannel0, vec2(uv.x, 1.)).r;
    float vp = texture(iChannel0, vec2(uv.x+dx, 1.)).r;
    float vm = texture(iChannel0, vec2(uv.x-dx, 1.)).r;
    
    vec2 p  = vec2(uv.x, v );
    vec2 pp = vec2(uv.x+dx, vp);
    vec2 pm = vec2(uv.x-dx, vm);
    
    vec2 np = normalize(pp-p);
    vec2 nm = normalize(p-pm);
    
    float d = max(abs(np.x), abs(nm.x));
    
    float k = mix(1.,0., (abs(uv.y-v)*iResolution.y-LINE_WIDTH+1.) * d);
    
    vec3 c = vec3(k);
    
    O = vec4(c, 1.0);
}
