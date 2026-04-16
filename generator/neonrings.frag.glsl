#define PI 3.14159265359
#define saturate(x) clamp(x, 0., 1.)

// change this to 0.05 for more rings, 0.2 for less rings
// more rings = more "responsiveness", but is slower
#define ITERATION_SIZE 0.1

vec3 genColor(vec2 centeredP, float multiplier) {
    vec3 circleColor = vec3(0.);
    
    vec3 circleMin1 = vec3(0.1, 0.1, 1.);
    vec3 circleMin2 = vec3(1., 0.1, 1.);
    vec3 circleMax1 = vec3(1., 1., 0.1);
    vec3 circleMax2 = vec3(1., 0.1, 0.1);
    
    for (float i = 0.; i <= 1.; i += ITERATION_SIZE) {
        float circleMaxSize = (200. + 1000. * i) * multiplier;
        float circleAmt = pow(texture(iChannel0, vec2(i, 0)).r, 2.);
        float circlePos = circleAmt * circleMaxSize;
        float circleDist = saturate(1. - abs(length(centeredP) - circlePos) / (800. * multiplier));
        
        vec3 circleMinColor = mix(circleMin1, circleMin2, i);
        vec3 circleMaxColor = mix(circleMax1, circleMax2, i);
        circleColor = mix(circleColor, mix(circleMinColor, circleMaxColor, pow(circleAmt, 2.)) * pow(circleDist, 99.) * (1. - i * 0.9) * circlePos, circleAmt * 0.9);
    }
    
    vec3 finalColor = circleColor / 20.;
    return finalColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 centeredP = fragCoord - iResolution.xy / 2.;
    vec2 originalCP = centeredP;
    float multiplier = iResolution.x / 1200.;
    
    float currentOffset = 500. * pow(texture(iChannel0, vec2(0, 0)).r, 2.);
    
    float amountMult = 0.2 + currentOffset / 1000.;
    vec3 finalColor = genColor(centeredP + vec2(currentOffset * multiplier, 0), multiplier) * amountMult;
    finalColor += genColor(centeredP, multiplier) * amountMult;
    finalColor += genColor(centeredP - vec2(currentOffset * multiplier, 0), multiplier) * amountMult;
    
    vec2 samplePos = iResolution.xy / 2. + originalCP * 0.999;
    
    vec3 mixedColor = finalColor * 0.3 + texture(iChannel1, samplePos / iResolution.xy).rgb * 0.97;
    
    fragColor = vec4(mixedColor, 1);
}