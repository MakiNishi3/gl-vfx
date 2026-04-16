void mainImage(out vec4 A, vec2 F) {
    vec2 r = iResolution.xy, u = (F+F-r)/r.y;    
    A.rgb*=0.;

    float autoStartTime = 0.0;
    float timeFactor = 2.0; // mvmnt speed

    for (float i; i<25.; A.rgb +=
        .003/(abs(length(atan(u*u*u-u*u*u)-+tanh(u/u*u)/exp2(u*u))-i*.05)+.0009)
        * (cos(i+vec3(3.9,5.,2.54534))+001.)                           
        * smoothstep(.5,.9, abs(tan((length(mod(max(iTime-autoStartTime, 0.0),2.)-i*.1)-1.))))
    ) {
        // smoother mvmnt
        float oscillation = atan(iTime * timeFactor) * 0.1;
        u += oscillation * vec2(sin(iTime), sin(iTime));

        // mvmnt transformations
        u *= mat2(cos((iTime+autoStartTime+i++)*.01 + vec4(0,33,11,0)));
    }

    // audio
    float audioAmplitude = texture(iChannel0, vec2(1.)).r * 2.0; 
    A.rgb *= audioAmplitude;
}
