#include <metal_stdlib>
#include "shaderFunctions.metal"
using namespace metal;

struct VertexIn {
  float4 position [[ attribute(0) ]];
  float4 normal   [[ attribute(1) ]];
  float4 color    [[ attribute(2) ]];
  float  value    [[ attribute(3) ]];
};

struct VertexUniforms {
  float time;
  float4x4 projectionView;
  float4x4 normal;
};

struct ShdaderInOut {
  float4 position [[ position ]];
  float4 color;
};

vertex ShdaderInOut staticShaderVertex(VertexIn in [[stage_in]],
                                       const device VertexUniforms &uniforms[[buffer(1)]]) {
  ShdaderInOut out;
  
  float4 displaced = in.position + in.normal*in.value*0.3*sin(uniforms.time*2.5);
  out.position = uniforms.projectionView * displaced;
  
  float3 lightDir = normalize(float3(-1,1,-1));
  float diffuse = max(min(-(dot(in.normal.xyz,lightDir)),1.0),0.0);
  
  float r = (in.value/3+0.2)*2;
  Colors type = triple;
  float4 color = Blender(r,type);//Blender((r-0.5)*sin(uniforms.time*2.5)+0.5,type);
  
  diffuse += 0.3;
  //diffuse = 1;
  
  out.color = pow(diffuse*color,1/2.2);
  return out;
}

fragment half4 staticShaderFragment(ShdaderInOut in [[stage_in]]) {
  
  half4 color = half4(in.color);
  return color;
}



