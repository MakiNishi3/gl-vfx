// Mixed two SoundCloud songs together to make something unique.
vec2 mAud(float x, float y) {
    // This function will take 2 parameters separately.
    vec4 point1 = texture(iChannel0, vec2(x, 0.75));
    vec4 point2 = texture(iChannel1, vec2(y, 0.75));
    return vec2(point1.r,point2.r);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy/iResolution.xy;
    vec2 uv2 = mAud(uv.x,uv.y);
    fragColor = vec4(uv2,abs(uv2.x-uv2.y),1.0);
    if (iTime <= 8.05) {
        fragColor = vec4(0.0,0.0,0.0,1.0);
    } else {
        float g = iTime-8.05;
        float ns = smoothstep(0.0,1.0,g*12.0);
        fragColor.rgb = 1.0-(1.0-fragColor.rgb*ns);
    }
}