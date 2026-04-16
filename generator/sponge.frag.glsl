precision mediump float;

float Box(vec3 pos, vec3 b)
{
    vec3 d = abs(pos) - b;
    return min(max(d.x,max(d.y,d.z)), .0) + length(max(d, .0));
}

float Map(vec3 p)
{  
    const float Iter = 40.;
    const float BoxWidth = 4.;
    float HoleWidth = BoxWidth * .333;
    float Menger = Box(p, vec3(BoxWidth));
       
    for (int i=0; i<5; i++)
    {
        float HoleDist = HoleWidth * 2.8;
        vec3 c = vec3(HoleDist);
        vec3 q = mod(p + vec3(HoleWidth), c) - vec3(HoleWidth);
        vec3 Hole = vec3(Box(q, vec3(Iter, HoleWidth, HoleWidth)), Box(q, vec3(HoleWidth, Iter, HoleWidth)), Box(q, vec3(HoleWidth, HoleWidth, Iter)));
        HoleWidth *= .1667; 
        Menger = max(max(max(Menger, -Hole.x), -Hole.y), -Hole.z);
    }
    
    return Menger;
}

float Tracer(vec3 Origin, vec3 Ray)
{
    float t;
    
    for (int i=0; i<32; ++i)
    {
        float d = Map(Origin + Ray * t);
        t += d;
    }
    
    return t;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 p = (fragCoord.xy / iResolution.xy) * 2. - 1.;     
    p.x *= iResolution.x/iResolution.y;     
        
    // Sound (see shadertoy.com/view/Xds3Rr)
    float fft_BassDrum;
    
    for (int n = 0; n<10; n++)
    {
        fft_BassDrum += texelFetch(iChannel0, ivec2(n, 0), 0).x;
    }
    
    fft_BassDrum /= 9.; //normalize
    
    vec3 Ray = normalize(vec3(p.xy, 2.));
    vec3 Origin = vec3(0, 0, -6. - 5.2 * sin(iTime * .4));
    
    float TempSin = sin(iTime);
    float TempCos = cos(iTime);
    mat2 Rotation = mat2(TempCos, -TempSin, TempSin, TempCos);
    
    Ray.yz *= Rotation;
    Ray.xy *= Rotation;
    Origin.yz *= Rotation;
    Origin.xy *= Rotation;
       
    float Temp = Tracer(Origin * fft_BassDrum, Ray * fft_BassDrum);    
    fragColor = vec4(vec3(2. / (2. + Temp * Temp * .05)) * vec3(.8 + .2 * sin(iTime * .1), .8 + .2 * sin(iTime * 1.), .9 + .1 * cos(iTime * 1.)), 1.);
}