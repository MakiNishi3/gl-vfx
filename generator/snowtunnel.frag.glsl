// EPS defines the epsilon that we use as a minimum for going out of our trace
// function ray or for defining our shading's function sha 3D treshold
#define EPS   1e-2

// The STEPS integer stores the number of rays that we shoot at our scene, 
// more means a better resolution(specially at the edges) but it also
// messes up our frame rate as it means many more calculations
#define STEPS  200

// The FAR float macro defines where should we stop tracing according to the
// distance from our camera to the 3D scene
#define FAR    70.

// Samples our microphone's or music's frequency, it is stored in a texture
// as all of the inputs here in shadertoy so we must call the texture() 
// function with input 1 our Channel, input 2 we define the frequency that we
// want to sample in two dimensions after we ask only for the x part of the 
// texture as it is a texture it contains 3 values and we only want one float
// after we multiply by 0.1 to obtain a less strong value for our purposes
#define WAV texture( iChannel0, vec2( 0.0, 0.25 ) ).x * 0.2

// We need this for our hash function
#define HASHSCALE1 .1031

// Uncomment to see a sphere that goes according to the path
//#define SPHERE

// Constructs a 2*2 matrix that enables us to rotate in 2D, see:
// https://thebookofshaders.com/08/ for more information on how to 
// implement this
mat2 rot( float a )
{

    return mat2( cos( a ), -sin( a ),
               	 sin( a ),  cos( a )
               );

}

// iq's smooth maximum it returns a smoothed version of max, meaning that it
// gets rid of the discontinuties of the max function see the link below for
// the smooth min implementation which is in principle the same, here we just
// apply it to max instead
// https://iquilezles.org/articles/smin
float smax(float a, float b, float k)
{
    
    return log(exp(k*a)+exp(k*b))/k;

}

