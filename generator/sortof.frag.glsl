
const vec2 off = vec2(.005);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy/iResolution.xy;
    uv = vec2(uv.x+mod(uv.y*10.+texture(iChannel0,uv.yy*.5).x,.2), .0);
    
    float tr = texture(iChannel0,floor(uv*64.)/64.).x;
	float tg = texture(iChannel0,floor(uv*64.)/64.+off).x;
    float tb = texture(iChannel0,floor(uv*64.)/64.-off).x;

	fragColor = vec4(tr,tg,tb,1.);
}
