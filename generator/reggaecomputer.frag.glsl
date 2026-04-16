// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// IBM from way back - or something like that
// was just trying to model something I saw on
// twitter - though my modeling skills blow, I'm
// trying to practice. 

// Audio - it's what I was listening to at the time
// and worked well with the lights! :-)

// soundcloud broken - https://soundcloud.com/alexvanderschoor/bob-marley-exodus-full-album
// using system music till fixed - saving link in comments

#define R   iResolution
#define M   iMouse
#define T   iTime
#define PI  3.14159265359
#define PI2 6.28318530718

#define MIN_DIST .0001
#define MAX_DIST 90.

float sampleFreq(float freq) 
{
    return texture(iChannel0, vec2(freq, 0.25)).x;
}
float hash21(vec2 p)
{
    return fract(sin(dot(p,vec2(23.86,48.32)))*4374.432);
}
mat2 rot(float a)
{
    return mat2(cos(a),sin(a),-sin(a),cos(a));
}

float tmod = 0.;
void getMouse(inout vec3 ro, inout vec3 rd)
{
    float x = M.xy == vec2(0) ? 0. : -(M.y/R.y * 2. - 1.) * PI;
    float y = M.xy == vec2(0) ? 0. : -(M.x/R.x * 2. - 1.) * PI;
 
    if(M.z<1.){
        y = .52*sin(T*.15);
        x = tmod<4.? .6: .22*sin(T*.075);
    }

    if(x<-.25)x=-.25;
    mat2 rx = rot(x);
    mat2 ry = rot(y);
    
    ro.yz *= rx;
    rd.yz *= rx;
    ro.xz *= ry;
    rd.xz *= ry;
}

//@iq thanks for the sdf's!
float cap( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(h,r);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float sdbox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdbox( vec2 p, vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdframe( vec3 p, vec3 b, float e )
{
  p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}
float torus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}
float smin( float d1, float d2, float k ) 
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); 
}
float modPolar(inout vec2 p, float rep) {
    float angle = 2.*PI/rep;
    float a = atan(p.y, p.x) + angle/2.;
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*length(p);
    return (abs(c) >= (rep/2.)) ? abs(c) : c;
} 
//globals
mat2 tprot = mat2(0);
float glow1 = 0.,glow2 = 0.,glow3 = 0.,glow4 = 0.,glow5 = 0.,glow6 = 0.;
vec3 hit=vec3(0);vec3 hitPoint=vec3(0);

