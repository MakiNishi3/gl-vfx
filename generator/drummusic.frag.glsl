vec3 DRUM_COLOR = vec3(255.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0);
vec3 DRUM_SIDE_COLOR = vec3(203.0 / 255.0, 200.0 / 255.0, 217.0 / 255.0);
vec3 DRUM_BACK_COLOR = vec3(149.0 / 255.0, 20.0 / 255.0, 51.0 / 255.0);
vec3 EQUALIZER_COLOR = vec3(0.0, 1.0, 0.0);
vec3 DRUMMER_COLOR = vec3(0.0, 0.0, 0.0);
vec3 DRUMMER_FACE_COLOR = vec3(247.0 / 255.0, 212.0 / 255.0, 184.0 / 225.0);
vec3 STICK_COLOR = vec3(168.0 / 255.0, 81.0 / 255.0, 72.0 / 255.0);

vec3 BACK_COLOR = vec3(108.0 / 255.0, 41.0 / 255.0, 94.0 / 255.0);
vec3 BACK_COLOR_2 = vec3(75.0 / 255.0, 59.0 / 255.0, 107.0 / 255.0);

float TOTAL_PLAY_TIME = 0.95;
int NUM_BREAKS = 192;

float ShapeQuad(in vec2 st, in vec2 c, in vec2 sizeX, in vec2 sizeY){
    
    vec2 dist = st - c;
    vec2 res = vec2(step(dist.x, sizeX.y) * step(-dist.x, sizeX.x), step(dist.y, sizeY.y) * step(-dist.y, sizeY.x));
	return res.x * res.y;
}

float ShapeCircle(in vec2 st, in vec2 c, in float r)
{
    vec2 dist = st - c;
	return float(1.0 - step(r, dot(dist, dist) * 2.0));
}

float ShapeCircle2(in vec2 st, in vec2 c, in float r, in vec2 coef)
{
    vec2 stC = st;
    stC -= c;
    stC *= coef;
    stC += c;
    
    vec2 dist = stC - c;
	float v1 = float(1.0 - step(r, dot(dist, dist) * 2.0));
    return v1;
}

vec3 Mult(vec3 color, vec3 origColor, float v)
{
    vec3 c = mix(color, origColor, v);
    return c;
}

vec2 Rotate(in vec2 p, float a, in vec2 c)
{
    vec2 res = p;
    
    float sn = sin(a);
    float cs = cos(a);
    
    res -= c;
    
    float x = res.x * cs - res.y * sn;
    float y = res.x * sn + res.y * cs;
    
    res = vec2(x, y) + c;
    
    return res;
}

float GetTime()
{
    return iTime;
}

float GetTotalTime()
{
    return mod(GetTime(), TOTAL_PLAY_TIME) / TOTAL_PLAY_TIME;
}

vec3 DrawDrum1(in vec3 col, in vec2 uv, in vec2 pos, in float scale, in float scaleMult, in float bass)
{
    vec2 allUV = uv;
    allUV -= pos;
    allUV /= scale;
    allUV += pos;
    
    vec2 topUV = uv;
    topUV -= pos;
    topUV /= scale * scaleMult;
    topUV += pos;
    
    vec2 uvLeft = Rotate(allUV, 0.7 + 0.4 * bass, pos);
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(uvLeft, pos + vec2(0.6, 0.0), vec2(0.2, 0.14), vec2(0.02, 0.02)));
    col = Mult(col, DRUM_BACK_COLOR, ShapeCircle(uvLeft, pos + vec2(0.7, 0), 0.01));
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle(topUV, pos + vec2(-0.15 - 0.02, 0.01), 0.52));
    col = Mult(col, DRUM_BACK_COLOR, ShapeCircle(topUV, pos + vec2(-0.15, 0.01), 0.52));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle(topUV, pos, 0.52));
    col = Mult(col, DRUM_COLOR, ShapeCircle(topUV, pos, 0.45));
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(topUV, pos + vec2(-0.29 - 0.3, -0.15), vec2(0.058, 0.13), vec2(0.01, 0.01)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(topUV, pos + vec2(-0.29 - 0.3, 0.15), vec2(0.058, 0.13), vec2(0.01, 0.01)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(topUV, pos + vec2(-0.2 - 0.3, 0.39), vec2(0.0, 0.19), vec2(0.01, 0.01)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(topUV, pos + vec2(-0.2 - 0.3, -0.39), vec2(-0.025, 0.19), vec2(0.01, 0.01)));
    
    vec2 uvRight = Rotate(allUV, -0.7 - 0.4 * bass, pos);
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(uvRight, pos + vec2(-0.6, 0.0), vec2(0.2, 0.04), vec2(-0.04, 0.08)));
    col = Mult(col, DRUM_BACK_COLOR, ShapeCircle(uvRight, pos + vec2(-0.77, 0.06), 0.01));
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(-0.21, 0.57), vec2(0.02, 0.02), vec2(0.07, 0.07)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(0.11, 0.56), vec2(0.02, 0.02), vec2(0.07, 0.07)));
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle(allUV, pos + vec2(0.11, 0.62), 0.005));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle(allUV, pos + vec2(-0.21, 0.62), 0.005));
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(-0.44, 0.62), vec2(0.2, 0.2), vec2(0.015, 0.015)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(0.3, 0.62), vec2(0.2, 0.05), vec2(0.015, 0.015)));
    
    return col;
}

