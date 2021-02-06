//
//  ShaderCommon.h
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 03/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

#ifndef ShaderCommon_h
#define ShaderCommon_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 model;
    matrix_float4x4 view;
    matrix_float4x4 projection;
    matrix_float3x3 normal;
} MatrixState;

typedef enum {
    DirectionalLightType = 4,
    SpotLightType = 1,
    PointLightType = 5,
    DisabledLightType = 0
} LightType;

typedef enum {
    PositionAttribIndex = 0,
    NormalAttribIndex = 1,
    UV0AttribIndex = 2,
    UV1AttribIndex = 3,
    TangentAttribIndex = 4
} Attributes;

typedef enum {
    MatrixStateIndex = 10,
    LightUniformIndex = 11,
    FragmentUniformIndex = 12,
    PBRMaterialUniformIndex = 13
} UniformBufferIndex;

typedef enum {
    AlbedoTextureIndex = 0,
    AOTextureIndex = 1,
    MetallicTextureIndex = 2,
    RoughnessTextureIndex = 3,
    NormalTextureIndex = 4
} TextureIndex;

typedef struct {
    vector_float3 position;
    vector_float3 direction;
    vector_float3 color;
    vector_float3 specular;
    float intensity;
    vector_float3 attenuation;
    LightType type;
} PhongLight;


typedef struct {
    vector_float4 albedo;
    vector_float2 albedoScale;
    int albedoUV;
    int isTransparent;
    float alphaCutoff;
    
    int aoUV;
    
    float metallic;
    vector_float2 metallicScale;
    int metallicChannel;
    int metallicUV;
    
    float roughness;
    vector_float2 roughnessScale;
    int roughnessChannel;
    int roughnessUV;
    
    vector_float4 fresnel;
    
    vector_float2 normalScale;
    int normalUV;
    
    int castShadows;
    int unlit;
    int visibleToShadows;
    int visible;
} PBRMaterial;

typedef struct {
    uint lightCount;
    vector_float3 cameraPosition;
} BasicShaderFragmentUniforms;

#endif /* ShaderCommon_h */