vec2 map(vec3 p, float sg)
{
    vec2 res =vec2(1e5,0.);
    vec3 q = p;
    
    float mainbox = sdbox(q-vec3(0,1.1,0),vec3(1.5,3,.75));
    float cutbox =  sdbox(q-vec3(0,2.50,.775),vec3(1.425,1.,.25));
    cutbox =   min( sdbox(q-vec3(0,-.1 ,.775),vec3(.75,1.55,.1 )), cutbox);
    cutbox =   min( sdbox(vec3(abs(q.x),q.yz)-vec3(.65,-.1 ,.775),vec3(.2,1.55,.25 )), cutbox);
    mainbox = max(  mainbox, -cutbox);
    if(mainbox<res.x) {
        res = vec2(mainbox,2.);
        hit = q-vec3(0,1,0);
    }
    
    float dsp = sdbox(q-vec3(0,2.05,.55),vec3(.325,.155,.005));
    if(dsp<res.x) {
        res = vec2(dsp,8.);
        hit = q-vec3(0,2.05,.55);
    }
    
    float frame = sdframe(q-vec3(0,1.1,0),vec3(1.525,3.025,.775),.025);
    frame = min(  sdframe(q-vec3(0,2.8,.775),vec3(1.525,1.33,.005),.025),frame);
    frame = min(  sdframe(q-vec3(0,2.05,.55),vec3(.35,.175,.005),.015),frame);
    frame = min(  torus(vec3(q.y,abs(q.x),q.z)-vec3(2.8,.65,.625),vec2(.225,.025)),frame);
    frame = min(  torus(vec3(q.y,abs(q.x),q.z)-vec3(1.95,.65,.555),vec2(.125,.025)),frame);
    frame = min(  sdbox(vec3(q.y,abs(q.x)-.835,q.z)-vec3(.120,0,.625),vec3(1.70,.03,.15)),frame);
    frame = min(  sdbox(vec3(q.y,abs(q.x)-.425,q.z)-vec3(.025,0,.6),vec3(1.65,.03,.15)),frame);
    frame = min(  cap(vec3(q.y,q.z,abs(q.x))-vec3(2.05,.475,1.05),.075,.1),frame);
    
    frame = min(sdbox(q-vec3(0,1.4,.55),vec3(.445,.225,.15)),frame);
    if(frame<res.x) {
        res = vec2(frame,3.);
        hit = q;
    }
 
    float tapeB = cap(vec3(q.y,q.z,abs(q.x))-vec3(2.8,.55,.65),.225,.1);
    tapeB = min(  cap(vec3(q.y,q.z,abs(q.x))-vec3(1.95,.5,.65),.100,.1),tapeB);
    if(tapeB<res.x) {
        res = vec2(tapeB,5.);
        hit = q;
    }
    
    vec3 tq1 = q.yzx-vec3(2.8,.55,.65);
    vec3 pq1 = tq1;
    pq1.xz*=tprot;
    modPolar(pq1.xz,3.);
    float tcbx = sdbox(pq1-vec3(.4,0,0),vec3(.09));
    float tape1 = cap(tq1,.575,.05);
    tape1=max(tape1,-tcbx);
    
    if(tape1<res.x) {
        res = vec2(tape1,6.);
        hit = pq1;
    }   
    
    vec3 tq2 = q.yzx-vec3(2.8,.55,-.65);
    vec3 pq2 = tq2;
    pq2.xz*=tprot;
    modPolar(pq2.xz,3.);
    float tcby = sdbox(pq2-vec3(.4,0,0),vec3(.09));
    float tape2 = cap(tq2,.575,.05);
    tape2=max(tape2,-tcby);
    if(tape2<res.x) {
        res = vec2(tape2,7.);
        hit = pq2;
    }    
    
    float btn1 = sdbox(q-vec3(.25,3.75,.625),vec3(.125,.035,.15));
    float btn2 = sdbox(q-vec3(.25,3.85,.625),vec3(.125,.035,.15));
    float btn3 = sdbox(q-vec3(.55,3.75,.625),vec3(.125,.035,.15));
    float btn4 = sdbox(q-vec3(.55,3.85,.625),vec3(.125,.035,.15));
    float btn5 = sdbox(q-vec3(-.05,3.75,.625),vec3(.125,.035,.15));
    float btn6 = sdbox(q-vec3(-.05,3.85,.625),vec3(.125,.035,.15));
    
    if (sg==1.&& hash21(vec2(floor(T),1.))>.8) glow1 += .00075/(.0025+btn1*btn1);
    if (sg==1.&& hash21(vec2(floor(T),2.))>.8) glow2 += .00075/(.0025+btn2*btn2);
    if (sg==1.&& hash21(vec2(floor(T),4.))>.8) glow1 += .00075/(.0025+btn4*btn4);
    if (sg==1.&& hash21(vec2(floor(T),3.))>.8) glow2 += .00075/(.0025+btn3*btn3);
    if (sg==1.&& hash21(vec2(floor(T),6.))>.8) glow2 += .00075/(.0025+btn5*btn5);
    if (sg==1.&& hash21(vec2(floor(T),7.))>.8) glow2 += .00075/(.0025+btn6*btn6);
    
    btn1=min(btn2,btn1);
    btn3=min(btn4,btn3);
    btn5=min(btn6,btn5);
    btn1=min(btn3,btn1);
    btn1=min(btn5,btn1);
    
    if(btn1<res.x) {
        res = vec2(btn1,1.);
        hit = q;
    }
    
    float gnd = p.y+2.;
    if(gnd<res.x) {
        res = vec2(gnd,4.);
        hit = p;
    }
    
    return res;
}

