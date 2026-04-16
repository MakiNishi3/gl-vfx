#define M_PI 	3.14159265358979323846
#define M_PI_2  1.57079632679489661923
#define M_2_PI  6.28318530717958647692

mat2 rotate2D(float angle)
{
   	float cosTheta = cos(angle);
    float sinTheta = sin(angle);
    
    return mat2(
        vec2(cosTheta, sinTheta), 
        vec2(-sinTheta, cosTheta));
}

// Noise shamlessly storen from iq
float noise(vec3 x) 
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = textureLod( iChannel1, (uv+ 0.5)/256.0, 0.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

float noise(in vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	vec2 uv = p.xy + f.xy*f.xy*(3.0-2.0*f.xy);
	return texture( iChannel1, (uv+118.4)/256.0, -100.0 ).x;
}

float fbm(vec2 p)
{
	p += vec2(1.0,0.1) * iTime*0.5;
    
    float f;
    f  = 0.5000 * noise(p); p = p * 2.02;
    f += 0.2500 * noise(p); p = p * 2.03;
    f += 0.1250 * noise(p); p = p * 2.01;
    f += 0.0625 * noise(p);
    return f;
}

float f(vec2 uv, vec2 centre, float radius, float power)
{
    vec3 a = vec3(uv, radius);
    vec3 b = vec3(centre, 0.0);
    
    return dot(pow(abs(a-b), vec3(power)), vec3(1.0, 1.0, -1.0));
}

vec2 grad_f(in vec2 x, vec2 centre, float radius, float power)
{
    vec2 h = vec2( 0.001, 0.0 );
    return vec2( f(x+h.xy, centre, radius, power) - f(x-h.xy, centre, radius, power),
                 f(x+h.yx, centre, radius, power) - f(x-h.yx, centre, radius, power) ) / (2.0*h.x);
}

float opU( float d1, float d2 )
{
	return (d1 < d2) ? d1 : d2;
}

float segment(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return length( pa - ba*h );
}

float sq(vec2 uv, vec2 centre, float radius, float power)
{
	float v = f(uv, centre, radius, power);
    vec2 g = grad_f(uv, centre, radius, power);
    return v/length(g);    
}

void addScene(inout vec3 col, vec3 c, float de)
{
	col = mix(c, col, smoothstep(0.0, 2.5/iResolution.x, de));    
}

void addScene(inout vec3 col, vec3 c, float de, float width)
{
	col = mix(c, col, smoothstep(0.0, width, de));    
}

float avgFreq(int grid, int gridSize)
{
    float freq = 0.0;
    for (int i = 0; i < 4; i++)
    {
        float offset = (float(i) / (4.0)) + 0.5;
        float samplePos = (float(grid-1) + offset) / float(gridSize);
        freq += texture(iChannel0, vec2(samplePos, 0.25)).x;
    }
    
    return freq / 4.0;
}

vec3 getPalette(float p)
{
    float m = 0.8;
    float n = 0.1;
    
    p = sqrt(p);
    
    float range[5];
    range[0] = 0.00;
    range[1] = 0.40;
    range[2] = 0.50;
    range[3] = 0.60;
    range[4] = 1.00;
    
    if (p <= range[1]) 
    {
        float v = (p - range[0]) / (range[1] - range[0]);
        return mix(vec3(n, n, m), vec3(n, m, m), v); 
    }
    
    if (p <= range[2]) 
    {
        float v = (p - range[1]) / (range[2] - range[1]);
        return mix(vec3(n, m, m), vec3(n, m, n), v); 
        
    }    
    
    if (p <= range[3]) 
    { 
        float v = (p - range[2]) / (range[3] - range[2]);
        return mix(vec3(n, m, n), vec3(m, m, n), v); 
    }    
    
    if (p <= range[4]) 
    {
        float v = (p - range[3]) / (range[4] - range[3]);
        return mix(vec3(m, m, n), vec3(m, n, n), v); 
    }    
    
    return vec3(p,0,1.0-p);
}

void addRingBloom(
    inout vec3 col, 
    vec2 coord, 
	float freq, 
    float ringRadius, 
    float ringSize, 
    float s, 
    float total,
    float sqRadius,
	float offsetRotate)
{
 	vec3 c = getPalette(freq);
   
    mat2 midRotate = rotate2D(offsetRotate + (M_2_PI / total) * (s + 0.5));
    vec2 q = midRotate*coord;
    vec2 mid = vec2(0.0, ringRadius + ringSize*0.5);
    
    vec3 bloom = mix(c, vec3(1,1,1), 0.70);
    
    addScene(col, bloom, sq(q, mid - vec2(0.0, sqRadius*0.125), sqRadius, 0.5+(freq*freq)*3.5), sqRadius*1.5);        
}
    

void addRingSegment(
    inout vec3 col, 
    vec2 coord, 
    float freq, 
    float ringRadius, 
    float ringSize, 
    float s, 
    float total, 
    float sqRadius,
	float offsetRotate)
{
    float angle0 = offsetRotate + (M_2_PI / total) * s;
    float angle1 = offsetRotate + (M_2_PI / total) * (s + 1.0);
        
 	vec2 inner0 = vec2(0.0, ringRadius) * rotate2D(angle0);
    vec2 inner1 = vec2(0.0, ringRadius) * rotate2D(angle1);

    vec2 outer0 = vec2(0.0, ringRadius) * rotate2D(angle0);
    vec2 outer1 = vec2(0.0, ringRadius) * rotate2D(angle1);
	
    vec3 c = getPalette(freq);
    
    mat2 midRotate = rotate2D(offsetRotate + (M_2_PI / total) * (s + 0.5));
    vec2 q = midRotate*coord;
    vec2 mid = vec2(0.0, ringRadius + ringSize*0.5);
    
    float de = sq(q, mid - vec2(0.0, sqRadius*0.125), sqRadius, 0.5+(freq*freq)*3.5);
    
    vec3 ac = mix(c, vec3(1,1,1), 0.5);
    c = mix(c, ac, smoothstep(0.0, 2.5/iResolution.x, abs(de)));
    
    addScene(col, c, de);    
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float aspect = iResolution.x/iResolution.y;
    vec3 col = vec3(1.0, 1.0, 1.0);
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    vec2 coord = -1.0 + 2.0*uv;
    coord.y /= aspect;

    float ro[4];
    ro[0] = 0.10;
    ro[1] = 0.21;
    ro[2] = 0.32;
    ro[3] = 0.43;
    
    float rs[4];
    rs[0] = 0.10;
    rs[1] = 0.10;
    rs[2] = 0.10;
    rs[3] = 0.10;
    
    vec3 bc = vec3(0.9, 0.9, 0.9);
    addScene(col, bc, abs(sq(coord, vec2(0,0), ro[0], 2.0)));      
    addScene(col, bc, abs(sq(coord, vec2(0,0), ro[1], 2.0)));
    addScene(col, bc, abs(sq(coord, vec2(0,0), ro[2], 2.0)));
    addScene(col, bc, abs(sq(coord, vec2(0,0), ro[3], 2.0)));
    addScene(col, bc, abs(sq(coord, vec2(0,0), ro[3]+rs[3], 2.0)));
    
    // Ring 0
    float ring0 = avgFreq(1, 30);
    const int numSegments0 = 24;
    
    for (int i = 0; i < numSegments0; i++)
    {
        if (float(i) / float(numSegments0-1) >= ring0) { break; }
        addRingBloom(col, coord, ring0, ro[0], rs[0], float(i), float(numSegments0), 0.015, iTime);
    }
    
    for (int i = 0; i < numSegments0; i++)
    {
        if (float(i) / float(numSegments0-1) >= ring0) { break; }
        addRingSegment(col, coord, ring0, ro[0], rs[0], float(i), float(numSegments0), 0.015, iTime);
    }
    
    // Ring 1
    float ring1 = avgFreq(10, 30);
    const int numSegments1 = 28;

    for (int i = 0; i < numSegments1; i++)
    {
        if (float(i) / float(numSegments1-1) >= ring1) { break; }
        addRingBloom(col, coord, ring1, ro[1], rs[1], float(i), float(numSegments1), 0.020, iTime*1.5);
    }
    
    for (int i = 0; i < numSegments1; i++)
    {
        if (float(i) / float(numSegments1-1) >= ring1) { break; }
        addRingSegment(col, coord, ring1, ro[1], rs[1], float(i), float(numSegments1), 0.020, iTime*1.5);
    }
    
    // Ring 2
    float ring2 = avgFreq(20, 30);
    const int numSegments2 = 32;
    
    for (int i = 0; i < numSegments2; i++)
    {
        if (float(i) / float(numSegments2-1) >= ring2) { break; }
        addRingBloom(col, coord, ring2, ro[2], rs[2], float(i), float(numSegments2), 0.025, iTime*2.0);
    }      
    
    for (int i = 0; i < numSegments2; i++)
    {
        if (float(i) / float(numSegments2-1) >= ring2) { break; }
        addRingSegment(col, coord, ring2, ro[2], rs[2], float(i), float(numSegments2), 0.025, iTime*2.0);
    }    
    
    // Ring 3
    float ring3 = avgFreq(30, 30);
    const int numSegments3 = 32;
    
    for (int i = 0; i < numSegments3; i++)
    {
        if (float(i) / float(numSegments3-1) >= ring3) { break; }
        addRingBloom(col, coord, ring3, ro[3], rs[3], float(i), float(numSegments3), 0.030, iTime*2.5);
    }     
    
    for (int i = 0; i < numSegments3; i++)
    {
        if (float(i) / float(numSegments3-1) >= ring3) { break; }
        addRingSegment(col, coord, ring3, ro[3], rs[3], float(i), float(numSegments3), 0.030, iTime*2.5);
    }      
    
    
    fragColor = vec4(col, 1.0);

}