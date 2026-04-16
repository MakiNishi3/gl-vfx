#define bars 100.0                 // How many buckets to divide spectrum into
#define barSize 1.0 / bars        // Constant to avoid division in main loop
#define barGap 0.1 * barSize      // 0.1 represents gap on both sides, so a bar is
#define sampleSize 5.0           // How accurately to sample spectrum, must be a factor of 1.0
#define PI 3.14159265359


// used
// https://www.shadertoy.com/view/XdX3z2

// atan2 en lerp:
// http://http.developer.nvidia.com/Cg/index_stdlib.html

// colors
// https://color.adobe.com/nl/Mijn-Kuler-thema-color-theme-4149936/?showPublished=true


float lerp(float a, float b, float t)
{
  return a + t*(b-a);
}

vec4 lerp(vec4 a, vec4 b, float t)
{
  return a + t*(b-a);
}

float atan2(float y, float x)
{
  float t0, t1, t2, t3, t4;

  t3 = abs(x);
  t1 = abs(y);
  t0 = max(t3, t1);
  t1 = min(t3, t1);
  t3 = float(1) / t0;
  t3 = t1 * t3;

  t4 = t3 * t3;
  t0 =         - float(0.013480470);
  t0 = t0 * t4 + float(0.057477314);
  t0 = t0 * t4 - float(0.121239071);
  t0 = t0 * t4 + float(0.195635925);
  t0 = t0 * t4 - float(0.332994597);
  t0 = t0 * t4 + float(0.999995630);
  t3 = t0 * t3;

  t3 = (abs(y) > abs(x)) ? float(1.570796327) - t3 : t3;
  t3 = (x < 0.0) ?  float(3.141592654) - t3 : t3;
  t3 = (y < 0.0) ? -t3 : t3;

  return t3;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // create pixel coordinates
	vec2 uv = fragCoord.xy / vec2(iResolution.y,iResolution.y);
	vec2 mouse = iMouse.xy / vec2(iResolution.y,iResolution.y);
    
    // calculate stuff
    vec2 center = vec2((0.5*(iResolution.x/iResolution.y)),0.5);
    //float deltaYFromCenter = center.y - uv.y;
    //float deltaXFromCenter = center.x - uv.x;
    float deltaYFromCenter = (mouse.y) - uv.y;
    float deltaXFromCenter = (mouse.x) - uv.x;
    
    // create music map red (dist center)
	vec4 musicMap;
    float angleFromCenter = atan2(deltaYFromCenter,deltaXFromCenter);  
    musicMap.r = (angleFromCenter+PI)/(PI*2.0);
    
    // create music map blue
    float distFromCenter = sqrt((deltaYFromCenter*deltaYFromCenter)+(deltaXFromCenter*deltaXFromCenter));
    //musicMap.b = pow((distFromCenter),0.25);  
    musicMap.b = clamp(pow((distFromCenter-0.2),2.5)/0.02,0.0,1.0);
    musicMap.g = (distFromCenter*6.0);
   
    
    // use music map red
    float musicChannelnput = texture( iChannel0, vec2( musicMap.r,0.0)).r;
    
    
	// Get the starting x for this bar by rounding down
	float barStart = floor(musicMap.r * bars) / bars;
    
    // Sample spectrum in bar area, keep cumulative total
    float intensity = 0.0;
    for(float s = 0.0; s < barSize; s += barSize * sampleSize) {
        // Shader toy shows loudness at a given frequency at (f, 0) with the same value in all channels
        intensity += texture(iChannel0, vec2(barStart + s, 0.0)).r;
    }
    intensity *= sampleSize;
    
    if(musicMap.r - barStart < barGap || musicMap.r > barStart + barSize - barGap) {
		intensity = 0.0;
	}
    
    
    // use music map blue
    vec4 colorOnCenter = vec4(0.24);
    vec4 colorOnBars = vec4(0.27,0.48,0.44,1.0);
    
    vec4 colorOn = lerp(colorOnCenter,colorOnBars,floor( clamp(musicMap.b,0.0,1.0) ));
    vec4 colorOff = vec4(0.21,0.40,0.51,1.0);
    
    //float onOff = musicMap.b-musicChannelnput;
	float onOff = musicMap.g-intensity;
    onOff = clamp(onOff,-0.5,0.5); 
    onOff = floor(onOff+1.0)+0.5;
    fragColor = lerp(colorOn, colorOff,onOff);
                       
	/*
    	if(musicChannelnput>musicMap.b){
			fragColor = colorOn;
    	}else{
			fragColor = colorOff;   
		}
    */
    
    // used to debug music map
    // fragColor = musicMap;
}