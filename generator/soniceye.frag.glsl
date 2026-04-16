/*
pwd

www.prinzipiell.com - www.psykosoft.net

eye sonic ornamental

credits:
iq (eyeball), mu6k (wierd balls)

*/

#define occlusion_enabled
#define occlusion_pass1_quality 4
#define occlusion_pass2_quality 3

#define noise_use_smoothstep

#define object_count 11
#define object_speed_modifier .5

#define render_steps 28

vec4  eyeball;
float fft, led, dx;

float displace(vec3 p) {
	
	return ((cos(4.*p.x)*sin(4.*p.y)*sin(4.*p.z))*cos(30.1))*sin(iTime);
	
}


float hash(float x)
{
	return fract(sin(x*.0127863)*17143.321); //decent hash for noise generation
}

float hash(vec2 x)
{
	return fract(cos(dot(x.xy,vec2(2.31,53.21))*124.123)*412.0); 
}

float hashmix(float x0, float x1, float interp)
{
	x0 = hash(x0);
	x1 = hash(x1);
	#ifdef noise_use_smoothstep
	interp = smoothstep(0.0,1.0,interp);
	#endif
	return mix(x0,x1,interp);
}

float hashmix(vec2 p0, vec2 p1, vec2 interp)
{
	float v0 = hashmix(p0[0]+p0[1]*128.0,p1[0]+p0[1]*128.0,interp[0]);
	float v1 = hashmix(p0[0]+p1[1]*128.0,p1[0]+p1[1]*128.0,interp[0]);
	#ifdef noise_use_smoothstep
	interp = smoothstep(vec2(0.0),vec2(1.0),interp);
	#endif
	return mix(v0,v1,interp[1]);
}

float hashmix(vec3 p0, vec3 p1, vec3 interp)
{
	float v0 = hashmix(p0.xy+vec2(p0.z*143.0,0.0),p1.xy+vec2(p0.z*143.0,0.0),interp.xy);
	float v1 = hashmix(p0.xy+vec2(p1.z*143.0,0.0),p1.xy+vec2(p1.z*143.0,0.0),interp.xy);
	#ifdef noise_use_smoothstep
	interp = smoothstep(vec3(0.0),vec3(1.0),interp);
	#endif
	return mix(v0,v1,interp[2]);
}

float noise(vec3 p) // 3D noise
{
	vec3 pm = mod(p,1.0);
	vec3 pd = p-pm;
	return hashmix(pd,(pd+vec3(1.0,1.0,1.0)), pm);
}

vec3 cc(vec3 color, float factor,float factor2) // color modifier
{
	float w = color.x+color.y+color.z;
	return mix(color,vec3(w)*factor,w*factor2);
}


vec3 rotate_z(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, -sa, +.0,
		+sa, +ca, +.0,
		+.0, +.0,+1.0);
}

vec3 rotate_y(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, +.0, -sa,
		+.0,+1.0, +.0,
		+sa, +.0, +ca);
}

vec3 rotate_x(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+1.0, +.0, +.0,
		+.0, +ca, -sa,
		+.0, +sa, +ca);
}

float dist(vec3 p)//distance function
{

	float t = iTime+4.0;
	float d = 1000.0;//p.y+2.0;
	p.y+=sin(t*.5)*.2;
	d=min(length(p)-1.0,d);
	
	float dp  = displace(p);
	d =d + dp;
	
	for (int i=0; i<object_count; i++)
	{
		float fi = float(i); 
		float tof=1442.530/float(object_count)*fi;
		vec3 offs = vec3(
			sin(t*.7+tof*6.0),
			sin(t*.8+tof*4.0),
			sin(t*.9+tof*3.0));
		vec3 v = p+normalize(offs)*1.0;
		d = min(d,length(v)-fft/4.);
		
	}
	
	return d;
}

float amb_occ(vec3 p)
{
	float acc=0.0;
	#define ambe 0.2

	acc+=dist(p+vec3(-ambe,-ambe,-ambe));
	acc+=dist(p+vec3(-ambe,-ambe,+ambe));
	acc+=dist(p+vec3(-ambe,+ambe,-ambe));
	acc+=dist(p+vec3(-ambe,+ambe,+ambe));
	acc+=dist(p+vec3(+ambe,-ambe,-ambe));
	acc+=dist(p+vec3(+ambe,-ambe,+ambe));
	acc+=dist(p+vec3(+ambe,+ambe,-ambe));
	acc+=dist(p+vec3(+ambe,+ambe,+ambe));
	return 0.5+acc /(16.0*ambe);
}