// Dave Hoskin's hash one out two in
float hash(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

// Divides the 2D space in tiles than those tiles are asigned a random colour
// than we interpolate using GLSL's mix() function to interpolate to combine
// the different random values of each tile into a 2D texture.
float noise( vec2 uv )
{
    
    vec2 lv = fract( uv );
    lv = lv * lv * ( 3.0 - 2.0 * lv );
    vec2 id = floor( uv );
    
    float bl = hash( id );
    float br = hash( id + vec2( 1, 0 ) );
    float b = mix( bl, br, lv.x );
    
    float tl = hash( id + vec2( 0, 1 ) );
    float tr = hash( id + vec2( 1 ) );
    float t = mix( tl, tr, lv.x );
    
    float c = mix( b, t, lv.y );
    
    return c;

}

// This function returns a mass sum of the noise function we just 
// defined but we assign an amplitude and a frequency
// https://www.shadertoy.com/view/lsf3zB
float hei( vec2 uv )
{

    int iter = 1;
    
    float a = 0.0, amp = 5.9, fre = 0.4 + WAV * 0.05;
    
    a = 5.0 * noise( uv * fre );
    
    /*
    for( int i = 0; i < iter; ++i )
    {
    
        a += amp * noise( uv * fre );
        if( i < iter ) amp *= 0.8; fre *= 0.8 + WAV * 0.05;
        
    }
	*/
    
    return a;

}

// https://www.shadertoy.com/view/MlXSWX
// The path is a 2D sinusoid that varies over time, depending upon the 
// frequencies, and amplitudes.
vec2 path(in float z)
{
    float a = 44.0;
    float b = a * 0.5;
    float s = sin(z/a)*cos(z/b); return vec2(s*b, 0.);
}

// Defines a Signed Distance Function if its inside the surface it returs 0
// else it returns a positive number, although this is a float that we need 
// to output it is important for our shading to return a 2nd value therefore
// it is a vec2, this way we can change our shading according to the index 
// that we assign to the SDF
// https://en.wikipedia.org/wiki/Signed_distance_function
vec2 map( vec3 p )
{

    // A float for our smooth max operator, as we repeat the same process 
    // twice I though it would be nice to have it as a variable
    float sm = 0.1;
    
    // Our bottom 
    float a = p.y + hei( p.xz );
    
    // The tube that cuts a hole in our bottom and top
    float b = length( p.xy - path( p.z ) ) - 13.0;
    
    // Our top
    float c = -p.y + hei( p.zx );
    
    // The smoothed max operator to get a nicely smoothed difference between
    // our tube and our bottom plane first and top plane second
    float d = smax( -b, a, sm );
    float e = smax( -b, c, sm );
    
    // Here we protude a basic plane to get a wave-like behaviour
    float f = p.y + 13.0 + noise( p.xz + iTime ) * 0.05;
    
    // We assign our bottom to a material id
    vec2 sur = vec2( d, 0.0 );
    
    // We assign our top to a material id
    vec2 surT = vec2( e, 1.0 );
    
    // We assign our plane/water an id
    vec2 pla = vec2( f, 2.0 );
    
    #ifdef SPHERE
    
    // We create a temporal position pO value so that we can manipulate
    // the z direction of the sphere's path
    vec3 pO = vec3( 0.0, 0.0, 0.5 + iTime * 25.0 );
    pO.xy *= rot( iTime * 4.0 );
    pO.xy += path( pO.z );
    
    // We assign our sphere an id
    vec2 sph = vec2( length( p - pO ) - 0.1, 3.0 );
    
    // Here we use this little trick to get our object's geometry out with
    // its id, if we used a minimum function to get both objects out, we'd
    // loose the id
    if( sph.x < sur.x ) sur = sph;
    
    #else
    
    #endif
    
    if( surT.x < sur.x ) sur = surT;
    if( pla.x < sur.x ) sur = pla;
    
    return sur;

}

// We define the perpendiculars according to sampling the Signed Distance 
// Function and doing Numerical Differentiation aka we find the derivatives
// https://en.wikipedia.org/wiki/Numerical_differentiation
vec3 norm( vec3 p )
{

    vec2 e = vec2( EPS, 0.0 );
    return normalize( vec3( map( p + e.xyy ).x - map( p - e.xyy ).x,
                            map( p + e.yxy ).x - map( p - e.yxy ).x,
                            map( p + e.yyx ).x - map( p - e.yyx ).x
                          )
                    );

}

// We trace a ray from its Ray Origin(ro) and to its Ray Direction(rd) if we
// get close enough to our Signed Distance Function we stop, this distance is
// defined by EPS aka epsilon. We also stop if the distance of the ray is more
// than the defined maximum length aka FAR
float ray( vec3 ro, vec3 rd, out float d )
{

    d = 0.0; float t = 0.0;
    for( int i = 0; i < STEPS; ++i )
    {
    
        // We make our steps smaller so that we don't get any artifacts from 
        // the raymarching
        d =  0.3 * map( ro + rd * t ).x;
        if( d < EPS || t > FAR ) break;
        
        t += d;
    
    }
    
    return t;

}

// We compute the colours according to different simulated phenomena such as
// diffuse, ambient, specularity
// Variable definitions:
// col = to the output RGB channels we are calculating
// d = our Signed Distance Function
// t = our ray's distance
// p = our point in space
// n = our numerical gradient aka derivatives aka perpendicular of our surface
// lig = our lights position, note that we must normalize as we dont want a 
// direction but only a point in space 
// amb = our ambient light, we use our y direction in the normals to fake a 
// sun's parallel rays, in here as we use a geometry that is upside down,
// meaning the top, we must define a negative ambient and use it when our
// material's id is the top surface
// dif = we use the dot product from our normals and our light to get the 
// diffuse component we must use the max function to not get a value less 
// than 0 as this is incorrect
// spe = our specular component we use the same process of our diffuse 
// component but instead we over load it by the clamp and power functions to 
// get a much brighter result that simulates the bright reflection of a light
// into a surface
// col /= vec3( 120.0 / ( 8.0 + t * t * 0.05 ) ); is a fogging function, it
// takes into accound the ray variable t to get a distance from our camera
vec3 shad( vec3 ro, vec3 rd )
{

    float d = 0.0, t = ray( ro, rd, d );
    vec3 col = vec3( 0 );
    vec3 p =  ro + rd * t;
    vec3 n = norm( p );
    vec3 lig = normalize( vec3( 0.0, 0.5, 0.3 + iTime * 25.0 ) );
    lig.xy += path( lig.z );
    
    float amb = 0.5 + 0.5 * n.y;
    float ambO = 0.5 + 0.5 * -n.y;
    float dif = max( 0.0, dot( lig, n ) );
    float spe = pow( clamp( dot( lig, n ), 0.0, 1.0 ), 16.0 );
    
    col += 1.0 * dif;
    
    if( map( p ).y == 0.0 || map( p ).y == 2.0  )
    {
        
    	col += 0.6 * amb;
    
    }
    
    if( map( p ).y == 1.0 )
    {
        
    	col += 0.6 * ambO;
    
    }
    
    if( map( p ).y == 2.0 )
    {
        
    	col += vec3( 0.0, 0.1, 0.2 );
    	col += 1.0 * spe;
        
    }
    
    if( map( p ).y == 3.0 )
    {
        
        col += 0.6 * amb;
    	col += 1.0 * spe;
        col += 6.0 * vec3( 0.0, 0.1, 0.2 );
        
    }
    
    col /= vec3( 120.0 / ( 8.0 + t * t * 0.05 ) );
    
    return col;

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from -1 to 1)
    vec2 uv = ( -iResolution.xy + 2.0 * fragCoord ) / iResolution.y;

	vec3 ro = vec3( 0.0, 0.0, iTime * 25.0 );
    
    // Camera lookat
    vec3 ww = normalize( vec3( 0 ) - ro );
    // Camera up
    vec3 uu = normalize( cross( vec3( 0, 1, 0 ), ww ) );
    // Camera side
    vec3 vv = normalize( cross( ww, uu ) );
    // Add it to the ray direction
    vec3 rd = normalize( uv.x * uu + uv.y * vv - 1.5 * ww );
    
    ro.xy += path( ro.z );
    rd.xy *= rot( sin( WAV * 0.2 ) );
    rd.xz = rot( path(ro.z).x / -160.0 )*rd.xz;
    
    float d = 0.0, t = ray( ro, rd, d );
    vec3 p = ro + rd * t;
    vec3 n = norm( p );
    
    vec3 col = d < EPS ? shad( ro, rd ) : vec3( 1 );
    
    if( map( p ).y == 2.0 || map( p ).y == 3.0 )
    {

    	rd = normalize( reflect( rd, n ) );
    	ro = p + rd * EPS;

        if( d < EPS || t > FAR ) 
        {
        
            col += shad( ro, rd ) * 0.2;
        
        }
        
    }
        
    //vec3 col = vec3( noise( uv * 10.0 ) );
    
    // Output to screen
    fragColor = vec4(col,1.0);
}
