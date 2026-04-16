void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    fragColor = vec4(0.0,0.0,0.0,1.0);
    vec2 uv = fragCoord.xy / iResolution.xy;
    int tx = int(uv.x*512.0);
    int ty = int(uv.y*512.0);
    float sum = 0.0;
    int starter = int(floor(float(tx)/16.0))*16;
    int diff = tx-starter;
    for (int i = 0; i<32;i++) {
		sum = sum + texelFetch(iChannel0, ivec2(starter+i,0), 0 ).x;
    }
    float height = (sum/32.0)-.2;
    sum = ((sum/32.0)-.2)*1.25;
    float col = sum;
    if (height > uv.y && diff>2) {
        fragColor = vec4(col, (sin(col*3.14)+1.0)/2.0, 1.0-col,1.0);
    }
}