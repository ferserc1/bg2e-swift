//
//  BG2SceneObject.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2SceneObject {
    private var renderer: BG2Renderer
    public var name: String = ""
    
    public init(withRenderer renderer: BG2Renderer, name: String = "") {
        self.renderer = renderer
        self.name = name
    }
    
    private var children: [BG2SceneObject] = []
    private var parent: BG2SceneObject? = nil
    private var componentIndex: [String:BG2SceneComponent] = [:]
    private var componentArray: [BG2SceneComponent] = []
}


// Component management functions
public extension BG2SceneObject {
    func addComponent(_ comp: BG2SceneComponent) {
        if let existingComp = componentIndex[String(describing: comp.typeName)],
            let index = componentArray.firstIndex(where: { $0.typeName == existingComp.typeName }) {
            componentArray.remove(at: index)
        }
        componentIndex[String(describing: comp.typeName)] = comp
        componentArray.append(comp)
    }
    
    func removeComponent<T>(_ comp: T) {
        guard let existingComp = componentIndex[String(describing: comp.self)],
            let index = componentArray.firstIndex(where: { $0.typeName == existingComp.typeName })
        else {
            return
        }
        componentArray.remove(at: index)
        componentIndex.removeValue(forKey: String(describing: comp.self))
    }
    
    func component<T>(ofType: T) -> BG2SceneComponent? {
        return componentIndex[String(describing: ofType.self)]
    }
    
    // Recorrer todos los componentes
    func components(_ closure: (_ c: BG2SceneComponent) -> Void ) {
        for comp in componentArray {
            closure(comp)
        }
    }
    
    func everyComponent(_ closure: (_ c: BG2SceneComponent) -> Bool) {
        for comp in componentArray {
            if !closure(comp) {
                break;
            }
        }
    }
    
    func someComponent(_ closure: (_ c: BG2SceneComponent) -> Bool) {
        for comp in componentArray {
            if closure(comp) {
                break;
            }
        }
    }
    
    func components(_ closure: (_ c: BG2SceneComponent, _ index: Int) -> Void ) {
        for (index,comp) in componentArray.enumerated() {
            closure(comp, index)
        }
    }
    
    func everyComponent(_ closure: (_ c: BG2SceneComponent, _ index: Int) -> Bool) {
        for (index,comp) in componentArray.enumerated() {
            if !closure(comp,index) {
                break;
            }
        }
    }
    
    func someComponent(_ closure: (_ c: BG2SceneComponent, _ index: Int) -> Bool) {
        for (index,comp) in componentArray.enumerated() {
            if closure(comp,index) {
                break;
            }
        }
    }
    
    var componentCount: Int {
        get {
            return componentArray.count
        }
    }
}

// Node hierarchy management functions
public extension BG2SceneObject {
    func addChild(_ child: BG2SceneObject) {
        if child.parent != nil {
            child.parent?.removeChild(child)
        }
        children.append(child)
        child.parent = self
    }
    
    func removeChild(_ child: BG2SceneObject) {
        if children.contains(child) {
            children.removeAll(where: { $0 == child })
            child.parent = nil
        }
    }
}

extension BG2SceneObject : Equatable {
    public static func == (lhs: BG2SceneObject, rhs: BG2SceneObject) -> Bool {
        return lhs === rhs
    }
}
