vec3 orientation;

float dt = 0.0;
float totaldt = 0.0;
float accumulator = 0.0;
float fft = 0.0;

const float ln2 = log(2.0);
const float meanFreq = 4.0;
const float mean = meanFreq * .69314718;
const float stdDev = 2.0;
const float pi = 4.0 * atan(1.0);
const float pi2 = 2.0 * pi;

float smoothWave(int n, float x){
    float l = ln2 * float(n) + log(x);
    l -= mean;
    return exp(-l * l / stdDev) / 2.0;
}

float opU( float d1, float d2 )
{
    return min(d1,d2);
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

float sdSphere( vec3 p, float s )
{
	return length(p)-s;
}

float terrainFunction(vec3 pos, vec4 t1, vec4 t2)
{
    float d = sin(iTime / 20.0) * 0.5 + 0.75;
    vec3 c = vec3(d);
    pos = mod(pos, c) - 0.5 * c;
        
    float time = iTime * 1.0;
    float p1 = 1.0 + (cos(dt + t1[0] * t2[0]) * 1.5);
    //p1 *= 5.2;

  	float d2 = p1 + p1 + totaldt;
    pos *= sqrt((d2 * d2) + (d2 * d2));

    vec3 nPos1 = vec3(pos.x, pos.y - 1.0, pos.z);
    vec3 nPos2 = vec3(pos.x, pos.y + 1.0, pos.z);
    vec3 nPos3 = vec3(pos.x, pos.y, pos.z + 1.0);
    vec3 nPos4 = vec3(pos.x, pos.y, pos.z - 1.0);
    vec3 nPos5 = vec3(pos.x + 1.0, pos.y, pos.z);
    vec3 nPos6 = vec3(pos.x - 1.0, pos.y, pos.z);
    
    return -
        opS(sdSphere(nPos6, 0.33321),
        opS(sdSphere(nPos5, 0.5),
        opS(sdSphere(nPos4, 0.3),
        opS(sdSphere(nPos3, 0.5),
        opS(sdSphere(nPos2, 0.7),
        opS(sdSphere(nPos1, 0.2),
        sdSphere(pos, 1.0)))))));
}

vec3 normalAt(vec3 pos, vec4 t1, vec4 t2)
{
    float epsilon = 0.01;
    
    float b = 0.0;
    float s = terrainFunction(pos, t1, t2);
    float dx = s - terrainFunction(vec3(pos.x + epsilon, pos.y, pos.z), t1, t2);
    float dy = s - terrainFunction(vec3(pos.x, pos.y + epsilon, pos.z), t1, t2);
    float dz = s - terrainFunction(vec3(pos.x, pos.y, pos.z + b + epsilon), t1, t2);
                                   
    return normalize(vec3(dx, dy, dz));
}


float march(vec3 offset, vec3 dir, vec4 t1, vec4 t2)
{
    const float minDist = 1.0;
    const float maxDist = 200.0;
    const float delta = 1.0;
    float inp = (t1[0] * t1[1]) + (t2[0] * t2[1]) * 0.5;
	float amp = inp * 1.05;
    
    float lastTer = 0.0;
    float closest = 0.0;
    
    float d = minDist;
    float m = t1[0] * t2[0];
    m *= 256.0;
    
    for (float t = 0.0; t < m; t++)
    {
        if (d > maxDist)
            break;
        vec3 pos = offset + dir * d;
        
        float ter = terrainFunction(pos, t1, t2);
        
        if (ter >= amp)
            return d + delta + delta * ((amp -lastTer) / (ter - lastTer));
        
        float ter2 = terrainFunction(pos * -1.0, t1 * -0.1, t2 * -1.5);
        if(ter2 >= amp)
            return d * delta + delta * ((amp -lastTer) / (ter - lastTer));
        
        lastTer = ter;
        
        if (ter > closest)
            closest = ter;
        
        d += delta;
    }
    
    return closest - amp;
}

vec3 rotX(vec3 vec, float r)
{
    float c = cos(r);
    float s = sin(r);
    float cy = c * vec.y;
    float sy = s * vec.y;
    float cz = c * vec.z;
    float sz = s * vec.z;
    
    return normalize(vec3(vec.x, cy - sz, sy + cz));
}

vec3 rotY(vec3 vec, float r)
{
    float c = cos(r);
    float s = sin(r);
    float cx = c * vec.x;
    float sx = s * vec.x;
    float cz = c * vec.z;
    float sz = s * vec.z;
    
    return normalize(vec3(cx - sz, vec.y, sx + cz));
}

vec3 palette[7]; 

vec3 getcolor(float c) 
{
	c=mod(c,7.); 
	int p=0;
	vec3 color=vec3(0.);
	for(int i=0;i<7;i++) {
		if (float(i)-c<=.0) { 
			color=palette[i]; 
		}
	}
	return color;
}

vec3 getsmcolor(float c, float s) 
{
    s*=.5;
    c=mod(c-.5,7.);
    vec3 color1=vec3(0.0),color2=vec3(0.0);
    for(int i=0;i<7;i++) {
        if (float(i)-c<=.0) {
            color1 = palette[i];
            color2 = palette[(i+1>6)?0:i+1];
        }
    }
    return mix(color1,color2,smoothstep(.5-s,.5+s,fract(c)));
}

vec3 shade(vec3 position, vec3 rayDir, vec2 uv2, vec4 t1, vec4 t2)
{
    vec3 col = vec3(0.0, 0.0, 0.0);
    vec3 color=vec3(0.);
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
    float mul = 1.0;
       
    if (uv.x>.9) { 
        color=getsmcolor(uv.y*7.0+iTime*.5,.25+.75*abs(sin(iTime))); 
    } else if (uv.x>.1) {
        color=getcolor(uv.y*7.7-iTime*.5); 
    } 

    vec2 p=(uv2-.5);
    p.x*=iResolution.x/iResolution.y;

    // fractal
    float a=iTime*.075;	
    float b=iTime*60.;	
    float ot=1000.;
    mat2 rot=mat2(cos(a),sin(a),-sin(a),cos(a));
    p += sin(iTime);

    float l=length(p);
    for(int i=0;i<128;i++) 
    {
        p*=rot;
        p=abs(p)*1.2-1.;
        ot=min(ot,abs(dot(p,p)-sin(b+l*20.)*.015-.15)); 
    }
    ot=max(0.,.1-ot)/.1; //orbit trap 

    color=getsmcolor(ot*4.+l*10.-iTime*7.,1.)*(1.-.4*step(.5,1.-dot(p,p))); //get color gradient for orbit trap value	
    color=mix(vec3(length(color))*.5,color,.6); // saturation adjustment
    
    const float numWaves = 3.0;
    for (float i = 1.0; i < numWaves; i++)
    {
    	vec3 normal = normalAt(position, t1, t2);
        col = col * (1.0 - mul) + mul * clamp(dot(normal, orientation), 0.4, 1.0) * col * 1.4;
        
        vec3 dir = vec3(1.0, 0.0, 0.0);
        col += vec3(sin(totaldt / 6.0 + t1[0] + t2[0] - uv.x), sin(iTime / 3.0 + uv.y + t1[0]), sin(iTime / 4.0 + t2[0])) * clamp(dot(normal, dir), 0.0, 1.0) * 0.5;
        
        col *= sin(totaldt / 4.0) / 4.0 + 1.0;
        
        //col *= getcolor(t1[0] * 7.0);
        //col *= getsmcolor(1.0 + atan(uv.y*7.0+iTime*.5) * 6.0, t1[0]); 
		col += (color * 0.01);
        col += (getsmcolor(t1[0] * 7.0, pow(.3, t1[0])) * 0.01);
        col=mix(vec3(length(col))*.8,col,.9);
        
        col.x *= 0.5 + sin(uv.x + t1[0]+ totaldt / 7.0);
        col.y *= 1.0 + cos(uv.y + t1[0] * 2.0 + totaldt / 3.0);
        col.z *= 1.0 + sin(uv.x + uv.y + t2[0] * 2.0 + totaldt / 6.0);
        
        rayDir = reflect(rayDir, normal);
        
        float dist = march(position, rayDir, t1, t2);
        if (dist >= 0.0)
            position = (position + rayDir * dist);
        
        mul *= 0.8;
        
        float scale = exp2(-fract(iTime / 5.0));
        float theta = pi * float(i) / float(numWaves);
        vec2 waveVec = vec2(cos(theta), sin(theta));
        float phase = dot(position.xy * (rayDir.xy * 100.0), waveVec);
        for(int k = 0; k < int(5); k++){
            mul += cos(phase * scale * exp2(float(t1.xy))) * smoothWave(k, 1.0 + (sin(accumulator) * 0.5));
        }
    }
        
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    palette[6]=vec3(0,000,000)/255.;
	palette[5]=vec3(0,127,000)/255.;
	palette[4]=vec3(0,255,000)/255.;
	palette[3]=vec3(0,050,050)/255.;
	palette[2]=vec3(000,050,50)/255.;
	palette[1]=vec3(0,000,130)/255.;
	palette[0]=vec3(0,000,255)/255.;
    
    orientation = normalize(vec3(0.0, sin(iTime), cos(iTime)));
    
    vec2 uv = (fragCoord.xy / iResolution.xy);
    //uv=abs(2.0*(uv-0.5));
    
    float theta = atan(fft)*(1.0/(3.14159/2.0))*atan(uv.x);
    float r = length(uv);
	float a= -1.0 * log(r);
    uv = vec2(theta, -r);
    
    vec3 cameraPos = vec3(sin(iTime / 7.0), 
                          sin(iTime * accumulator / 5.0) * 3.0, 
                          sin((iTime + accumulator) * 0.002) * 30.0);
    
    float focalLength = sin(fft / 2.0) * 4.0 + 5.0;
    float x = fragCoord.x / iResolution.x - 0.5;
    float y = (fragCoord.y / iResolution.y - 0.5) * (iResolution.y / iResolution.x);
    
    int tx = int(uv.x*512.0);
    
    float fft2  = texelFetch( iChannel0, ivec2(tx,0), 0 ).x; 
    fft += ( (fft2 + fft2) * (fft2 + fft2) );
    fft = clamp(0.0, 100.0, fft - (5.0 * iTimeDelta));
    
    accumulator += (fft2 * 0.5);
    
    float lookX = sin((iTime + accumulator) / 1000.0) * 150.0;
    float lookY = cos((iTime + accumulator) / 100.0) * 50.0;
    
    vec3 rayDir = normalize(vec3(x * focalLength, -1, y * focalLength));
    rayDir = rotX(rayDir, lookX + sin(accumulator * 0.01));
    rayDir = rotY(rayDir, lookY);
    
    float p1 = fragCoord.x / iResolution.x;
    float p2 = fragCoord.y / iResolution.y;
        
    vec4 t1 = texture(iChannel0, vec2(tx, 0) );
    vec4 t2 = texture(iChannel0, vec2(tx, 1) );
    
    float dist = march(cameraPos, rayDir, t1, t2);

    vec3 pos = (cameraPos + rayDir * dist);
    vec2 xy = pi2 * 1.0 * ((2.0 * fragCoord - iResolution.xy) / iResolution.y - exp2(iTime + fft) * atan(accumulator * fft));
            
    float n = (t1[0] + t2[0] + fft) * 0.5;
    totaldt += n;
    
    dt += n * 0.5;
    dt = abs(dt - (1.0 * iTimeDelta));
    
	vec3 color = shade(pos, rayDir, fragCoord, t1, t2);
	fragColor = vec4(color, 1.0);
}