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

float3 phongLighting(thread PhongLight & l, thread PhongMaterial & m);

#endif /* Lighting_h */