float occ(vec3 start, vec3 light_pos, float size)
{
	vec3 dir = light_pos-start;
	float total_dist = length(dir);
	dir = dir/total_dist;
	
	float travel = .1;
	float o = 1.0;
	vec3 p=start;
	
	float search_travel=.0;
	float search_o=1.0;
	
	float e = .5*total_dist/float(occlusion_pass1_quality);
	
	//pass 1 fixed step search
	
	for (int i=0; i<occlusion_pass1_quality;i++)
	{
		travel = (float(i)+0.5)*total_dist/float(occlusion_pass1_quality);
		float cd = dist(start+travel*dir);
		float co = cd/travel*total_dist*size;
		if (co<search_o)
		{
			search_o=co;
			search_travel=travel;
			if (co<.0)
			{
				break;
			}
		}
		
	}
	
	//pass 2 tries to find a better match in close proximity to the result from the 
	//previous pass
		
	for (int i=0; i<occlusion_pass2_quality;i++)
	{
		float tr = search_travel+e;
		float oc = dist(start+tr*dir)/tr*total_dist*size;
		if (tr<.0||tr>total_dist)
		{
			break;
		}
		if (oc<search_o)
		{
			search_o = oc;
			search_travel = tr;
		}
		e=e*-.75;
	}
	
	o=max(search_o,.0);

	return o;
}

float occ(vec3 start, vec3 light_pos, float size, float dist_to_scan)
{
	vec3 dir = light_pos-start;
	float total_dist = length(dir);
	dir = dir/total_dist;
	
	float travel = .1;
	float o = 1.0;
	vec3 p=start;
	
	float search_travel=.0;
	float search_o=1.0;
	
	float e = .5*dist_to_scan/float(occlusion_pass1_quality);
	
	//pass 1 fixed step search
	
	for (int i=0; i<occlusion_pass1_quality;i++)
	{
		travel = (float(i)+0.5)*dist_to_scan/float(occlusion_pass1_quality);
		float cd = dist(start+travel*dir);
		float co = cd/travel*total_dist*size;
		if (co<search_o)
		{
			search_o=co;
			search_travel=travel;
			if (co<.0)
			{
				break;
			}
		}
		
	}
	
	//pass 2 tries to find a better match in close proximity to the result from the 
	//previous pass
		
	for (int i=0; i<occlusion_pass2_quality;i++)
	{
		float tr = search_travel+e;
		float oc = dist(start+tr*dir)/tr*total_dist*size;
		if (tr<.0||tr>total_dist)
		{
			break;
		}
		if (oc<search_o)
		{
			search_o = oc;
			search_travel = tr;
		}
		e=e*-.75;
	}
	
	o=max(search_o,.0);

	return o;
}

vec3 normal(vec3 p,float e) //returns the normal, uses the distance function
{
	float d=dist(p);
	return normalize(vec3(dist(p+vec3(e,0,0))-d,dist(p+vec3(0,e,0))-d,dist(p+vec3(0,0,e))-d));
}

mat2 m = mat2( 0.10,  0.60, -0.10,  0.80 );

float noise(float p)
{
	float pm = mod(p,1.0);
	float pd = p-pm;
	return hashmix(pd,pd+1.0,pm);
}

float noise(vec2 p)
{
	vec2 pm = mod(p,1.0);
	vec2 pd = p-pm;
	return hashmix(pd,(pd+vec2(1.0,1.0)), pm);
}

float fbm( vec2 p )
{
    float f = 0.0;
    f += 0.50000*noise( p ); p = m*p*2.02;
    f += 0.25000*noise( p ); p = m*p*2.03;
    f += 0.12500*noise( p ); p = m*p*2.01;
    f += 0.06250*noise( p ); p = m*p*2.04;
    f += 0.03125*noise( p );
    return (f/0.984375);
}

float length2( vec2 p )
{
    float ax = abs(p.x);
    float ay = abs(p.y);
    return pow( pow(ax,4.0) + pow(ay,4.0), 1.0/4.0 );
}

vec3 background(vec3 p,vec3 d)//render background
{
	vec3 color = mix(vec3(.9,.6,.2),vec3(.1,.4,.8),d.y*.5+.5);
	return (color*(noise(d)+.3*pow(noise(d*4.0),4.0)));

}



vec3 object_material(vec3 p, vec3 d) //computes the material for the object
{
	vec3 n = normal(p,.001); //normal vector
	vec3 oldn=n; float nns = 64.0; float nna = .1;
	n.x+=(noise(oldn.yz*nns)-.5)*nna;
	n.y+=(noise(oldn.zx*nns)-.5)*nna;
	n.z+=(noise(oldn.xy*nns)-.5)*nna;
	n=normalize(n);
	vec3 r = reflect(d,n); //reflect vector
	float ao = amb_occ(p); //fake ambient occlusion
	vec3 color = vec3(.0,.0,.0); //variable to hold the color
	float reflectance = 1.0+dot(d,n);
	reflectance += 1.4;

	float or = occ(p,p+r*10.0,0.5,2.0);
	
	
	for (int i=0; i<3; i++)
	{
		float fi = float(i);
		vec3 offs = vec3(
			-sin(5.0*(1.0+fi)*123.4),
			-sin(4.0*(1.0+fi)*723.4),
			-sin(3.0*(1.0+fi)*413.4));
	
		vec3 lp = offs*100.0;
		vec3 ld = normalize(lp-p);
		
		float diffuse = dot(ld,n);
		float od=.0;
		if (diffuse>.0)
		{
			od = occ(p,lp,0.05,2.0);
		}
		
		float spec = pow(dot(r,ld)*.5+.5,100.0);
		
		vec3 icolor = vec3(eyeball.r,eyeball.g,eyeball.b)*diffuse*od*.6 + vec3(spec)*od*reflectance;
		color += icolor;
	}

	color += background(p,r)*(.1+or*reflectance) * eyeball.rgb;

	
	return color*ao*1.2;
	
}

