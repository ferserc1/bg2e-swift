//
//  BG2DrawableComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 12/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2DrawableComponent: BG2SceneComponent {
    
    public var drawableItems: [BG2DrawableItem] = []
    
    public override init() {
        super.init()
    }
}
