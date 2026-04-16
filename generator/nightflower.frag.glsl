#define PI 3.14159265359
#define saturate(x) clamp(x, 0., 1.)

// from mercury sdf
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float pModPolar(inout vec2 p, float repetitions) {
    float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}

vec3 scopeGen(vec2 p, float width, float height) {        
    float xPos = (p.x + width / 2.) / width;
    float nearestXPos = clamp(xPos, 0., 1.);
    
    float block = nearestXPos;
    
    float leftSampleVol = texture(iChannel0, vec2(block - 1. / width, 0)).r;
    float sampleVol = texture(iChannel0, vec2(block, 0)).r;
    float rightSampleVol = texture(iChannel0, vec2(block + 1. / width, 0)).r;
    
    sampleVol = (sampleVol + leftSampleVol + rightSampleVol) / 3.;
        
    float sampleAmp = pow(sampleVol, 2.);
    float barHeight = sampleAmp * height;
    float fadeOpacity = 1. - step(0.5, abs(xPos - 0.5));
    
    vec3 minColor = vec3(0., 0., 1.);
    vec3 maxColor = mix(vec3(1., 0., 0.), vec3(1., 1., 0.), saturate(xPos));
    
    vec3 realMin = mix(maxColor, minColor, pow(texture(iChannel0, vec2(sqrt(1. - block), 0)).r, 2.));
    vec3 realMax = mix(minColor, maxColor, pow(texture(iChannel0, vec2(sqrt(1. - block), 0)).r, 0.5));
    
    float barMult = 1. - step(barHeight, abs(p.y));
    float barSmooth = 0.;
    float barOpacity = (1. - barSmooth) * fadeOpacity * barMult;
    
    vec3 barColor = mix(realMin, realMax, saturate(pow(sampleVol, 2.)));
    
    return barColor * barOpacity;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 centeredP = fragCoord - iResolution.xy / 2.;
    float multiplier = iResolution.x / 1000.;
    
    // circle
    float circleMaxSize = 100. * multiplier;
    float circleAmt = pow(texture(iChannel0, vec2(0, 0)).r, 2.);
    float circlePos = circleAmt * circleMaxSize;
    float circleDist = saturate(1. - abs(length(centeredP) - circlePos) / (800. * multiplier));
    vec3 circleColor = mix(vec3(0.1, 0.1, 1.), vec3(1., 0.1, 1.), pow(circleAmt, 2.)) * pow(circleDist, 99.);
    
    vec2 originalCP = centeredP;
    pR(centeredP, radians(iTime) * 30.);
    
    float brightness = pow(texture(iChannel0, vec2(1., 0)).r, 2.);    
    float currentOffset = (200. + 150. * (brightness - 0.5)) * multiplier;
    
    centeredP /= 0.8;
    pModPolar(centeredP, 6.);
    centeredP.x -= currentOffset;
    pR(centeredP, radians(90.));
    centeredP.x += currentOffset;
    vec3 finalColor = saturate(scopeGen(centeredP - vec2(150. * multiplier, 0.), 300. * multiplier, 300. * multiplier) / 2. + circleColor);
    
    vec2 samplePos = iResolution.xy / 2. + originalCP * 0.995;
    
    vec3 mixedColor = finalColor * 0.3 + texture(iChannel1, samplePos / iResolution.xy).rgb * 0.97;
    
    fragColor = vec4(mixedColor, 1);
}