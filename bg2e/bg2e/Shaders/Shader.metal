//
//  Shader.metal
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "Lighting.h"

#import "ShaderCommon.h"

constant bool hasColorTexture [[function_constant(FuncConstColorTextureIndex)]];
//constant bool hasNormalTexture [[function_constant(FuncConstNormalTextureIndex)]];
//constant bool hasRoughnessTexture [[function_constant(FuncConstRoughnessTextureIndex)]];
//constant bool hasMetallicTexture [[function_constant(FuncConstMetallicTextureIndex)]];
//constant bool hasAOTexture [[function_constant(FuncConstAOTextureIndex)]];

struct VertexIn {
    float4 position [[ attribute(PositionAttribIndex) ]];
    float3 normal [[ attribute(NormalAttribIndex) ]];
    float2 uv0 [[ attribute(UV0AttribIndex) ]];
    float2 uv1 [[ attribute(UV1AttribIndex) ]];
    float3 tangent [[ attribute(TangentAttribIndex) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 normal;
    float2 uv0;
    float2 uv1;
    float3 tangent;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant MatrixState & matrixState [[ buffer(MatrixStateIndex) ]]) {
    VertexOut result;
    
    result.worldPosition = (matrixState.model * vertexIn.position).xyz;
    result.position = matrixState.projection * matrixState.view * float4(result.worldPosition,1.0);
    result.normal =  matrixState.normal * normalize(vertexIn.normal);
    result.uv0 = vertexIn.uv0;
    result.uv1 = vertexIn.uv1;
    result.tangent = vertexIn.tangent;
    return result;
}

fragment float4 fragment_main(
    VertexOut in [[ stage_in ]],
    constant ShaderLight *lights [[ buffer(LightUniformIndex) ]],
    constant BasicShaderFragmentUniforms &fragmentUniforms [[ buffer(FragmentUniformIndex) ]],
    constant ShaderMaterial &material [[ buffer(PBRMaterialUniformIndex) ]],
    texture2d<float> albedoTexture [[ texture(AlbedoTextureIndex), function_constant(hasColorTexture) ]])
{
    constexpr sampler defaultSampler;
    Lighting lighting;
    lighting.baseColor = (hasColorTexture ? albedoTexture.sample(defaultSampler, in.uv0) : material.albedo).rgb;
    
    return float4(basicPBRLight(lighting), 1.0);
}
