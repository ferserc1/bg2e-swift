//
//  BG2SceneComponent.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2SceneComponent {
    var typeName: String {
        get {
            return String(describing: type(of: self))
        }
    }
    
    
}
