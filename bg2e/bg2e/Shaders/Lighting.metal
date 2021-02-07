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

constant float pi = 3.1415926535897932384626433832795;

float3 basicPBRLight(Lighting lighting) {
    // Rendering equation courtesy of Apple et al.
    float nDotl = max(0.001, saturate(dot(lighting.normal, lighting.lightDirection)));
    float3 halfVector = normalize(lighting.lightDirection + lighting.viewDirection);
    float nDoth = max(0.001, saturate(dot(lighting.normal, halfVector)));
    float nDotv = max(0.001, saturate(dot(lighting.normal, lighting.viewDirection)));
    float hDotl = max(0.001, saturate(dot(lighting.lightDirection, halfVector)));
    
    // specular roughness
    float specularRoughness = lighting.roughness * (1.0 - lighting.metallic) + lighting.metallic;
    
    // Distribution
    float Ds;
    if (specularRoughness >= 1.0) {
      Ds = 1.0 / pi;
    }
    else {
      float roughnessSqr = specularRoughness * specularRoughness;
      float d = (nDoth * roughnessSqr - nDoth) * nDoth + 1;
      Ds = roughnessSqr / (pi * d * d);
    }
    
    // Fresnel
    float3 Cspec0 = float3(1.0);
    float fresnel = pow(clamp(1.0 - hDotl, 0.0, 1.0), 5.0);
    float3 Fs = float3(mix(float3(Cspec0), float3(1), fresnel));
    
    
    // Geometry
    float alphaG = (specularRoughness * 0.5 + 0.5) * (specularRoughness * 0.5 + 0.5);
    float a = alphaG * alphaG;
    float b1 = nDotl * nDotl;
    float b2 = nDotv * nDotv;
    float G1 = (float)(1.0 / (b1 + sqrt(a + b1 - a*b1)));
    float G2 = (float)(1.0 / (b2 + sqrt(a + b2 - a*b2)));
    float Gs = G1 * G2;
    
    float3 specularOutput = (Ds * Gs * Fs * lighting.lightColor) * (1.0 + lighting.metallic * lighting.baseColor) + lighting.metallic * lighting.lightColor * lighting.baseColor;
    specularOutput = specularOutput * lighting.ambientOcclusion;
    
    return specularOutput;
}