float rand(vec2 position) {
	return fract(sin(dot(position.xy ,vec2(12.9898,78.233))) * 43758.5453+(fft*0.5));
}

float radius = .5;
float refractionIndex = 1.9;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv_ = fragCoord.xy / iResolution.xy;
	vec2  p_ = -1.0 + 2.0 * uv_;
    vec2 dist_ = p_;
    float radius2 = radius * radius;
    float r2 = dist_.x * dist_.x + dist_.y * dist_.y;
        
	if ( r2 > 0.0 && r2 < radius2 )
	{
		float z2 = radius2 - r2;
		float z = sqrt(z2);
		
		float xa = asin( dist_.x / sqrt( dist_.x * dist_.x + z2 ) );
		float xb = xa - xa * refractionIndex;
		float ya = asin( dist_.y / sqrt( dist_.y * dist_.y + z2 ) );
		float yb = ya - ya * refractionIndex;
		
		p_.x -= z * tan( xb );
		p_.y -= z * tan( yb );
	}
       
    float r = length( p_ );
    float a = atan( p_.y, p_.x );

    float dd = 0.2*sin(0.7*iTime);
    float ss = .85 + clamp(1.0-r,0.0,1.0)*dd/.5;			
	r *= ss;

    vec3 col = vec3( 1.0, 0.53, 0.64 );
    float f = fbm( 2.0*p_ );
	
    col = mix( col, vec3(0.2,0.5,0.4), f );
	col = mix( col, vec3(0.9,0.6,0.2), 1.0-smoothstep(0.2,0.6,r) );
    a += 0.05*fbm( 20.0*p_ );
    f = smoothstep( 0.3, 1.0, fbm( vec2(20.0*a,6.0*r) ) );
    col = mix( col, vec3(1.0,1.0,1.0), f );
    f = smoothstep( 0.4, 0.9, fbm( vec2(15.0*a,10.0*r) ) );
    col *= 1.0-0.5*f;
    col *= 1.0-0.25*smoothstep( 0.6,0.8,r );
    f = 1.0-smoothstep( 0.0, 0.6, length2( mat2(0.6,0.8,-0.8,0.6)*(p_-vec2(0.3,0.5) )*vec2(1.0,2.0)) );
    col += vec3(1.0,0.9,0.9)*f*0.985;
    col *= vec3(0.8+0.2*cos(r*a));
    f = 1.0-smoothstep( 0.2, 0.25, r );
    col = mix( col, vec3(0.0), f );
    f = 1.0 - smoothstep( 0.79, 0.82, r );

    eyeball = vec4(col*f,f);
	
	vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
	uv.x *= iResolution.x/iResolution.y; //fix aspect ratio
	vec3 mouse = vec3(iMouse.xy/iResolution.xy - 0.5,iMouse.z-.5);
	

	//setup the camera
	const float bands = 40.;
	vec3 p = vec3(.0,0.0,-2.0);
	
	fft  = texture( iChannel0, vec2(p.x,0.0) ).x;	
	dx  = fract( (uv.x - p.x) * bands) - 0.5;
	led = smoothstep(0.5, 0.3, abs(dx));	

	float t = iTime*.5*object_speed_modifier + 30.0 * fft / 14.;
	mouse += vec3(sin(t)*.1,sin(t)*.1,.0);
	
	p = rotate_x(p,mouse.y*9.0);
	p = rotate_y(p,mouse.x*9.0);
	p.y*.2;
	vec3 d = vec3(uv,1.0);
	d.z -= length(d)*.6; //lens distort
	d = normalize(d);
	d = rotate_x(d,mouse.y*9.0);
	d = rotate_y(d,mouse.x*9.0);
	
	vec3 sp = p;
	vec3 color;

	
	//raymarching 
	for (int i=0; i<render_steps; i++)
	{
		dd = dist(p);
		p+=d*dd;
		if (dd<.001||dd>2.0) break;
	}
	
	if (dd<.03)
	{
		color = object_material(p,d);
	}
	else
	{
		color = background(p,d);
	}
	
	color = mix(color*color,color,1.4);
	color *=.8;
	color -= length(uv)*.1;
	color = cc(color,.5,.5);
	color += hash(uv.xy+color.xy)*.02;
	
	color *= 1.0+0.3*sin(uv.y*(iResolution.y*1.75));
	color = (color*0.85)+(color*0.25*vec3(rand(uv)));
	
	fragColor = vec4(color,1.0) * fft;
}
