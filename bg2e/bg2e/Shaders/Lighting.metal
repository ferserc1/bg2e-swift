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


float3 basicPBRLight(Lighting lighting) {
    return lighting.baseColor;
}
