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
    vector_float4 diffuse;
    vector_float4 specular;
    float shininess;
    vector_float3 normal;
} PhongMaterial;

#endif /* ShaderCommon_h */
