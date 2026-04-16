// Visualizer config: appearance
#define POW_EXPONENT      10.0         // Set to 1.0, if you want see real value
#define POW_SCALE         64.0         // Pow scale value. SCALE / pow(...)
#define POW_SCALE_AUTO                 // Uncomment if you want it to auto calculate scale
#define POW_SCALE_AUTO_F   0.8         // Auto scale factor
#define EQ_PERIOD          8           // Visualizer lines period
#define EQ_WIDTH           2           // Thickness of a single line
#define EQ_COLOR           vec4(.7)    // Color of the visualizer
//#define EQ_EMPTY                     // Uncomment to make inner part of visualizer empty
//#define BLUR                         // Blur effect, suddenly it doesn't work
#define EQ_RED             vec4(0.025) // Hexagon color
#define EQ_NRED            vec4(0.025) // -Hexagon color
#define GRAD_SCL           1.6         // Gradiend scalar

// Visualizer config: math
#define SOUNDV             .25        // V-coordinate of sound channel mapping     

// Ne trogai
#ifdef POW_SCALE_AUTO
	#undef POW_SCALE
	#define POW_SCALE iResolution.y / 2.0 * POW_SCALE_AUTO_F
#endif

// Global fields, redefine
void renderOscill(out vec4 fragColor, in vec2 fragCoord) {
    int period = int(fragCoord.x);
    if(period % EQ_PERIOD >= EQ_WIDTH)
        return;
    period /= EQ_PERIOD;
    
	float fragc = fragCoord.x / iResolution.x;
    float frags = texture(iChannel0, vec2(float(period) * float(EQ_PERIOD) / iResolution.x, SOUNDV)).x;
    
    float screenY = iResolution.y / 2.0;
    int fragsv  = int(frags * POW_SCALE / pow(POW_EXPONENT, fragc));
    fragsv = fragsv < 1 ? 1 : fragsv;
    
    if(fragCoord.y < screenY + float(fragsv) && fragCoord.y > screenY - float(fragsv)) 
        #ifdef EQ_EMPTY
        	if(fragCoord.y > screenY + float(fragsv - 2) || fragCoord.y < screenY - float(fragsv - 2))
        		fragColor += EQ_COLOR;
        #else
        	fragColor += EQ_COLOR;
        #endif
}

float signv(vec2 p1, vec2 p2, vec2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool inTriangle(vec2 p, vec2 pos, float d) {
    float side2 = d * 0.866025405;
    vec2 v1 = vec2(pos.x,         pos.y + d);
    vec2 v2 = vec2(pos.x - side2, pos.y - d / 2.0);
    vec2 v3 = vec2(pos.x + side2, pos.y - d / 2.0);
    
    bool b1, b2, b3;
    b1 = signv(p, v1, v2) < 0.0;
    b2 = signv(p, v2, v3) < 0.0;
    b3 = signv(p, v3, v1) < 0.0;
    
    return (b1 == b2) && (b2 == b3);
}

bool inHexagon(vec2 p, vec2 pos, float d, float a) {
    float x_ = pos.x - p.x;
    float y_ = pos.y - p.y;
    float s_ = sin(a);
    float c_ = cos(a);
    float dx = abs(x_ * c_ - y_ * s_)/d;
    float dy = abs(x_ * s_ + y_ * c_)/d;
    float ar = 0.25 * sqrt(3.0);
    return (dy <= ar) && (ar * dx + 0.25 * dy <= 0.5 * ar);
}

void renderBackground(out vec4 fragColor, in vec2 fragCoord) {
	float grad = 1.0 - length(fragCoord - iResolution.xy / 2.0) / length(iResolution.xy) * GRAD_SCL;
    fragColor += grad / 3.0;

    float d = 0.33 * iResolution.y;
	vec2 center = iResolution.xy / 2.0;

    if(inTriangle(fragCoord, center, d * (0.8 + 0.8 * texture(iChannel0, vec2(0.0)).x))) 
        fragColor -= 0.1;
    if(inHexagon(fragCoord, center, d, iTime))
        fragColor += EQ_RED;
    if(inHexagon(fragCoord, center, d * 2.0, -iTime * 0.5))
        fragColor -= EQ_NRED;
    if(inHexagon(fragCoord, center, d * 3.0, iTime  * 0.6))
        fragColor += EQ_RED;
    if(inHexagon(fragCoord, center, d * 4.0, -iTime * 0.7))
        fragColor -= EQ_NRED;
    if(inHexagon(fragCoord, center, d * 5.0, iTime  * 0.8))
        fragColor += EQ_RED;
    if(inHexagon(fragCoord, center, d * 6.0, -iTime * 0.9))
        fragColor -= EQ_NRED;
    if(inHexagon(fragCoord, center, d * 7.0, iTime  * 1.0))
        fragColor += EQ_RED;
    if(inHexagon(fragCoord, center, d * 8.0, -iTime * 1.1))
        fragColor -= EQ_NRED;
}

void blur(out vec4 fragColor, in vec2 fragCoord) {
    fragColor += texture(iChannel1, fragCoord / iResolution.xy) * 0.1;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	fragColor = vec4(0.0);
    renderBackground(fragColor, fragCoord);
    renderOscill(fragColor, fragCoord);
    
    #ifdef BLUR
    	blur(fragColor, fragCoord);
    #endif
}
