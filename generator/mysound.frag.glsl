//Font code ripped from: ASCII Characters... font texture by Bart_Verheijen
//  Created by Bart Verheijen 2016
//  License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// font data is copied from Flyguy:
// https://www.shadertoy.com/view/Mt2GWD

//Automatically generated from the 8x12 font sheet here:
//http://www.massmind.org/techref/datafile/charset/extractor/charset_extractor.htm

#define CHAR_SIZE vec2(8, 12)

vec4 ch_spc = vec4(0x000000,0x000000,0x000000,0x000000);
vec4 ch_exc = vec4(0x003078,0x787830,0x300030,0x300000);
vec4 ch_quo = vec4(0x006666,0x662400,0x000000,0x000000);
vec4 ch_hsh = vec4(0x006C6C,0xFE6C6C,0x6CFE6C,0x6C0000);
vec4 ch_dol = vec4(0x30307C,0xC0C078,0x0C0CF8,0x303000);
vec4 ch_pct = vec4(0x000000,0xC4CC18,0x3060CC,0x8C0000);
vec4 ch_amp = vec4(0x0070D8,0xD870FA,0xDECCDC,0x760000);
vec4 ch_apo = vec4(0x003030,0x306000,0x000000,0x000000);
vec4 ch_lbr = vec4(0x000C18,0x306060,0x603018,0x0C0000);
vec4 ch_rbr = vec4(0x006030,0x180C0C,0x0C1830,0x600000);
vec4 ch_ast = vec4(0x000000,0x663CFF,0x3C6600,0x000000);
vec4 ch_crs = vec4(0x000000,0x18187E,0x181800,0x000000);
vec4 ch_com = vec4(0x000000,0x000000,0x000038,0x386000);
vec4 ch_dsh = vec4(0x000000,0x0000FE,0x000000,0x000000);
vec4 ch_per = vec4(0x000000,0x000000,0x000038,0x380000);
vec4 ch_lsl = vec4(0x000002,0x060C18,0x3060C0,0x800000);
vec4 ch_0 = vec4(0x007CC6,0xD6D6D6,0xD6D6C6,0x7C0000);
vec4 ch_1 = vec4(0x001030,0xF03030,0x303030,0xFC0000);
vec4 ch_2 = vec4(0x0078CC,0xCC0C18,0x3060CC,0xFC0000);
vec4 ch_3 = vec4(0x0078CC,0x0C0C38,0x0C0CCC,0x780000);
vec4 ch_4 = vec4(0x000C1C,0x3C6CCC,0xFE0C0C,0x1E0000);
vec4 ch_5 = vec4(0x00FCC0,0xC0C0F8,0x0C0CCC,0x780000);
vec4 ch_6 = vec4(0x003860,0xC0C0F8,0xCCCCCC,0x780000);
vec4 ch_7 = vec4(0x00FEC6,0xC6060C,0x183030,0x300000);
vec4 ch_8 = vec4(0x0078CC,0xCCEC78,0xDCCCCC,0x780000);
vec4 ch_9 = vec4(0x0078CC,0xCCCC7C,0x181830,0x700000);
vec4 ch_col = vec4(0x000000,0x383800,0x003838,0x000000);
vec4 ch_scl = vec4(0x000000,0x383800,0x003838,0x183000);
vec4 ch_les = vec4(0x000C18,0x3060C0,0x603018,0x0C0000);
vec4 ch_equ = vec4(0x000000,0x007E00,0x7E0000,0x000000);
vec4 ch_grt = vec4(0x006030,0x180C06,0x0C1830,0x600000);
vec4 ch_que = vec4(0x0078CC,0x0C1830,0x300030,0x300000);
vec4 ch_ats = vec4(0x007CC6,0xC6DEDE,0xDEC0C0,0x7C0000);
vec4 ch_A = vec4(0x003078,0xCCCCCC,0xFCCCCC,0xCC0000);
vec4 ch_B = vec4(0x00FC66,0x66667C,0x666666,0xFC0000);
vec4 ch_C = vec4(0x003C66,0xC6C0C0,0xC0C666,0x3C0000);
vec4 ch_D = vec4(0x00F86C,0x666666,0x66666C,0xF80000);
vec4 ch_E = vec4(0x00FE62,0x60647C,0x646062,0xFE0000);
vec4 ch_F = vec4(0x00FE66,0x62647C,0x646060,0xF00000);
vec4 ch_G = vec4(0x003C66,0xC6C0C0,0xCEC666,0x3E0000);
vec4 ch_H = vec4(0x00CCCC,0xCCCCFC,0xCCCCCC,0xCC0000);
vec4 ch_I = vec4(0x007830,0x303030,0x303030,0x780000);
vec4 ch_J = vec4(0x001E0C,0x0C0C0C,0xCCCCCC,0x780000);
vec4 ch_K = vec4(0x00E666,0x6C6C78,0x6C6C66,0xE60000);
vec4 ch_L = vec4(0x00F060,0x606060,0x626666,0xFE0000);
vec4 ch_M = vec4(0x00C6EE,0xFEFED6,0xC6C6C6,0xC60000);
vec4 ch_N = vec4(0x00C6C6,0xE6F6FE,0xDECEC6,0xC60000);
vec4 ch_O = vec4(0x00386C,0xC6C6C6,0xC6C66C,0x380000);
vec4 ch_P = vec4(0x00FC66,0x66667C,0x606060,0xF00000);
vec4 ch_Q = vec4(0x00386C,0xC6C6C6,0xCEDE7C,0x0C1E00);
vec4 ch_R = vec4(0x00FC66,0x66667C,0x6C6666,0xE60000);
vec4 ch_S = vec4(0x0078CC,0xCCC070,0x18CCCC,0x780000);
vec4 ch_T = vec4(0x00FCB4,0x303030,0x303030,0x780000);
vec4 ch_U = vec4(0x00CCCC,0xCCCCCC,0xCCCCCC,0x780000);
vec4 ch_V = vec4(0x00CCCC,0xCCCCCC,0xCCCC78,0x300000);
vec4 ch_W = vec4(0x00C6C6,0xC6C6D6,0xD66C6C,0x6C0000);
vec4 ch_X = vec4(0x00CCCC,0xCC7830,0x78CCCC,0xCC0000);
vec4 ch_Y = vec4(0x00CCCC,0xCCCC78,0x303030,0x780000);
vec4 ch_Z = vec4(0x00FECE,0x981830,0x6062C6,0xFE0000);
vec4 ch_lsb = vec4(0x003C30,0x303030,0x303030,0x3C0000);
vec4 ch_rsl = vec4(0x000080,0xC06030,0x180C06,0x020000);
vec4 ch_rsb = vec4(0x003C0C,0x0C0C0C,0x0C0C0C,0x3C0000);
vec4 ch_pow = vec4(0x10386C,0xC60000,0x000000,0x000000);
vec4 ch_usc = vec4(0x000000,0x000000,0x000000,0x00FF00);
vec4 ch_a = vec4(0x000000,0x00780C,0x7CCCCC,0x760000);
vec4 ch_b = vec4(0x00E060,0x607C66,0x666666,0xDC0000);
vec4 ch_c = vec4(0x000000,0x0078CC,0xC0C0CC,0x780000);
vec4 ch_d = vec4(0x001C0C,0x0C7CCC,0xCCCCCC,0x760000);
vec4 ch_e = vec4(0x000000,0x0078CC,0xFCC0CC,0x780000);
vec4 ch_f = vec4(0x00386C,0x6060F8,0x606060,0xF00000);
vec4 ch_g = vec4(0x000000,0x0076CC,0xCCCC7C,0x0CCC78);
vec4 ch_h = vec4(0x00E060,0x606C76,0x666666,0xE60000);
vec4 ch_i = vec4(0x001818,0x007818,0x181818,0x7E0000);
vec4 ch_j = vec4(0x000C0C,0x003C0C,0x0C0C0C,0xCCCC78);
vec4 ch_k = vec4(0x00E060,0x60666C,0x786C66,0xE60000);
vec4 ch_l = vec4(0x007818,0x181818,0x181818,0x7E0000);
vec4 ch_m = vec4(0x000000,0x00FCD6,0xD6D6D6,0xC60000);
vec4 ch_n = vec4(0x000000,0x00F8CC,0xCCCCCC,0xCC0000);
vec4 ch_o = vec4(0x000000,0x0078CC,0xCCCCCC,0x780000);
vec4 ch_p = vec4(0x000000,0x00DC66,0x666666,0x7C60F0);
vec4 ch_q = vec4(0x000000,0x0076CC,0xCCCCCC,0x7C0C1E);
vec4 ch_r = vec4(0x000000,0x00EC6E,0x766060,0xF00000);
vec4 ch_s = vec4(0x000000,0x0078CC,0x6018CC,0x780000);
vec4 ch_t = vec4(0x000020,0x60FC60,0x60606C,0x380000);
vec4 ch_u = vec4(0x000000,0x00CCCC,0xCCCCCC,0x760000);
vec4 ch_v = vec4(0x000000,0x00CCCC,0xCCCC78,0x300000);
vec4 ch_w = vec4(0x000000,0x00C6C6,0xD6D66C,0x6C0000);
vec4 ch_x = vec4(0x000000,0x00C66C,0x38386C,0xC60000);
vec4 ch_y = vec4(0x000000,0x006666,0x66663C,0x0C18F0);
vec4 ch_z = vec4(0x000000,0x00FC8C,0x1860C4,0xFC0000);
vec4 ch_lpa = vec4(0x001C30,0x3060C0,0x603030,0x1C0000);
vec4 ch_bar = vec4(0x001818,0x181800,0x181818,0x180000);
vec4 ch_rpa = vec4(0x00E030,0x30180C,0x183030,0xE00000);
vec4 ch_tid = vec4(0x0073DA,0xCE0000,0x000000,0x000000);
vec4 ch_lar = vec4(0x000000,0x10386C,0xC6C6FE,0x000000);



