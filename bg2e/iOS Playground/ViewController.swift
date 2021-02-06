//
//  ViewController.swift
//  iOS Playground
//
//  Created by Fernando Serrano Carpena on 6/2/21.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    var renderer: BG2Renderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let metalView = view as? MTKView else {
            fatalError("Please, set the view to be an instance of MTKView")
        }
        
        renderer = BG2Renderer(metalView: metalView)
        renderer?.delegate = RendererDelegate()
    }
}

