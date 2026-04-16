/*
Ray marching a endless, randomly generated track.
To make this demo less boring, the waveform of the background music is being visualized :-P

This shader is still under optimization.

*/
vec4 GRID_SIZE = vec4( 1.0, 0.5, 0.0, 2.0 ); // grid size, grid size / 2, 0, grid height
vec4 BG_COLOR = vec4( 0.0, 0.0, 0.0, 1.0 );
vec4 FG_COLOR0 = vec4( 0.25, 0.25, 1.0, 1.0 );
vec4 FG_COLOR1 = vec4( 1.0, 0.701, 0.0, 1.0 );

struct Ray
{
	vec3 org;
	vec3 dir;
};
	
float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

vec3 rotatex( const in vec3 vPos, const in float fAngle )
{
	float s = sin(fAngle);
	float c = cos(fAngle);

	vec3 vResult = vec3( vPos.x, c * vPos.y + s * vPos.z, -s * vPos.y + c * vPos.z);

	return vResult;
}

vec3 rotatey( const in vec3 vPos, const in float fAngle )
{
	float s = sin(fAngle);
	float c = cos(fAngle);

	vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

	return vResult;
}
      
vec3 rotatez( const in vec3 vPos, const in float fAngle )
{
	float s = sin(fAngle);
	float c = cos(fAngle);

	vec3 vResult = vec3( c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y, vPos.z);

	return vResult;
}

vec3 translate( vec3 v, vec3 t )
{
	return v - t;
}

// reference: https://iquilezles.org/articles/distfunctions
float sdPlane( vec3 p, vec4 n )
{
	// n must be normalized
	return dot( p, n.xyz ) + n.w;
}

float udRoundBox( vec3 p, vec3 b, float r )
{
	return length(max(abs(p)-b,0.0))-r;
}

float udBox( vec3 p, vec3 b )
{
	return length(max(abs(p)-b,0.0));
}

// Grid related
vec3 gridId( in vec3 p )
{
	vec3 gid;
	gid = floor( p / GRID_SIZE.xxx );
	gid.y = 0.0;
	return gid;
}

void gridData( out vec4 gdim, out vec3 gpos, in vec3 gid, in Ray eyeRay )
{
	float h = hash( gid.z * 5.0 ) * 0.875 + 0.125;
	h = h * h * GRID_SIZE.w;
	
	gpos.xz = ( gid.xz * GRID_SIZE.xx );
	gpos.y = 0.0;
	
	gdim.xz = GRID_SIZE.xx;
	gdim.y = h;
	gdim.w = 0.0625;
}

float gridUD( in vec4 gdim, in vec3 gpos, in vec3 p )
{
	//return udBox( translate( p, gpos ), gdim.xyz );
	return udRoundBox( translate( p, gpos ), gdim.xyz - gdim.www, gdim.w );
}

vec4 scene( in Ray eyeRay, in vec3 target )
{
	vec3 gid;
	vec4 gdim;
	vec3 gpos;
	vec4 ret;
	
	vec3 q = floor( eyeRay.org / GRID_SIZE.xxx ) * GRID_SIZE.xxx;
	
	q.y = 0.0;
	float side = 1.0;
	float sideL = udBox( translate( target, q - GRID_SIZE.xzz * 2.0 ), GRID_SIZE.xwx * vec3( 1.0, side, 5.0 ) );
	float sideR = udBox( translate( target, q + GRID_SIZE.xzz * 2.0 ), GRID_SIZE.xwx * vec3( 1.0, side, 5.0 ) );
	ret.w = min( sideL, sideR );
	
	
	vec3 p = q + GRID_SIZE.zzx;
		
	for ( int col = 0; col < 7; ++col )
	{
		gid = gridId( p );
		gridData( gdim, gpos, gid, eyeRay );
		
		float d = gridUD( gdim, gpos, target );
		
		if ( d < ret.w )
		{
			ret.xyz = gid;
			ret.w = d;
		}
		
		p -= GRID_SIZE.zzx;
	}
	
	return ret;
}

