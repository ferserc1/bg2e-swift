//
//  BG2LightComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 12/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2LightComponent: BG2SceneComponent {
    private let _light: BG2Light = BG2Light()
    
    public var light: BG2Light {
        get {
            return _light
        }
    }
    
    public override init() {
        super.init()
    }
}
