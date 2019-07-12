//
//  BG2EPolyList.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 30/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation
import Metal
import simd

public class BG2PolyList {
    public var vertices: [Float]?
    public var normals: [Float]?
    public var tex0Coords: [Float]?
    public var tex1Coords: [Float]?
    public var indexes: [UInt32]?
    
    public var name: String = ""
    public var groupName: String = ""
    
    var tangents: [Float]?
    
    var vertexBuffer: MTLBuffer!
    var normalBuffer: MTLBuffer!
    var tex0Buffer: MTLBuffer!
    var tex1Buffer: MTLBuffer!
    var tangentBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    
    var vertexDescriptor: MTLVertexDescriptor!
    
    public init() {
        
    }
    
    public init(vertices: [Float], normals: [Float], tex0: [Float], tex1: [Float]!, indexes:[UInt32]) {
        self.vertices = vertices
        self.normals = normals
        self.tex0Coords = tex0
        self.tex1Coords = tex1
        self.indexes = indexes
    }
    
    public func buildPolyList(device: MTLDevice) {
        buildTangents()
        
        guard let vertices = vertices, vertices.count % 3 == 0,
              let normals = normals, normals.count % 3 == 0,
              let tex0Coords = tex0Coords, tex0Coords.count % 2 == 0,
              let tex1Coords = (tex1Coords != nil ? tex1Coords : tex0Coords), tex1Coords.count % 2 == 0,
              let tangents = tangents,  // This array is generated in buildTangents and will always be % 3 == 0
              let indexes = indexes
        else {
            fatalError("Invalid vertex data set")
        }
        
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Float>.size * vertices.count,
                                         options: [])
        vertexBuffer.label = "PolyList vertices"
        
        normalBuffer = device.makeBuffer(bytes: normals,
                                         length: MemoryLayout<Float>.size * normals.count,
                                         options: [])
        normalBuffer.label = "PolyList normals"
        
        tex0Buffer = device.makeBuffer(bytes: tex0Coords,
                                         length: MemoryLayout<Float>.size * tex0Coords.count,
                                         options: [])
        tex0Buffer.label = "PolyList tex0 coords"
        
        tex1Buffer = device.makeBuffer(bytes: tex1Coords,
                                       length: MemoryLayout<Float>.size * tex1Coords.count,
                                       options: [])
        tex1Buffer.label = "PolyList tex1 coords"
        
        tangentBuffer = device.makeBuffer(bytes: tangents,
                                       length: MemoryLayout<Float>.size * tangents.count,
                                       options: [])
        tangentBuffer.label = "PolyList tangents"
        
        indexBuffer = device.makeBuffer(bytes: indexes,
                                        length: MemoryLayout<UInt32>.size * indexes.count,
                                        options: [])
        
        // vertex descriptor for non-interleaved buffers
        vertexDescriptor = MTLVertexDescriptor()
        // vertex
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        // normal
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.attributes[1].offset = 0
        // uv0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 2
        vertexDescriptor.attributes[2].offset = 0
        // uv1
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].bufferIndex = 3
        vertexDescriptor.attributes[3].offset = 0
        // tangent
        vertexDescriptor.attributes[4].format = .float3
        vertexDescriptor.attributes[4].bufferIndex = 4
        vertexDescriptor.attributes[4].offset = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 3 // vertices
        vertexDescriptor.layouts[1].stride = MemoryLayout<Float>.stride * 3 // normals
        vertexDescriptor.layouts[2].stride = MemoryLayout<Float>.stride * 2 // uv0
        vertexDescriptor.layouts[3].stride = MemoryLayout<Float>.stride * 2 // uv1
        vertexDescriptor.layouts[4].stride = MemoryLayout<Float>.stride * 3 // tangent
    }
    
    // Returns the next available buffer index to use in the render command encoder
    // This value is 5 because we are using the indexes 0 to 4 to pass the attribute buffers
    // to the shdaer
    public var nextAvailableBufferIndex: Int {
        get {
            return 5
        }
    }
    public func draw(encoder: MTLRenderCommandEncoder) {
        guard let indexes = indexes
        else {
            print("Warning: invalid buffer data in PolyList")
            return
        }
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(normalBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(tex0Buffer, offset: 0, index: 2)
        encoder.setVertexBuffer(tex1Buffer, offset: 0, index: 3)
        encoder.setVertexBuffer(tangentBuffer, offset: 0, index: 4)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexes.count,
                                      indexType: .uint32,
                                      indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
}

extension BG2PolyList {
    func buildTangents() {
        guard let tex0Coords = tex0Coords, tex0Coords.count % 2 == 0,
              let vertices = vertices, vertices.count % 3 == 0,
              let normals = normals, normals.count % 3 == 0,
              let indexes = indexes, indexes.count % 3 == 0
        else {
            fatalError("Unsupported polyList: v2 supports only triangle faces, with normals and at least one UV set")
        }
        
        tangents = []
        var generatedIndexes: [Int:SIMD3<Float>] = [:]
        for i in stride(from: 0, to: indexes.count, by: 3) {
            let v0i = Int(indexes[i] * 3)
            let v1i = Int(indexes[i + 1] * 3)
            let v2i = Int(indexes[i + 2] * 3)
            
            let t0i = Int(indexes[i] * 2)
            let t1i = Int(indexes[i + 1] * 2)
            let t2i = Int(indexes[i + 2] * 2)
            
            let v0 = SIMD3<Float>(vertices[v0i], vertices[v0i + 1], vertices[v0i + 2])
            let v1 = SIMD3<Float>(vertices[v1i], vertices[v1i + 1], vertices[v1i + 2])
            let v2 = SIMD3<Float>(vertices[v2i], vertices[v2i + 1], vertices[v2i + 2])
        
            let t0 = SIMD2<Float>(tex0Coords[t0i], tex0Coords[t0i + 1])
            let t1 = SIMD2<Float>(tex0Coords[t1i], tex0Coords[t1i + 1])
            let t2 = SIMD2<Float>(tex0Coords[t2i], tex0Coords[t2i + 1])
            
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            
            let deltaU1 = t1.x - t0.x
            let deltaV1 = t1.y - t0.y
            let deltaU2 = t2.x - t0.x
            let deltaV2 = t2.y - t0.y
            
            let den = deltaU1 * deltaV2 - deltaU2 * deltaV1
            let tangent: SIMD3<Float>
            if den == 0 {
                // Invalid tangent
                tangent = SIMD3<Float>(normals[v0i], normals[v0i + 1], normals[v0i + 2])
            } else {
                let f: Float = 1 / den
                tangent = simd_normalize(SIMD3<Float>(
                    f * (deltaV2 * edge1.x - deltaV1 * edge2.x),
                    f * (deltaV2 * edge1.y - deltaV1 * edge2.y),
                    f * (deltaV2 * edge1.z - deltaV1 * edge2.z)
                ))
            }
            
            if generatedIndexes[v0i] == nil {
                tangents?.append(tangent.x)
                tangents?.append(tangent.y)
                tangents?.append(tangent.z)
                generatedIndexes[v0i] = tangent
            }
            
            if generatedIndexes[v1i] == nil {
                tangents?.append(tangent.x)
                tangents?.append(tangent.y)
                tangents?.append(tangent.z)
                generatedIndexes[v1i] = tangent
            }
            
            if generatedIndexes[v2i] == nil {
                tangents?.append(tangent.x)
                tangents?.append(tangent.y)
                tangents?.append(tangent.z)
                generatedIndexes[v2i] = tangent
            }
        }
    }
}
