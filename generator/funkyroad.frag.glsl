#define pi (acos(-1.))

vec3 color (float t)
{
    vec3 a,b,c,d;
    a = vec3(0.5);
    b = vec3(0.5);
    c = vec3(1.);
    d = vec3(0., 0.33, 0.66);
    return a+b*cos(2.*pi*(t*c+d));
}

vec3 roadCol (float t)
{
    vec3 a,b,c,d;
    a = vec3(0.5);
    b = vec3(0.5);
    c = vec3(6.,6.03,6.);
    d = vec3(0.0, 0.1, 0.);
    return a+b*cos(2.*pi*(t*c+d));
}

vec3 offroadCol (vec2 uv, float t)
{
    t += cos(uv.x*7.) + sin(0.2+7.*(uv.y+t));
    vec3 a,b,c,d;
    a = vec3(0.5, 0.7, 0.5);
    b = vec3(0.5, 0.8, 0.5);
    c = vec3(3.,5.,2.);
    d = vec3(0.25, 0., 0.5);
    return a+b*cos(2.*pi*(t*c+d));
}

vec4 rainbow(vec2 uv, float t)
{
    uv.x -= 0.8;
    float dist = pow(uv.x, 2.)+pow(uv.y,2.) + 0.1*t;
    float brightness = smoothstep(0.3,0.5, dist) * smoothstep(1.3,1.1, dist);
    return vec4(color(dist), (0.3+t)*brightness);
}

float roadPos(float t)
{
    return 0.8 + 0.2*cos(2.1*t) + 0.1*sin(0.2+t);
}

vec3 road(vec2 uv, float t)
{
    float medDist = uv.x - roadPos(t+uv.y);
    medDist *= (uv.y+0.2);
    float onRoad = smoothstep(-0.1,-0.09, medDist) * smoothstep(0.1,0.09, medDist);
    return  mix(offroadCol(vec2(medDist, uv.y), t), roadCol(t+uv.y), onRoad);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.y;
    
    float f = texture(iChannel0, vec2(0.001, 0.)).r;
    float dx = 0.1*f*texture(iChannel0, vec2(uv.y, 0.)).r;
    
    float t = iTime + 0.2*f;
    //periodic acceleration term
    t = t+cos(0.3*t);

    vec4 rb = rainbow(uv, f);
    vec3 rd = road(uv + vec2(dx, 0.), t);
    vec3 col = rb.rgb*rb.a + rd*(1.-rb.a);

    // Output to screen
    fragColor = vec4(col,1.0);
}