vec3 tone(vec3 v)
{
    mat3 m = mat3(.842479062253094,  .0423282422610123, .0423756549057051,
                  .0784335999999992, .878468636469772,  .0784336,
                  .0792237451477643, .0791661274605434, .879142973793104);

    v = clamp((log2(m * v) + 12.47393) / 16.5, 0., 1.);
  
    vec3 v2 = v * v,
         v4 = v2 * v2;
  
    v =   15.5  * v4 * v2
        - 40.14 * v4 * v
        + 31.96 * v4
        - 6.868 * v2 * v
        + .4298 * v2
        + .1191 * v
        - .00232;
    
    v = inverse(m) * mix(vec3(dot(v, vec3(0.2126, 0.7152, 0.0722))), pow(v, vec3(1.35)), 1.4);
    
    return mix(pow((v + .055) / 1.055, vec3(2.4)), v / 12.92, lessThan(v, vec3(.04045)));
}

// Wavelength To RGB
vec3 WaveToRGB(float w)
{
    #define g(m, s1, s2) exp(-.5 * pow((w - m) / ((w < m) ? s1 : s2), 2.))
    
    return max(vec3(  1.056 * g(599.8, 37.9, 31.)
                     + .362 * g(442. , 16. , 26.7)
                     - .065 * g(501.1, 20.4, 26.2),
                      
                       .821 * g(568.8, 46.9, 40.5)
                     + .286 * g(530.9, 16.3, 31.1),
                      
                      1.217 * g(437. , 11.8, 36.)
                     + .681 * g(459. , 26. , 13.8) )
              
             * mat3( 3.2405, -1.5372, - .4986,
                    - .9689,  1.8758,   .0415,
                      .0557, -  .204,   1.057), 0.);
}

void mainImage(out vec4 O, vec2 U)
{
    #define S smoothstep
    
    vec2 uv = abs(U - .5 * iResolution.xy) / iResolution.y;
    uv.x /= 2.;
    
    float res = 50.;
    
    vec3 col = vec3(0);
    
    for(float i = 380.; i < 780.; i += 400. / res)
    {
        float a = 1e-4 * i;
        
        #define height(v) (texture(iChannel0, vec2(2. * round(v / a) * a, 0)).x * .3 + .02)
        
        col += 10. * S(.5, 0., uv.x) * S(height(uv.x), 0., uv.y)
                   * WaveToRGB(i) * max(cos(6.28 * uv.x / a), 0.);
        
        for(float x = a * ceil(-.5 / a); x < .5; x += a)
        
        col += S(.5, 0., abs(x)) * WaveToRGB(i) / (1e3 * pow(length(uv * vec2(1, .03 / height(x)) - vec2(x, 0)), 2.) + .15);
    }

    O = vec4(tone(col / res), 1);
}