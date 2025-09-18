#include <metal_stdlib>
using namespace metal;

#define PI 3.14159265359
#define TAU 6.28318530718
#define TILING_FACTOR 1.0
#define MAX_ITER 8
#define SPEED 2.
#define TURB_NUM 10.0
#define TURB_AMP 0.7
#define TURB_SPEED 0.3
#define TURB_FREQ 2.0
#define TURB_EXP 1.4

struct VertexOut {
  float4 position [[position]];
  float2 texCoord;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]], constant float2 *vertices [[buffer(0)]])
{
  VertexOut out;
  out.position = float4(vertices[vertexID] * 2.0 - 1.0, 0.0, 1.0);
  out.texCoord = vertices[vertexID];
  return out;
}

float2 c2uv (float2 coord, float2 iResolution) {
  float mn = min(iResolution.x, iResolution.y);
  return (coord-iResolution.xy/2.)/mn;
  }

fragment float4 circleShader(VertexOut in [[stage_in]],
                            constant float &time [[buffer(0)]],
                            constant float2 &iResolution [[buffer(1)]],
                            texture2d<float> iTexture [[texture(0)]]) {
  float2 uv = in.texCoord * 2.0 - 1.0;
  uv.x *= iResolution.x / iResolution.y;
 
  float d=length(uv);
  float v=sin(8/(d + 0.5) + time * SPEED);
  v= smoothstep(-0.8,1.,v);

  float3 ctint=float3(0.282,0.176,0.404);
  float3 bg =  float3(0.365, 0.231, 0.518);
  float3 col=float3(v);
  col *= d*ctint;
  float3 finalColor = mix(col, bg, 0.5);
  return float4(finalColor, 1.0);
}

float2 turbulence(float2 p, float t)
{
    float freq = TURB_FREQ;
    
  float2x2 rot = float2x2(0.6, -0.8, 0.8, 0.6);
    for(float i=0.0; i<TURB_NUM; i++)
    {
        float phase = freq * (p * rot).y + TURB_SPEED*t + i;
        p += TURB_AMP * rot[0] * sin(phase) / freq;
      rot = rot*float2x2(0.6, -0.8, 0.8, 0.6);
        freq *= TURB_EXP;
    }
    
    return p;
}

fragment float4 smokeShader(VertexOut in [[stage_in]],
                            constant float &time [[buffer(0)]],
                            constant float2 &iResolution [[buffer(1)]],
                            texture2d<float> iTexture [[texture(0)]])
{
  
 
  float2 p = in.texCoord * 2.0 - 1.0;
  p.x *= iResolution.x / iResolution.y;
  p = turbulence(p, time);
    float3 col = 0.5*exp(0.1*p.x*float3(-1,0,2));
    col /= dot(cos(p*3.),sin(-p.yx*3.*.618))+2.0;
    col = 1.0 - exp(-col);
    return float4(col,1);
}



float2 Hash12Polar(float t){
    float a = fract(sin(t*748.31)*367.34)*6.2832;
    float d = fract(sin((t+a)*623.785)*292.45);
    
    return float2(cos(a),sin(a))*d;
}
#define NUM_PARTICLES 5.
#define TIME_LOWERING .2
#define BRIGHTNESS .0004


fragment float4 firework(VertexOut in [[stage_in]], constant float &time [[buffer(0)]], constant float2 &iResolution [[buffer(1)]]) {

  float2 uv = in.texCoord - 0.5;


    float4 color = float4(0.);
    
    for(float j = 0.; j < 3.; j++){
        for(float i = 0.; i < NUM_PARTICLES; i++){

            float t = fract(time*TIME_LOWERING);
            float bright = mix(BRIGHTNESS, 0.001, smoothstep(0.025, 0., t) );
            float2 dir = Hash12Polar(i+1.);
            float dist = distance(uv-dir*t, float2(0, 0)+(Hash12Polar(j*i)/2.));

            color += float4(bright/dist/3, bright/dist/2., bright/dist, bright/dist);
        }
    }
  
  return float4(color);

}

float3 computeProceduralColor(float2 uv, float time, float2 iResolution) {
  float2 r = iResolution;
  
  float2 p = (uv * 2.0 - 1.0) * float2(r.x / r.y, 1.0);
  
  float l = abs(0.7 - dot(p, p));
  float2 v = p * (1.0 - l) / 0.2;
  
  float4 o = float4(0.0);
  
  for (float i = 1.0; i <= 9.0; i++) {
    float2 vi = cos(float2(v.y, v.x) * i + float2(0.0, i) + time/4) / i + 0.7;
    v += vi;
    float4 s = sin(float4(v.x, v.y, v.y, v.x)) + 1.0;
    float m = abs(v.x - v.y) * 0.2;
    o += float4(s.x, s.y, s.z, 1.0) * m;
  }
  
  o = tanh(exp(p.y * float4(1, -1, -2, 0)) * exp(-4.0 * l) / o);
  float f = exp(-2.0 * sin(uv.x) * uv.x + 0.5 * uv.y) *
  fabs(sin(0.1 * sin(0.1 * time) * (uv.x * uv.x + uv.y * sin(0.2 * sin(0.2 * time)))));
  float yf = exp(-2.0 * uv.y * sin(time) * uv.x * cos(sin(0.5 * time))) *
  fabs(cos(0.4 * sin(0.1 * time) * (uv.y - 10.0 * cos(uv.x))));
  
  float3 col = float3(uv.x*uv.y * fabs(1.0 - f * sin(time) + cos(uv.y) * uv.x) - 0.4,
                      fabs(3*uv.x / 2.0 - uv.y - 0.3) / 50.0,
                      uv.y * (1.0 - yf) * (uv.x*sin(time) + uv.y * cos(time)) / 2.0);
  
  float3 color2 = mix(
                      float3(fabs(0.1 * cos(time / 6.0) / 2.0), fabs(0.2 * sin(time / 10.0 + PI / 4.0)), 0.22) / 0.9,
                      float3(0.1 * cos(time/2), 0.1, 0.4 + 0.4*sin(uv.x + uv.y)),
                      uv.y) * 2.0 - 0.25 * sin(time/2);
  
  col = mix(color2, col, 0.6);
  
  float3 dp = float3(0.29 - 0.1 * (uv.x * uv.x * uv.x - uv.y * sin(time / 3.0)),
                     0.0,
                     0.1 - 0.03 * sin(time));
  col = mix(dp, col, 0.5);


  float3 returncolor = mix(col, o.xyz, 0.3);
  
  return returncolor;
}

fragment float4 gradShader(VertexOut in [[stage_in]],
                           constant float &time [[buffer(0)]],
                           constant float2 &iResolution [[buffer(1)]]) {
  float2 uv = in.texCoord;

  
  float2 m2 = uv - 0.5;
  
  
  
  float3 baseColor = computeProceduralColor(uv, time, iResolution);
  if (baseColor.r >= baseColor.g && baseColor.r >= baseColor.b && baseColor.r > 1.0) {
    baseColor.r = 1.0;
  } else if (baseColor.g >= baseColor.r && baseColor.g >= baseColor.b && baseColor.g > 1.0) {
    baseColor.g = 1.0;
  } else if (baseColor.b > 1.0) {
    baseColor.b = 1.0;
  }
  float3 finalColor = baseColor;
  
  return float4(finalColor, 1.0);
}
