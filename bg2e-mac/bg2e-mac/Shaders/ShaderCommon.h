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
    PointLightType = 5
} LightType;

#endif /* ShaderCommon_h */
