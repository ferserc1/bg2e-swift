//
//  Lighting.h
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 31/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

#ifndef Lighting_h
#define Lighting_h

#import "ShaderCommon.h"

typedef struct Lighting {
    float3 lightDirection;
    float3 viewDirection;
    float3 baseColor;
    float3 normal;
    float metallic;
    float roughness;
    float3 ambientOcclusion;
    float3 lightColor;
} Lighting;


float3 basicPBRLight(Lighting lighting);

#endif /* Lighting_h */
