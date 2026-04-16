float barsize = 0.1;
int count=0;// unused !
vec2 position;
vec3 color;



vec3 mixcol(float value, float r, float g, float b)
{
	return vec3(value * r, value * g, value * b);
}

void bar(float pos, float r, float g, float b)
{
	 if ((position.y <= pos + barsize) && (position.y >= pos - barsize))
		color = mixcol(1.0 - abs(pos - position.y) / barsize, r , g, b);
}
 
	float r,g,b,posy=-1.0;


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q =96.*fragCoord.xy / iResolution.xy;
    position = ( fragCoord.xy / iResolution.xy );
	position = position * vec2(2.0) - vec2(0.95); 	
	
	float t=0.5+sin(iTime*2.); 
    position *=2.*floor(position*128.0)/128. ;
    
  	float tc=texture(iChannel0,q/128.).x;
   
    
   barsize=tc;
  
   
   bar(abs(tc*.8),sqrt(pow(q.y/q.x,-6.) ) ,tc*sqrt(q.y*q.x)-t*50., 1.0);
 
    
  
    fragColor = vec4(color,1.0);
  
    
}
