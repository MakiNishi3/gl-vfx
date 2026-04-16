const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;


struct Surface
{
    float sd;
    vec3 col;
};

mat3 rotX(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3
    (
        vec3(1., 0., 0.),
        vec3(0., c , -s),
        vec3(0 , s ,  c)
    );
}

mat3 rotY(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3
    (
        vec3(c , 0., s ),
        vec3(0., 1., 0.),
        vec3(-s, 0., c )
    );
}

mat3 rotZ(float theta)
{
    float c = cos(theta);
    float s = sin(theta);
    return mat3
    (
        vec3(c , -s, 0.),
        vec3(s ,  c, 0.),
        vec3(0., 0., 1.)
    );
}

mat3 identity = mat3(
    vec3(1., 0., 0.),
    vec3(0., 1., 0.),
    vec3(0., 0., 1.)
);

Surface sdFloor(vec3 p, vec3 col)
{
    float d = p.y + 1.;
    return Surface(d, col);
}

Surface sdBox(vec3 p, vec3 b, vec3 offset, vec3 col, mat3 transform)
{
    p = (p - offset) * transform;
    vec3 q = abs(p) - b;
    float d = length(max(q,0.)) + min(max(q.x,max(q.y,q.z)),0.);
    return Surface (d, col); 
}

Surface sdTorus(vec3 p, vec3 t, vec3 offset, vec3 col, mat3 transform)
{
    p = (p - offset) * transform;
    vec2 q = vec2(length(p.xz) - t.x, p.y);
    float d = length(q)-t.y;
    return Surface (d, col);
}

Surface minWithColor(Surface obj1, Surface obj2)
{
    if (obj2.sd < obj1.sd) return obj2;
    return obj1;
}

Surface sdScene(vec3 p)
{
    vec3 floorColor = vec3 (1. + 0.7*mod(floor(p.x) + floor(p.z), 2.0));
    vec3 boxColor = vec3(1., 0., 0.);
    vec3 torusColor = vec3(0., 0., 1.);
    
    mat3 t = identity; 
    t *= rotY(iTime/2.);
    t *= rotX(iTime/3.);
    

    vec3 pR = p * t;
    float s = texture(iChannel0, vec2((mod(pR.y + iTime / 10., 1.)/25.)+0.0, 0.25)).r;
    s *= 0.5;
    t *= rotZ(iTime/5. + pR.z*sin(iTime) + pR.x*cos(iTime));
  
    Surface co = sdFloor(p, floorColor);
    Surface box = sdBox(p, vec3(1.), vec3(0, 0.5, -4), boxColor, t);
    Surface torus = sdTorus(p, vec3(1., .5, .5), vec3(0, 0.5, -4), torusColor, t); 
    
    
    
    float mixObj = 0.5 + 0.5*sin(iTime+s*3.141);
    
    Surface obj = Surface
    (
        mix(box.sd, torus.sd, mixObj), 
        mix(box.col, torus.col, mixObj)
    );
    
    //co = minWithColor(co, sdBox(p, vec3(1), vec3(0, 0.5, -4.), vec3(1., 0., 0.),  rotY(iTime*2.)*rotX(iTime)));
    //co = minWithColor(co, sdTorus(p, vec3(1., .5, .5), vec3(0, 0.5, -4.), vec3(0., 0., 1.),  rotY(iTime*2.)*rotX(iTime)));
    
    co = minWithColor(co, obj);
    return co;
}

Surface rayMarch(vec3 ro, vec3 rd, float start, float end)
{
    float depth = start;
    Surface co;
    
    for (int i=0; i < MAX_MARCHING_STEPS; i++)
    {
        vec3 p = ro + depth * rd;
        co = sdScene(p);
        depth += co.sd;
        if (co.sd < PRECISION || depth > end) break;
    }
    
    co.sd = depth;
    return co;
}

vec3 calcNormal(in vec3 p)
{
    vec2 e = vec2(1.0, -1.0) * 0.0005;
    return normalize(
        e.xyy * sdScene(p + e.xyy).sd +
        e.yyx * sdScene(p + e.yyx).sd +
        e.yxy * sdScene(p + e.yxy).sd +
        e.xxx * sdScene(p + e.xxx).sd);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 uv = (fragCoord - .5 * iResolution.xy) / iResolution.y;
   vec3 backgroundColor = vec3(0.835, 1., 1.);
   
   vec3 col = vec3(0.);
   vec3 ro = vec3(0., 0., 3.);          //ray origin
   vec3 rd = normalize(vec3(uv, -1));   //ray direction
   
   Surface co = rayMarch(ro, rd, MIN_DIST, MAX_DIST);
   
   if (co.sd > MAX_DIST)
   {
       col = backgroundColor;
   } 
   else
   {
       vec3 p = ro + rd * co.sd;
       vec3 normal = calcNormal(p);
       vec3 lightPosition = vec3 (2., 2., 7.);
       vec3 lightDirection = normalize(lightPosition - p);
       float dif = clamp(dot(normal, lightDirection), 0.3, 1.);    //diffuse reflection
       col = dif * co.col + backgroundColor * .2;                  //Add a bit of bg color to diffuse
   }
   
   fragColor = vec4(col, 1.0);
}