vec3 DrawDrum2(in vec3 col, in vec2 uv, in vec2 pos, in float scale, in float rot)
{
    vec2 allUV = uv;
    allUV -= pos;
    allUV /= scale;
    allUV += pos;
    
    allUV = Rotate(allUV, rot, pos);
    
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle2(allUV, pos + vec2(0.0, 0.085 + 0.01), 0.029, vec2(1.0, 2.5)));
    col = Mult(col, DRUM_BACK_COLOR, ShapeQuad(allUV, pos, vec2(0.12, 0.12), vec2(0.085, 0.085)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeCircle2(allUV, pos + vec2(0.0, -0.085), 0.029, vec2(1.0, 2.8)));
    col = Mult(col, DRUM_BACK_COLOR, ShapeCircle2(allUV, pos + vec2(0.0, 0.085), 0.029, vec2(1.0, 2.8)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos, vec2(0.005, 0.005), vec2(0.085, 0.14)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(-0.11, -0.02), vec2(0.005, 0.005), vec2(0.075, 0.13)));
    col = Mult(col, DRUM_SIDE_COLOR, ShapeQuad(allUV, pos + vec2(0.11, -0.02), vec2(0.005, 0.005), vec2(0.075, 0.13)));
    return col;
}

vec3 DrawDrummer(in vec3 col, in vec2 uv, in vec2 pos, in float scale, in float bass1, in float bass2, in float mainBass)
{
    vec2 allUV = uv;
    allUV -= pos;
    allUV /= scale;
    allUV += pos;
    
    vec2 allOffset = vec2(0.0, 0.2 * (mainBass + bass1) / 2.0);
    vec2 headOffset = vec2(0.0, 0.05 * mainBass);
    
    col = Mult(col, DRUMMER_COLOR, ShapeQuad(allUV, pos + allOffset, vec2(0.12, 0.08), vec2(0.2, 0.05)));
    col = Mult(col, DRUMMER_COLOR, ShapeCircle2(allUV, pos + vec2(-0.02, 0.05) + allOffset, 0.02, vec2(1.0, 2.5)));
    col = Mult(col, DRUMMER_FACE_COLOR, ShapeQuad(allUV, pos + vec2(-0.005, 0.12) + headOffset + allOffset, vec2(0.05, 0.05), vec2(0.05, 0.05)));
    
    float handsLength = 0.12;
    float handsRadius = 0.0012;
    
    // left
    vec2 leftPos = pos + vec2(-0.1, 0.02) + allOffset;
    vec2 leftX = vec2(handsLength, 0.0);
    float leftAngle = 1.2 - 2.3 * bass1;
    vec2 uvLeft = Rotate(allUV, leftAngle, leftPos);
    col = Mult(col, DRUMMER_FACE_COLOR, ShapeQuad(uvLeft, leftPos, leftX, vec2(0.015, 0.015)));
    
    vec2 leftPos2 = leftPos - Rotate(leftX, -leftAngle, vec2(0.0, 0.0));
    col = Mult(col, DRUMMER_FACE_COLOR, ShapeCircle2(allUV, leftPos2, handsRadius, vec2(1.0, 1.0)));
    vec2 uvStickLeft = Rotate(allUV, 0.5, leftPos2);
    col = Mult(col, STICK_COLOR, ShapeQuad(uvStickLeft, leftPos2, vec2(0.0035, 0.0035), vec2(0.0, 0.15)));
    
    // right
    vec2 rightPos = pos + vec2(0.058, 0.02) + allOffset;
    vec2 rightX = vec2(handsLength, 0.0);
    float rightAngle = 2.1 + 2.05 * bass2;
    vec2 uvRight = Rotate(allUV, rightAngle, rightPos);
    col = Mult(col, DRUMMER_FACE_COLOR, ShapeQuad(uvRight, rightPos, rightX, vec2(0.015, 0.015)));
    
    vec2 rightPos2 = rightPos - Rotate(rightX, -rightAngle, vec2(0.0, 0.0));
    col = Mult(col, DRUMMER_FACE_COLOR, ShapeCircle2(allUV, rightPos2, handsRadius, vec2(1.0, 1.0)));
    vec2 uvStickRight = Rotate(allUV, -0.3, rightPos2);
    col = Mult(col, STICK_COLOR, ShapeQuad(uvStickRight, rightPos2, vec2(0.0035, 0.0035), vec2(0.0, 0.15)));
    
    return col;
}

