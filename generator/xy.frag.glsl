/*


BASED ON: https://www.shadertoy.com/view/MsXGDn

Reference: https://www.youtube.com/watch?v=YqSvkNjWnnQ

W I P. Please help out with the code if you have any tips on removing
the straight lines popping up, speeding up the code (can the for loop be avoided?)
and straightening up the shape.. it seems to have some offset problem (compare with ref)

just getting started with shaders i am very happy for all the help :)


*/

#define ReturnTuning .224399476
#define PhaseScaling 2.0
#define PointSmallness 100.0
#define NumSamples 100

#define PI 3.141592654

vec2 getPoint(float x) {
    float scale = 3.0;
    
    float pointX=(texture(iChannel0,vec2(x,1.0)).x) * scale;
    float pointY=(texture(iChannel0,vec2(fract(x - ReturnTuning),1.0)).x) * scale;
	//float pointX = sin(x * PI * 2.);
    //float pointY = cos(x * PI * 2.);
    return vec2(pointX, pointY) - scale / 2.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy)*2.0-1.0;
	uv.x *= iResolution.x / iResolution.y;
    //uv.x -= 0.8;
    
	float c=0.0;
	float m = 1.0;
    
    vec2 pointA = getPoint(0.); //getPoint(0.);
    
	for(int i=0;i<NumSamples;i++)
	{
		float x = float(i)/float(NumSamples);
        vec2 pointB = getPoint(x);

        vec2 pa = uv - pointB; 
        vec2 ba = pointA - pointB;
        
        float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
        
        vec2 q = pa - ba * h;
        
        m = min( m, dot( q, q ) );
		
        pointA = pointB;
        
	}
    
    m = sqrt( m );
	m = smoothstep(0.01, 0.0, m);

	fragColor = mix(vec4(0.0), vec4(0.2, 1.0, 0.1, 1.0), m);
}