bool raymarch3( out vec3 hitPos, out vec3 hitNrm, Ray ray )
{
	// assume ray.dir is normalized
	const float hitThreshold = 0.001;
	
	// ray march against found
	bool hit = false;
	float t = 0.0;
	
	Ray r2;
	r2.org = ray.org;
	r2.dir = ray.dir * GRID_SIZE.y;
	
	for ( int i = 0; i < 64; ++i )
	{
		vec3 p = ray.org + t * ray.dir;
		
		vec4 found = scene( r2, p );
		if ( found.w < hitThreshold )
		{
			hit = true;
			hitPos = p;
			
			vec3 eps = vec3( hitThreshold * 0.5,0.0,0.0 );
			vec3 nor;
			nor.x = scene( r2, p + eps.xyy ).w - scene( r2, p - eps.xyy ).w;
			nor.y = scene( r2, p + eps.yxy ).w - scene( r2, p - eps.yxy ).w;
			nor.z = scene( r2, p + eps.yyx ).w - scene( r2, p - eps.yyx ).w;
			hitNrm = normalize( nor );
			
			break;
		}
		
		t += found.w;
	}
	
	return hit;
}

float calcAO( in vec3 pos, in vec3 nor, in Ray eyeRay )
{
	float AREA = 0.045;
	float SOFTNESS = 0.25;
	float sca = 15.0;
	
    float ao = 1.0;
    float totao = 0.0;
    
    for ( int aoi = 0; aoi < 5; aoi++ )
    {
        float hr = 0.01 + AREA * float( aoi * aoi );
        vec3 aopos =  nor * hr + pos;
        float dd = scene( eyeRay, aopos ).w;
        totao += -( dd - hr ) * sca;
        sca *= SOFTNESS;
    }
    return 1.0 - clamp( totao, 0.0, 1.0 );
}

vec4 fgcolor( in float brightness )
{
	float t = clamp( brightness * brightness * 2.0, 0.0, 1.0 ) ;
	if ( t < 0.5 )
		return mix( BG_COLOR, FG_COLOR0, t * 2.0 ) * t;
	else
		return mix( FG_COLOR0, FG_COLOR1, ( t - 0.5 ) * 2.0 ) * t;
}


vec4 shade( in vec3 scenePos, in vec3 sceneNrm, in Ray eyeRay, in vec4 bg_color )
{
	float brightness = texture( iChannel0, vec2( 0.125, 0.75 ) ).x;
	
	float ao = calcAO( scenePos, sceneNrm, eyeRay );
	
	vec4 diff = mix( fgcolor( brightness ), BG_COLOR, ao );
	
	float fog = min( 1.0, length( scenePos.z - eyeRay.org.z ) / 5.0 );
	
	return mix( diff, bg_color, fog );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//fragColor = texture( iChannel0, vec2( 0.5, 0.75 ) );
	
	vec2 ndcXY = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	float aspectRatio = iResolution.x / iResolution.y;
	vec2 scaledXY = ndcXY * vec2( aspectRatio, 1.0 );
	
	vec3 camWsXYZ = vec3( 0.0, GRID_SIZE.w * 1.25, 0.0 );
	camWsXYZ.z = -iTime * 1.5;
	
	float rotX = 0.2618;
	float rotZ = sin( iTime ) * 0.25;
	//float rotZ = mix( -0.7854, 0.7854, texture( iChannel0, vec2( 0.25, 0.25 ) ).x );
	
	// construct the ray in world space
	Ray ray;
	ray.org = camWsXYZ;
	ray.dir = rotatex( normalize( vec3( scaledXY, -1.0 ) ), rotX ); // OpenGL is right handed
	ray.dir = rotatez( ray.dir, rotZ );
	
	vec3 sceneWsPos;
	vec3 sceneWsNrm;
	
	// sync the bg_color with the music
	vec2 uv = ( fragCoord.xy / iResolution.xy );
	//vec2 uv = rotatez( vec3( fragCoord.xy / iResolution.xy, 0 ), rotZ * 0.75 ).xy;
	
	float h = texture( iChannel0, vec2( uv.x, 0.75 ) ).x;
	float t = clamp( pow( abs((1.0 - uv.y) - ((1.0 - h) - 0.125)), 0.25 ), 0.0, 1.0 );
	vec4 bg_color = mix( fgcolor( h ), BG_COLOR, t ) * 2.0;
	
	
	// ray march the scene
	if ( raymarch3( sceneWsPos, sceneWsNrm, ray ) )
	{
		// hit
		fragColor = shade( sceneWsPos, sceneWsNrm, ray, bg_color );
	}
	else
	{
		// not hit
		fragColor = bg_color;
	}/**/
	
	//fragColor = bg_color;
}