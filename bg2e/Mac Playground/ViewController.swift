//
//  ViewController.swift
//  Mac Playground
//
//  Created by Fernando Serrano Carpena on 6/2/21.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
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
