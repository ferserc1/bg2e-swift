//
//  Shader.metal
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

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
                          constant Uniforms & mvp [[ buffer(5) ]]) {
    VertexOut result;
    result.position = mvp.projectionMatrix * mvp.viewMatrix * mvp.modelMatrix * vertexIn.position;
    
    result.normal =  mvp.normalMatrix * normalize(vertexIn.normal);
    result.uv0 = vertexIn.uv0;
    return result;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]],
                              texture2d<float> albedoTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler;
    //return float4(albedoTexture.sample(textureSampler, in.uv0).rgb, 1.0);
    return float4(in.normal,1.0);
}
