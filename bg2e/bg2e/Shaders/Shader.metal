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
constant bool hasNormalTexture [[function_constant(FuncConstNormalTextureIndex)]];
constant bool hasRoughnessTexture [[function_constant(FuncConstRoughnessTextureIndex)]];
constant bool hasMetallicTexture [[function_constant(FuncConstMetallicTextureIndex)]];
constant bool hasAOTexture [[function_constant(FuncConstAOTextureIndex)]];

struct VertexIn {
    float3 position [[ attribute(PositionAttribIndex) ]];
    float3 normal [[ attribute(NormalAttribIndex) ]];
    float2 uv0 [[ attribute(UV0AttribIndex) ]];
    float2 uv1 [[ attribute(UV1AttribIndex) ]];
    //float3 tangent [[ attribute(TangentAttribIndex) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float3 worldNormal;
    float2 uv0;
    float2 uv1;
    //float3 worldTangent;
    //float3 worldBitangent;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant MatrixState & matrixState [[ buffer(MatrixStateIndex) ]]) {
    VertexOut result;
    
    result.worldPosition = (matrixState.model * float4(vertexIn.position,1.0)).xyz;
    result.position = matrixState.projection * matrixState.view * float4(result.worldPosition,1.0);
    result.worldNormal =  matrixState.normal * normalize(vertexIn.normal);
    result.uv0 = vertexIn.uv0;
    result.uv1 = vertexIn.uv1;
    //result.worldTangent = (matrixState.normal * normalize(vertexIn.tangent)).xyz;
    //result.worldBitangent = result.worldNormal * result.worldTangent;
    return result;
}

fragment float4 fragment_main(
    VertexOut in [[ stage_in ]],
    constant ShaderLight *lights [[ buffer(LightUniformIndex) ]],
    constant BasicShaderFragmentUniforms &fragmentUniforms [[ buffer(FragmentUniformIndex) ]],
    constant ShaderMaterial &material [[ buffer(PBRMaterialUniformIndex) ]],
    texture2d<float> albedoTexture [[ texture(AlbedoTextureIndex), function_constant(hasColorTexture) ]],
    texture2d<float> metallicTexture [[ texture(MetallicTextureIndex), function_constant(hasMetallicTexture) ]],
    texture2d<float> roughnessTexture [[ texture(RoughnessTextureIndex), function_constant(hasRoughnessTexture) ]],
    texture2d<float> normalTexture [[ texture(NormalTextureIndex), function_constant(hasNormalTexture) ]],
    texture2d<float> aoTexture [[ texture(AOTextureIndex), function_constant(hasAOTexture) ]])
{
    constexpr sampler defaultSampler;
    
    float3 baseColor;
    float alpha;
    if (hasColorTexture) {
        float4 c = albedoTexture.sample(defaultSampler, in.uv0);
        baseColor = c.rgb;
        alpha = c.a;
    } else {
        baseColor = material.albedo.rgb;
        alpha = material.albedo.a;
    }
    
    float metallic;
    if (hasMetallicTexture) {
        metallic = metallicTexture.sample(defaultSampler, in.uv0).r;
    } else {
        metallic = material.metallic;
    }
    
    float roughness;
    if (hasRoughnessTexture) {
        roughness = roughnessTexture.sample(defaultSampler, in.uv0).r;
    } else {
        roughness = material.roughness;
    }
    
    float ambientOcclusion;
    if (hasAOTexture) {
        ambientOcclusion = aoTexture.sample(defaultSampler, in.uv0).r;
    } else {
        ambientOcclusion = 1.0;
    }
    
    float3 normal;
    //if (hasNormalTexture) {
    //    float3 normalValue = normalTexture.sample(defaultSampler, in.uv0).xyz * 2.0 -1.0;
    //    normal = in.worldNormal * normalValue.z
    //        + in.worldTangent * normalValue.x
    //        + in.worldBitangent * normalValue.y;
    //}
    //else {
        normal = in.worldNormal;
    //}
    normal = normalize(normal);
    
    return float4(normal, 1.0);
    
    float3 viewDirection = normalize(fragmentUniforms.cameraPosition - in.worldPosition);

    ShaderLight light = lights[0];
    // TODO: Calculate light direction depending on the light type
    float3 lightDirection = light.direction;
    
    Lighting lighting;
    lighting.lightDirection = lightDirection;
    lighting.viewDirection = viewDirection;
    lighting.baseColor = baseColor;
    lighting.normal = normal;
    lighting.metallic = metallic;
    lighting.roughness = roughness;
    lighting.ambientOcclusion = ambientOcclusion;
    lighting.lightColor = light.color;
    
    
    float3 specularOutput = basicPBRLight(lighting);
    
    // Compute lambertian deffuse
    float nDotl = max(0.001, saturate(dot(lighting.normal, lighting.lightDirection)));
    float3 diffuseColor = light.color * baseColor * nDotl * ambientOcclusion;
    diffuseColor *= 1.0 - metallic;
    
    float4 finalColor = float4(specularOutput + diffuseColor, 1.0);
    return finalColor;
}
