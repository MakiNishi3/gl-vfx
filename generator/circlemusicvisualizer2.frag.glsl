#define bars 70.0				// How many buckets to divide spectrum into
#define barSize 1.0 / bars		// Constant to avoid division in main loop
#define barGap 0.1 * barSize	// 0.1 represents gap on both sides, so a bar is
#define sampleSize 2.0			// How accurately to sample spectrum, must be a factor of 1.0
#define PI 3.14159265359
#define circleRadius 0.4;

// used
// https://www.shadertoy.com/view/XdX3z2

// atan2 en lerp:
// http://http.developer.nvidia.com/Cg/index_stdlib.html

// colors
// https://color.adobe.com/nl/Mijn-Kuler-thema-color-theme-4149936/?showPublished=true

#define c1 vec4(0.24)				// grey
#define c2 vec4(.71,.32,.36,1.0)	// red
#define c3 vec4(.91,.64, .0,1.0)	// yello
#define c4 vec4(.27,.48,.44,1.0)	// green
#define c5 vec4(.21,.40,.51,1.0)	// blue

#define colorOnCenter c3
#define colorOff c5
#define colorOn c2
    

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
    
    // calculate stuff
    vec2 center = vec2((0.5*(iResolution.x/iResolution.y)),0.5);
    float deltaYFromCenter = center.y - uv.y;
    float deltaXFromCenter = center.x - uv.x;
    
    // create music map red (angle center)
	vec4 musicMap;
    float angleFromCenter = atan2(deltaYFromCenter,deltaXFromCenter);  
    musicMap.r = (angleFromCenter+PI)/(PI*2.0);
    
    // create music map blue (dist center)
    float distFromCenter = sqrt((deltaYFromCenter*deltaYFromCenter)+(deltaXFromCenter*deltaXFromCenter));
    float circleFromCenter = (distFromCenter*3.0);
    circleFromCenter = circleFromCenter-circleRadius;
    musicMap.b = circleFromCenter;
    
    if(musicMap.b < 0.0){
        fragColor = colorOnCenter;
    }else{

        // use music map red
        float musicChannelnput = texture( iChannel0, vec2( musicMap.r,0.0)).r;

        // Get the starting x for this bar by rounding down
        float barStart = floor(musicMap.r * bars) / bars;

        // Sample spectrum in bar area, keep cumulative total
        float intensity = 0.0;
        for(float s = 0.0; s < barSize; s += barSize * sampleSize) {
            intensity += texture(iChannel0, vec2(barStart + s, 0.0)).r;
        }
        intensity *= sampleSize;
        if(musicMap.r - barStart < barGap || musicMap.r > barStart + barSize - barGap) {
            intensity = 0.0;
        }

        // use music map blue
        float onOff = musicMap.b-intensity;
        onOff = clamp(onOff,-0.5,0.5); 
        onOff = floor(onOff+1.0);
        fragColor = lerp(colorOn, colorOff,onOff);

    }
    // used to debug music map
    // fragColor = musicMap;
}


