const vec3 eye = vec3(0.0,0.0,-3.0);
const vec3 center = vec3(0.0,0.0,-5.0);

const float M_PI = 3.14159265358979;
const float CO_PLANE_TRESHOLD = 0.01;
const float LENGTH_THRESHOLD = 0.04;
const int MAX_CUBE = 5;

const vec3 cube_verts[8] = vec3[8](
    vec3(-0.5,-0.5,-0.5),
    vec3(0.5,-0.5,-0.5),
    vec3(0.5,0.5,-0.5),
    vec3(-0.5,0.5,-0.5),
    vec3(-0.5,-0.5,0.5),
    vec3(0.5,-0.5,0.5),
    vec3(0.5,0.5,0.5),
    vec3(-0.5,0.5,0.5)
);

const vec3 move_cube = vec3(-0.5,-0.5,5.0);

const int cube_edges[24] = int[24](
    0,1,
    1,2,
    2,3,
    3,0,
    4,5,
    5,6,
    6,7,
    7,4,
    0,4,
    1,5,
    2,6,
    3,7
);



vec3 get_rayDirection(vec2 uv){
    vec3 start = vec3(uv,0.0)+eye;
    vec3 delta = start-center;
    delta.x*=iResolution.x/iResolution.y;
    delta = normalize(delta);
    return delta;
}
float soundEffect(float x){
    float forced=clamp(iTime/5.0,0.3,2.0);
    return texture( iChannel0, vec2(x, 0.3) ).x*forced;
}



vec3 intersectCubes(vec3 start, vec3 dir){
    float cos_time = cos(iTime);
    float sin_time = sin(iTime);
    
    mat3 rotation = mat3(
        cos_time, -sin_time, 0.0,
        sin_time, cos_time, 0.0,
        0.0,0.0,1.0
        );
    
    
    vec3 col = vec3(0.0);
    
    
    for(int cube_id=0; cube_id<MAX_CUBE; ++cube_id){
        
        float sound_eff = soundEffect(float(cube_id)/float(MAX_CUBE));
    	vec3 cube_motion = vec3(0.0,0.0,sin_time-sound_eff*4.0);
        
        
        vec3 cube_position = vec3(-float(MAX_CUBE/2)+float(cube_id)*1.5,0.0,0.0)
            +move_cube+cube_motion;
        for(int i=0; i<int(cos(iTime+sound_eff+float(cube_id))*6.0+6.5);++i){
            vec3 first_vert = cube_verts[cube_edges[i*2]]*rotation + cube_position;
            vec3 second_vert = cube_verts[cube_edges[i*2+1]]*rotation + cube_position;

            vec3 line_dir = second_vert-first_vert;
            vec3 look_line_dir = first_vert - start;

            vec3 line_look_cross = cross(dir,line_dir);

            float dot_pr = dot(look_line_dir, line_look_cross);
            
            float normed = dot_pr/CO_PLANE_TRESHOLD/(length(look_line_dir)*length(line_look_cross))*0.5+0.5;
            

            if(abs(dot_pr)<=CO_PLANE_TRESHOLD)
            {
                
                float s = dot(cross(look_line_dir, line_dir),line_look_cross) / dot(line_look_cross,line_look_cross);

                    vec3 intersection = start + s * dir;
                	vec3 inter_vert_1 = intersection - first_vert;
                	vec3 inter_vert_2 = intersection - second_vert;
                    float l_eq = dot(inter_vert_1,inter_vert_1) + dot(inter_vert_2,inter_vert_2);
                    float r_eq = dot(line_dir,line_dir)+LENGTH_THRESHOLD;
                    if(l_eq<=r_eq)
                        col=mix(col,vec3(sound_eff),pow(1.0-abs(normed-0.5),2.0));
            }
                
        }
    }
    return col;
}
/*
vec3 intersectCubes_opt(vec3 start, vec3 dir){
    float cos_time = cos(iTime);
    float sin_time = sin(iTime);
    
    mat3 rotation = mat3(
        cos_time, -sin_time, 0.0,
        sin_time, cos_time, 0.0,
        0.0,0.0,1.0
        );
    
    
    vec3 col = vec3(0.0);
    
    
    for(int cube_id=0; cube_id<MAX_CUBE; ++cube_id){
        
        float sound_eff = soundEffect(float(cube_id)/float(MAX_CUBE));
    	vec3 cube_motion = vec3(0.0,0.0,sin_time-sound_eff*4.0);
        
        
        vec3 cube_position = vec3(-float(MAX_CUBE/2)+float(cube_id)*1.5,0.0,0.0)
            +move_cube+cube_motion;
        for(int i=0; i<int(cos(iTime+sound_eff+float(cube_id))*6.0+6.5);++i){
            vec3 first_vert = cube_verts[cube_edges[i*2]]*rotation + cube_position;
            vec3 second_vert = cube_verts[cube_edges[i*2+1]]*rotation + cube_position;
            
            vec3 vec_to_first = first_vert-start;
            vec3 vec_to_second = second_vert-start;
            
            float dist_to_first = length(vec_to_first);
            float dist_to_second = length(vec_to_second);
            
            vec3 dir_to_first = vec_to_first/dist_to_first;
            vec3 dir_to_second = vec_to_second/dist_to_second;
            
            vec3 dir_diff_first = dir - dir_to_first;
            vec3 dir_diff_second = dir - dir_to_second;
            
            float dot_first = dot(dir_diff_first,dir_diff_first);
            float dot_second = dot(dir_diff_second,dir_diff_second);
            
            if(dot_first<=0.001)
                col = mix(col, vec3(1.0),1.0/dot_first*0.001);
            
            if(dot_second<=0.001)
                col = mix(col, vec3(1.0),1.0/dot_second*0.001);
                
        }
    }
    return col;
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from -1 to 1)
    vec2 uv = (fragCoord/iResolution.xy - 0.5)*2.0;

    vec3 direction = get_rayDirection(uv);
    //if(iFrame%4==0){
    vec3 color = intersectCubes(center,direction);

    // Output to screen
    fragColor = vec4(color,1.0);
}
