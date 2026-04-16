/*Music: Lilith's Club by Noisia (Devil May Cry OST)*/

float fft = 0.0;

mat2 Rot(float a)
{
	float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float DrawHex(vec2 p)
{;
	p = abs(p);
    float c = dot(p, normalize(vec2(1.0, 1.73)));
    c = max(c, p.x);
    return c;
}

float Hash21(vec2 p)
{
	p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

vec3 HexesLayer(vec2 uv)
{
	vec3 col = vec3(0);
    
    vec2 gv = fract(uv) - 0.5; //tiling and making the middle of each tile the origin
	vec2 id = floor(uv);
    
    for (int y = -1; y <= 1; ++y)
    {
    	for (int x = -1; x <= 1; ++x)
        {
        	vec2 offs = vec2(x, y);
            float rand = Hash21(id + offs);
            float hex = smoothstep(clamp(fft, 0.3, 1.0), 0.1, DrawHex(gv-offs- vec2(rand, fract(rand * 40.0)) + 0.5));
        	vec3 color = (sin(vec3(0.2, 0.3, 0.9) * fract(rand * 6531.3) * 532.4) * 0.5 + 0.5);
            
           	col += hex * color;
        }
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - 0.5 * iResolution.xy)/iResolution.y;
	uv *= 5.0;
    
    // read frequency data from first row of texture
    //change the first value of the vec2 to influence the blinking effect
    fft  = texture(iChannel0, vec2(0.01, 0.0)).x;
    
    float t = iTime * 0.2;
    
    uv *= Rot(sin(t * 2.0));
	vec3 col = vec3(0);
    
    float LayerCount = 1.7;
    
    for (float i = 0.0; i < 1.0; i+= 1.0 / LayerCount)
    {
        float depth = fract(i + t);
        float scale = mix(5., 0.5, depth);
    	col += HexesLayer(uv * scale + (i * 1000.0)) * (depth * smoothstep(1.0, 0.96, depth));
    }
   
    // Output to screen
    fragColor = vec4(col,1.0);
}
