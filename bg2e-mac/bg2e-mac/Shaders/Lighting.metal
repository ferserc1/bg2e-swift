//
//  Lighting.metal
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 31/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

#include <metal_stdlib>
#include "Lighting.h"

#include "ShaderCommon.h"

using namespace metal;


float3 phongLighting(thread PhongLight & l,
                     thread PhongMaterial & m)
{
    float3 lightDirection = normalize(l.direction);
    float diffuseIntensity = saturate(dot(lightDirection,m.normal));
    float3 diffuseColor = l.color * m.diffuse.rgb * diffuseIntensity;
    
    
    return diffuseColor;
}