vec2 marcher(vec3 ro, vec3 rd, int steps, float sg)
{
    float d = 0.;
    float m = 0.;
    vec3 p;
    for(int i=0;i<steps;i++)
    {
        p = ro + rd * d;
        vec2 ray = map(p,sg);
        if(abs(ray.x)<MIN_DIST*d||d>MAX_DIST)break;
        d += ray.x*.8;
        m  = ray.y;
    } 
    hit = p;
    return vec2(d,m);
}

vec3 normal(vec3 p, float t)
{
    t*=MIN_DIST;
    float d = map(p,0.).x;
    
    vec2 e = vec2(t,0);
    vec3 n = d - vec3(
        map(p-e.xyy,0.).x,
        map(p-e.yxy,0.).x,
        map(p-e.yyx,0.).x
        );
    return normalize(n);
}

vec3 machineTone = vec3(.9,.01,.001);
vec3 checkColor = vec3(0.729,0.031,0.031);
vec4 FC= vec4(0.145,0.055,0.055,0.);
vec3 lpos =  vec3(3,7,5);

vec4 render(inout vec3 ro, inout vec3 rd, inout vec3 ref, bool last, inout float d) {

    vec3 C = vec3(0);
    vec2 ray = marcher(ro,rd,164,1.);
    
    hitPoint = hit;
    d = ray.x;
    float m = ray.y;
    float alpha = 0.;
    if(d<MAX_DIST)
    {
        vec3 p = ro + rd * d;
        vec3 n = normal(p,d);

        vec3 l = normalize(lpos-p);
        
        vec3 h = vec3(.5);

        float diff = clamp(dot(n,l),0.,1.)*.75;
        float fresnel = pow(clamp(1.+dot(rd, n), 0., 1.), 5.);
        fresnel = mix(.01, .7, fresnel);

        float shdw = 1.0;
        vec3 light = normalize(lpos-p);
        for( float t=.01; t < 18.; )
        {
            float h = map(p + light*t,0.).x;

            if( h<MIN_DIST ) { shdw = 0.; break; }

            shdw = min(shdw, 11.*h/t);
            t += h * .95;

            if( shdw<MIN_DIST || t>62. ) break;
        }
        diff *= shdw;
        
        vec3 view = normalize(p - ro);
        vec3 ret = reflect(normalize(lpos), n);
        float spec =  0.5 * pow(max(dot(view, ret), 0.), (m==2.||m==4.)?24.:64.);
 
        if(m==1.) {
            C+=diff*.4;
            ref = vec3(1)*fresnel;
        }
        hitPoint=p;
        if(m==2.) {
            //black decals
            if(
            (hitPoint.y>3.65&&hitPoint.y<3.95&&hitPoint.z>.75&&
             hitPoint.x>-.75&&hitPoint.x<.75)||
            (hitPoint.y>1.5&&hitPoint.y<3.5&&hitPoint.z>.15&&
             hitPoint.x>-1.45&&hitPoint.x<1.45)||
            
            (hitPoint.y>-1.65&&hitPoint.y<1.5&&hitPoint.z>.15&&
             hitPoint.x>-.85&&hitPoint.x<.85)||
            
            (hitPoint.y<-1.75)
            ){  //red stripe
                h=(hitPoint.y>-1.75&&hitPoint.y<1.5&&hitPoint.z>.5&&
                   hitPoint.x>-.45&&hitPoint.x<.45)?
                   machineTone:vec3(.01);
                ref = vec3(1)*(.05-fresnel);
            }else{
               h= vec3(.95);
               ref = vec3(0);
            }
            
            if( hitPoint.y>1.0&&hitPoint.y<3.5&&hitPoint.z>.15&&
             hitPoint.x>-1.4 &&hitPoint.x<1.4 ) {
                //big back visualizer
                vec2 uv = hitPoint.xy-vec2(0,2.05);
                uv*=8.;
                vec2 f = fract(uv)-.5;
                vec2 fid = floor(uv)+.5;
                fid.x=abs(fid.x);
                fid.y*=-1.;
                float ht = sampleFreq(fid.x*.0465);
               
                ht=smoothstep(.001,1.,ht)*1.5;

                float ff = sdbox(f,vec2(.25))-.05;
                //ff=abs(ff)-.01;
                ff=smoothstep(.11,.1,ff);
                
                if(
                (hitPoint.y>1.52 &&hitPoint.y<3.5) &&
                ht>.5 && (fid.y-1.)>-(ht*1.75)
                ) {
                h=mix(h,ff*mix(vec3(.0,.6,1.),vec3(.0,.3,.6),fid.y-2.),.2);
                ref = vec3(1)*(.35-fresnel);
                }
                
             }
             
            C+=spec+(h*diff);
        }
        
        if(m==3.) {
            C+=vec3(.25)*diff;
            ref = vec3(1)*(.25-fresnel);
        }
        
        if(m==4.) {
            vec2 f = fract(hitPoint.xz*.25)-.5;
            if(f.x*f.y>0.) 
            {
                h = vec3(.01);
                ref = vec3(1)*(.35-fresnel);
            } else {
                ref = vec3(1)*(.01+fresnel);
                h = checkColor;
            }
            C+=spec+h*diff;
        }
     
        if(m==5.) {
            h = vec3(.001);
            C+=spec+h*diff;
        }
        if(m==6.) {
            h = machineTone;
            C+=spec+h*diff;
        }
        if(m==7.) {
            h = vec3(1.);
            C+=spec+h*diff;
        }
        if(m==8.) {
            h = vec3(.01);
            //mini visualizer
            vec2 uv = hitPoint.xy-vec2(0,2.05);
            uv*=15.;
            vec2 f = fract(uv)-.5;
            vec2 fid = floor(uv)+.5;
            fid.x=abs(fid.x);
            fid.y*=-1.;
            float ht = sampleFreq(fid.x*.0465);
            ht=smoothstep(.001,1.,ht)*1.5;
    
            float ff = sdbox(f,vec2(.25))-.05;
            ff=smoothstep(.11,.1,ff);
            if(
            (hitPoint.y>1.92 &&hitPoint.y<2.19) &&
            ht>.5 && (fid.y-1.)>-(ht*1.75)
            ){
                h+=ff*mix(vec3(.9,.5,0),vec3(.6,.2,0),fid.y+.5);
                ref = vec3(1)*(.65-fresnel);
            }
            ref = vec3(1)*(.05-fresnel);
            C+=spec+h*diff;
        }
        
        ro = p+n*MIN_DIST;
        rd = reflect(rd,n);
    } else {
        C = FC.rgb;
    }
    C = mix(FC.rgb,C,  exp(-.000035*d*d*d)); 
    
    float glowMask1 = clamp(glow1,.0,.8);
    C = mix(C,glow1*machineTone,glowMask1);
    
    float glowMask2 = clamp(glow2,.0,.7);
    C = mix(C,glow2*vec3(.9),glowMask2);
    
    return vec4(C,alpha);
}
   
void mainImage( out vec4 O, in vec2 F )
{
    tprot = rot(T*.5);
    tmod = mod(T*.25,15.);
    
    vec2 uv = (2.*F.xy-R.xy)/max(R.x,R.y);
    vec3 ro = vec3(0,1.25,M.z>0.||tmod<4.?6.5:8.);
    vec3 rd = normalize(vec3(uv,-1));

    getMouse(ro,rd);
    vec3 C = vec3(0);
    vec3 ref=vec3(0), fil=vec3(1);
    float d =0.;
    float numBounces = 2.;//@BigWings reflection
    for(float i=0.; i<numBounces; i++) {
        vec4 pass = render(ro, rd, ref, i==numBounces-1., d);
        C += pass.rgb*fil;
        fil*=ref;
        // first bounce - get fog layer
        if(i==0.) FC = vec4(FC.rgb,exp(-.00035*d*d*d));
    }
    //layer fog in
    C = mix(C,FC.rgb,1.-FC.w);

    C = pow(C, vec3(.4545));	// gamma correction
    
    O = vec4(C,1.0);
}