float GetPitch(int fragColumn)
{ 
    float pitch = texture(iChannel0, vec2(float(fragColumn) / float(NUM_BREAKS), 0.0)).x;
    return pitch;
}

float GetBass(in float p1, in float p2)
{
    float bass = 0.0;
    int bassCount = 0;
    for (int i = 0; i < NUM_BREAKS; ++i)
    {
        float p = GetPitch(i);
        if (float(i) / float(NUM_BREAKS) <= p2 && float(i) / float(NUM_BREAKS) >= p1)
        {
            bass += p;
            ++bassCount;
        }
    }
    
    bass /= float(bassCount);
    return bass;
}

float GetMainBass()
{
    return clamp(GetBass(0.0, 0.01) - 0.6, 0.0, 1.0);
}

float GetBackBass()
{
    return clamp(GetBass(0.0, 0.02) - 0.8, 0.0, 1.0);
}

float GetSideBass1()
{
    return clamp(GetBass(0.3, 0.7) + 0.15, 0.0, 1.0);
}

float GetSideBass2()
{
    return clamp(GetBass(0.03, 0.09) - 0.03, 0.0, 1.0);
}

vec3 GetBack(in vec3 col, in vec2 uv, in vec2 pos, in float bass)
{
    col = Mult(col, vec3(0.0, 0.0, 0.0), bass); 
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec3 col = vec3(1.0, 0.0, 0.0);

    uv.x -= 0.25;
    uv.x *= iResolution.x / iResolution.y;

    vec2 pos = vec2(0.5, 0.5);
    float allScale = 0.7;
    
    float mainBass = GetMainBass();
    float sideBass1 = GetSideBass1();
    float sideBass2 = GetSideBass2();
    
    float DRUM_SCALE = 0.5 + 0.15 * mainBass;
    vec2 DRUM_OFFSET = vec2(0.0, 0.2 * mainBass);
    
    float DRUM_1_SCALE = 1.0 + 0.39 * sideBass1;
    float DRUM_2_SCALE = 1.0 + 0.39 * sideBass2;
    vec2 DRUM_1_OFFSET = vec2(0.2 * mainBass, 0.2 * mainBass) * allScale;
    vec2 DRUM_2_OFFSET = vec2(-0.2 * mainBass, 0.2 * mainBass) * allScale;
    
    float DRUM_TOP_SCALE = 1.0;
    vec2 DRUM_TOTAL_OFFSET = vec2(0.0, -0.25 + 0.07);
    vec2 DRUMMER_OFFSET = vec2(0.0, -0.02 + 0.07);
    
    float backColorByBass = GetBackBass();//clamp((mainBass + sideBass1 + sideBass2) / 3.0 - 0.15, 0.0, 1.0);
    col = BACK_COLOR;
    col = GetBack(BACK_COLOR_2, uv, pos, backColorByBass);
    
    col = DrawDrummer(col, uv, pos + DRUMMER_OFFSET, 1.0, sideBass2, sideBass1, mainBass);
    
    col = DrawDrum2(col, uv, pos + vec2(0.28, 0.25 + 0.03) * allScale + DRUM_1_OFFSET + DRUM_TOTAL_OFFSET, allScale * DRUM_1_SCALE, -0.45);
    col = DrawDrum1(col, uv, pos + DRUM_OFFSET + DRUM_TOTAL_OFFSET, DRUM_SCALE * allScale, DRUM_TOP_SCALE, mainBass);
    col = DrawDrum2(col, uv, pos + vec2(-0.37, 0.25 + 0.03) * allScale + DRUM_2_OFFSET + DRUM_TOTAL_OFFSET, allScale * DRUM_2_SCALE, 0.45);
    
    for (int i = 0; i < NUM_BREAKS; ++i)
    {
        float p = GetPitch(i);
        float w = 1.0 / float(NUM_BREAKS);
        float h = p;
        //col = Mult(col, EQUALIZER_COLOR, ShapeQuad(uv, pos + vec2(-0.5, -0.5) + vec2(float(i) * w, 0.0), vec2(w / 2.0, w / 2.0), vec2(0.0, h * 0.5)));
    }
    
    fragColor = vec4(col, 1.0);
}