/**
 * x [0..8>
 * y [0..12>
 **/
float drawCh(in vec4 character, in float x, in float y)
{
    if(x<0.0 || y<0.0 || x>7.0 || y>11.0) return 0.0;
    float word = 0.0;
    if (y>5.9)
    {
        if (y>8.9) word = character.x;
        else       word = character.y;
    }
    else
    {
        if (y>2.9) word = character.z;
        else       word = character.a;
    }
    float n = floor(7.0-x + 8.0*mod(y,3.0));
    return mod(floor(word/pow(2.0,n)), 2.0);
}
vec4 numToSprite(float a)
{
    if (a<0.5) return ch_0;
    if (a<1.5) return ch_1;
    if (a<2.5) return ch_2;
    if (a<3.5) return ch_3;
    if (a<4.5) return ch_4;
    if (a<5.5) return ch_5;
    if (a<6.5) return ch_6;
    if (a<7.5) return ch_7;
    if (a<8.5) return ch_8;
    else return ch_9;
}
//from IQ
float Capsule(in vec2 p, vec3 r){return length(vec2(p.x-clamp(p.x,r.x,r.y),p.y))-r.z;}

#define F(ch) drawCh(ch, X-=8.0, Y)
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv=fragCoord.xy/iResolution.xy;
    float x=floor(uv.x*36.0)/36.0;
    
    float a=0.0;
    if(x>=2.0/36.0 && x<34.0/36.0)a=texture(iChannel0,vec2(x-2.0/36.0,0.25)).r;
    a*=0.8;
    vec3 col=vec3(a,2.0*a,1.0-a)*step(0.0,min(a-uv.y,uv.x-x-1.0/iResolution.x));
    float X=floor(fragCoord.x-iResolution.x+mod(iTime*22.0,iResolution.x*2.0)),Y=floor(fragCoord.y-iResolution.y*2.0/3.0);
    a=F(ch_V)+F(ch_i)+F(ch_l)+F(ch_l)+F(ch_a)+F(ch_i)+F(ch_n)+F(ch_o)+F(ch_u)+F(ch_s);
    X-=10.0;
    a+=F(ch_W)+F(ch_i)+F(ch_l)+F(ch_l)+F(ch_i)+F(ch_s);
    X-=10.0;
    a+=F(ch_dsh);
    X-=10.0;
    a+=F(ch_T)+F(ch_o)+F(ch_o)+F(ch_spc)+F(ch_T)+F(ch_e)+F(ch_y)+F(ch_per);
    a+=F(ch_spc)+F(ch_B)+F(ch_e)+F(ch_e)+F(ch_spc)+F(ch_Y)+F(ch_e)+F(ch_n);
    
    X=floor(fragCoord.x*0.5);Y=floor(fragCoord.y*0.5-iResolution.y*0.5+20.0);
    float n=iChannelTime[0];
    float c=floor(max(log(n)/log(10.0),0.0));
    if(c>0.0)n/=pow(10.0,c);
    for(float i=0.0;i<5.0;i++){
        if(i>c+2.)continue;
		float ch=floor(n);
		a+=F(numToSprite(ch));
		n=(n-ch)*10.0;
        if(i==c)a+=F(ch_per);
    }
    a+=F(ch_s);
    X=floor(fragCoord.x*0.5-iResolution.x*0.25);
    a+=F(ch_S)+F(ch_O)+F(ch_U)+F(ch_N)+F(ch_D)+F(ch_C)+F(ch_L)+F(ch_O)+F(ch_U)+F(ch_D);
    float d=Capsule(uv-vec2(0.4,0.9),vec3(-0.05,0.04,0.03));
    d=min(d,Capsule(uv-vec2(0.4,0.93),vec3(-0.02,0.02,0.03)));
    d=min(d,Capsule(uv-vec2(0.4,0.95),vec3(0.02,0.02,0.03)));
    if(d<0.0 && (uv.x-0.4>0.0 || mod(uv.x,0.012)>0.003))a=1.0;
    if(a>0.0)col=vec3(1.0);
    
    fragColor = vec4(col,1.0);
}