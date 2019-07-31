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

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
    float2 uv0 [[ attribute(2) ]];
    float2 uv1 [[ attribute(3) ]];
    float3 tangent [[ attribute(4) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
    float2 uv0;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant MatrixState & matrixState [[ buffer(5) ]]) {
    VertexOut result;
    result.position = matrixState.projection * matrixState.view * matrixState.model * vertexIn.position;
    
    result.normal =  matrixState.normal * normalize(vertexIn.normal);
    result.uv0 = vertexIn.uv0;
    return result;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]],
                              texture2d<float> albedoTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler;
    //return float4(albedoTexture.sample(textureSampler, in.uv0).rgb, 1.0);
    
    PhongMaterial mat;
    mat.diffuse = albedoTexture.sample(textureSampler, in.uv0);
    mat.specular = float4(1.0);
    mat.shininess = 0;
    mat.normal = in.normal;
    
    PhongLight light;
    light.color = float3(0.0, 0.0, 1.0);
    light.type = DirectionalLightType;
    light.position = float3(0.0, 0.0, 0.0);
    light.attenuation = float3(1.0, 0.5, 0.1);
    float3 lighting = phongLighting(light,mat);
    
    return float4(in.normal * lighting,1.0);
}
