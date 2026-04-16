/**
 *
 * My chrome extension for Shadertoy:
 * 
 * http://bit.ly/shadertoy-plugin 
 * 
 */

//getNormalHex or getNormalCube
#define getNormal getNormalHex

#define rgb(r, g, b) vec3(float(r), float(g), float(b)) / 255.

#define FAR 50.
#define time iTime
#define mt iChannelTime[1]
#define FOV 130.0
#define FOG 0.95

#define PI 3.14159265
#define TAU (2*PI)
#define PHI (1.618033988749895)

//rotate 
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

// http://mercury.sexy/hg_sdf/
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
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

// http://mercury.sexy/hg_sdf/
// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

// http://mercury.sexy/hg_sdf/
// Repeat only a few times: from indices <start> to <stop> (similar to above, but more flexible)
float pModInterval1(inout float p, float size, float start, float stop) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p+halfsize, size) - halfsize;
	if (c > stop) { //yes, this might not be the best thing numerically.
		p += size*(c - stop);
		c = stop;
	}
	if (c <start) {
		p += size*(c - start);
		c = start;
	}
	return c;
}

struct rm {
    float dist;
    vec2 material;
    vec3 space;
};

//union
rm rmU(rm g1, rm g2) {
    if (g1.dist < g2.dist) return g1;
    return g2;
}

rm map(vec3 p) {
    
    rm 
        scene,
        objBall,
        objFloor = objBall;
    
    vec3 orgP = p;

    // floor
    float matDetail = 1.0;
    float mat = 2.0;

    p.y += 4.0;
    
    objFloor.dist = fBox(p, vec3(100., 0.1, 100.)); 
    objFloor.material = vec2(mat, matDetail);
    objFloor.space = p;                 
    //floor end
    
    p = orgP;
	
    //ball
    float x = pModInterval1(p.x, 1.5, 2., 10.);
    float z = pModInterval1(p.z, 2.0, -15., 10. );

    p = orgP;
    
    p.y = orgP.y * (1. + sin(time * 5.) / 5.);
    p.y = p.y + sin(time * 5.) * 1.5 + .9;
    
    
    pR(p.xy,(time * 2.));
    
    p.x += fract(time / 60. / 120. + 4.);
    
    float rzx = pModPolar(p.zx, 14.);
    float ryz = pModPolar(p.yz, 14.);

    pModPolar(p.yx, 24. - sin(time / 2.4) * 10.);
    
    p.y -= 2.2;
    
    objBall.dist = fBox(p, vec3(0.5));
    objBall.material = vec2(1., rzx - ryz + 1.);
    objBall.space = p;
    
    
    scene = rmU(objFloor, objBall); 
	scene = rmU(scene, objFloor);
    
    return scene;
}


rm trace(vec3 ro, vec3 rd) {
    rm t;
    rm d;
    float dist = 0.;
    
    for (int i = 0; i < 48; i++) {
        d = map(ro + rd * dist);
        dist += d.dist;
		
        if (abs(d.dist) < 0.025 || d.dist > FAR) break;
    }
    t.material = d.material;
    t.dist = dist;
    return t;
}

rm traceRef(vec3 ro, vec3 rd) {
    rm t;
    rm d;
    float dist = 0.;
    
    for (int i = 0; i < 24; i++) {
        d = map(ro + rd * dist);
        dist += d.dist;
		
        if (abs(d.dist) < 0.025 || d.dist > FAR) break;
    }
    t.material = d.material;
    t.dist = dist;
    return t;
}


#define EPSILON .001
vec3 getNormalHex(vec3 pos)
{
	float d=map(pos).dist;
	return normalize(
        vec3(
            map(
                pos+vec3(EPSILON,0,0)).dist-d,
                map(pos+vec3(0,EPSILON,0)).dist-d,
                map(pos+vec3(0,0,EPSILON)).dist-d 
        	)
    	);
}

#define delta vec3(.001, 0., 0.)
vec3 getNormalCube(vec3 pos)   
{    
   vec3 n;  
   n.x = map( pos + delta.xyy ).dist - map( pos - delta.xyy ).dist;
   n.y = map( pos + delta.yxy ).dist - map( pos - delta.yxy ).dist;
   n.z = map( pos + delta.yyx ).dist - map( pos - delta.yyx ).dist;
   
   return normalize(n);
}

