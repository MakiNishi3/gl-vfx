/* @kishimisu - 2023

   Photosensitive/Epilepsy Warning!
   
   This music seem calm at the beginning but
   don't be fooled, this is riddim in 7/4 time signature
   and the drop is coming from outer space.
   
   But I really liked how its different parts react to this scene!
*/

/* Audio-related functions */
#define getLevel(x) (texelFetch(iChannel0, ivec2(int(x*512.), 0), 0).r)
#define logX(x,a,c) (1./(exp(-a*(x-c))+1.))

float logisticAmp(float amp){
   float c = 1., a = 20.;  
   return (logX(amp, a, c) - logX(0.0, a, c)) / (logX(1.0, a, c) - logX(0.0, a, c));
}
float getPitch(float freq, float octave){
   freq = pow(2., freq)   * 261.;
   freq = pow(2., octave) * freq / 12000.;
   return logisticAmp(getLevel(freq));
}
float getVol(float samples) {
    float avg = 0.;
    for (float i = 0.; i < samples; i++) avg += getLevel(i/samples);
    return avg / samples;
}
/* ----------------------- */

float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float hash13(vec3 p3) {
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

#define light(d, att) 1. / (1.+pow(abs(d*att), 1.3))

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv   = (2.*fragCoord-iResolution.xy)/iResolution.y;
    vec3 col  = vec3(0.);
    float vol = getVol(8.);
    
    float hasSound = 1.; // Used only to avoid a black preview image
    if (iChannelTime[0] <= 0.) hasSound = .0;
 
    for (float i = 0., t = 0.; i < 30.; i++) {
        vec3 p  = t*normalize(vec3(uv, 1.)) + vec3(0,0,iTime*2.+vol*2.);        
        
        vec3 id = floor(abs(vec3(p.x,0,p.z)));
        vec3 q  = fract(p)-.5;
        q.y = abs(p.y) - 3.5;

        float freq  = smoothstep(0., 20.,id.x)*3.*hasSound+ hash13(id)*5.+sin(id.z*100.)*.5;
        float pitch = getPitch(freq, 0.);
        float dst   = sdBox(q-vec3(0,10,0), vec3(.35,10,.35));
        
        vec3 color = .8*vec3(.8,.6,1) * (cos(id*.4 + vec3(0,1,2) + iTime) + 2.);
        vec3 bug = color*t*.04*smoothstep(0.05, 1., pow(vol, 4.)); // Create distant patterns instead of black
        
        col += color
             * (light(dst, 10. - vol) + bug)
             * pow(pitch,2.-1.5+vol) ;
        
        t += dst;
    }
    
    fragColor = vec4(col,1.0);   
}
