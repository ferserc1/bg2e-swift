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
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef enum {
    DirectionalLightType = 4,
    SpotLightType = 1,
    PointLightType = 5
} LightType;

#endif /* ShaderCommon_h */