vec3 getObjectColor(vec3 p, vec3 n, rm obj) {
    
    vec3 col = vec3(.0);
    
    if (obj.material.x == 2.0) {
        col = rgb(111,92,147);
        p.x += -time * 5.;
        p.xz /= 4.;
        p.xz = sin(p.xz * 6.3);
        col += ceil(p.x * p.z);
    }
    
    if (obj.material.x == 1.0) {
        if (mod(obj.material.y, 2.) < 1.) {
            col = vec3(2.);   
        } else {
            col = vec3(1., 0., 0.);   
        }
    }
    
    if (obj.material.x == 3.0) col = rgb(111,92,147) / 2.;
    
    return col ;
}


// https://www.shadertoy.com/view/4dt3zn
vec3 doColor( in vec3 sp, in vec3 rd, in vec3 sn, in vec3 lp, rm obj) {
	vec3 sceneCol = vec3(0.0);
    lp = sp + lp;
    vec3 ld = lp - sp; // Light direction vector.
    float lDist = max(length(ld / 2.), 0.001); // Light to surface distance.
    ld /= lDist; // Normalizing the light vector.

    // Attenuating the light, based on distance.
    float atten = 1. / (1.0 + lDist * 0.025 + lDist * lDist * 0.2);

    // Standard diffuse term.
    float diff = max(dot(sn, ld), 2.);
    // Standard specualr term.
    float spec = pow(max(dot(reflect(-ld, sn), -rd), 1.), 1.);

    // Coloring the object. You could set it to a single color, to
    // make things simpler, if you wanted.
    vec3 objCol = getObjectColor(sp, sn, obj);

    // Combining the above terms to produce the final scene color.
    sceneCol += (objCol * (diff + .15) * spec * .2);// * atten;

    // Return the color. Done once every pass... of which there are
    // only two, in this particular instance.
    
    return sceneCol;
}

vec3 sky(vec3 rd) {
    vec3 col = rgb(111,92,147);
    
    vec2 uv = vec2(
        .5 + atan(rd.z, rd.x) / 2. * PI,
        0.// .5 + asin(rd.y) / 2. * PI
        );
	
    return col * (.3 + 2. * pow(texture(iChannel0, mod(uv / 10., 1.)).r * 1.2, 3.)) ;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 uv = fragCoord.xy / iResolution.xy - .5;

    uv *= tan(radians (FOV) / 2.0);
    
    float 
        sk = sin(time * .8) * 8.0,
        ck = cos(time * .8) * 6.0,        
        mat = 0.;
    
    vec3 
        sn,
        light = vec3(7., 10., -10.),        
		sceneColor = vec3(0.0),
    
    	// camera
        vuv = vec3(0., 1., 0.), // up
    	ro = vec3(ck, 5. , sk), // pos
    	vrp =  vec3(0., .0, 0.) , // lookat    
		vpn = normalize(vrp - ro),
    	u = normalize(cross(vuv, vpn)),
    	v = cross(vpn, u),
    	vcv = (ro + vpn),
    	scrCoord = (vcv + uv.x * u * iResolution.x/iResolution.y + uv.y * v),
        
    	rd = normalize(scrCoord - ro);

	rm tr = trace(ro, rd);    
    ro += rd * tr.dist;
    
    float fog = smoothstep(FAR * FOG, 0., tr.dist);
    
    if (tr.dist < FAR) {
        
	    sn = getNormal(ro);
        
        sceneColor += doColor(ro, rd, sn, light, tr) * 1.;
        
        rd = reflect(rd, sn);
        tr = trace(ro + rd * .1, rd);
        
        if (tr.dist < FAR) {
            
            ro = ro + rd * tr.dist;
            //sn = getNormal(ro);
            sceneColor += abs(doColor(ro, rd, sn, light, tr) ) * .4;
            
        }
    }       
    
    sceneColor = mix(sky(rd), sceneColor, fog);
	fragColor = vec4(clamp(sceneColor, 0.0, 1.0), 1.0); 
    
}