//
//  BG2EPolyList.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 30/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import simd

struct Vertex {
    let position: vector_float3
    let normal: vector_float3
    let uv0: vector_float2
    let uv1: vector_float2
}

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
    
    //var vertexDescriptor: MTLVertexDescriptor!
    
    
    // New stuffs
    var vertexData: [Vertex] = []
    
    var mdlMesh: MDLMesh?
    var mesh: MTKMesh?
    
    public init() {
        
    }
    
    public init(vertices: [Float], normals: [Float], tex0: [Float], optTex1: [Float]!, indexes:[UInt32]) {
        self.vertices = vertices
        self.normals = normals
        self.tex0Coords = tex0
        self.tex1Coords = optTex1
        self.indexes = indexes
    }
    
    public func buildMesh(device: MTLDevice) {
        guard let tex0 = tex0Coords,
              let tex1 = (tex1Coords != nil && tex1Coords!.count>0) ? tex1Coords : tex0,
              let vertices = self.vertices,
              let normals = self.normals else {
            return;
        }
        
        var j = 0;
        for i in stride(from: 0, to: vertices.count, by: 3) {
            let pos = vector_float3(vertices[i], vertices[i+1],vertices[i+2])
            let nor = vector_float3(normals[i], normals[i+1],normals[i+2])
            let uv0 = vector_float2(tex0[j], tex0[j+1])
            let uv1 = vector_float2(tex1[j], tex1[j+1])
            vertexData.append(Vertex(position: pos,
                                     normal: nor,
                                     uv0: uv0,
                                     uv1: uv1))
            j += 2
        }
        
        guard let indexes = self.indexes else {
            fatalError("Could no create mesh: no index data specified")
        }
        let allocator = MTKMeshBufferAllocator(device: device)
        let vertexBuffer = allocator.newBuffer(MemoryLayout<Vertex>.size * vertexData.count, type: .vertex)
        let vertexMap = vertexBuffer.map()
        vertexMap.bytes.assumingMemoryBound(to: Vertex.self).assign(from: vertexData, count: vertexData.count)
        
        let indexBuffer = allocator.newBuffer(MemoryLayout<UInt32>.size * indexes.count, type: .index)
        let indexMap = indexBuffer.map()
        indexMap.bytes.assumingMemoryBound(to: UInt32.self).assign(from: indexes, count: indexes.count)
        
        let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                                 indexCount: indexes.count,
                                 indexType: .uInt32,
                                 geometryType: .triangles,
                                 material: nil)
        
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: offset, bufferIndex: 0)
        offset += MemoryLayout<vector_float3>.stride
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,
                                                            format: .float3,
                                                            offset: offset, bufferIndex: 0)
        offset += MemoryLayout<vector_float3>.stride
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: offset, bufferIndex: 0)
        offset += MemoryLayout<vector_float2>.stride
        vertexDescriptor.attributes[3] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate,
                                                            format: .float2,
                                                            offset: offset, bufferIndex: 0)
        offset += MemoryLayout<vector_float2>.stride
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Vertex>.stride)
        
        let mdlMesh = MDLMesh(vertexBuffer: vertexBuffer,
                              vertexCount: vertexData.count,
                              descriptor: vertexDescriptor,
                              submeshes: [submesh])
        self.mdlMesh = mdlMesh
        guard let mesh = self.mdlMesh else {
            fatalError("Could not create PolyList: error creating MDLMesh")
        }
        do {
            self.mesh = try MTKMesh(mesh: mesh, device: device)
        } catch {
            fatalError("Could not create PolyList: error creating MTKMesh")
        }
        
    }
    
    public func buildPolyList(device: MTLDevice) {
        buildMesh(device: device)
        
        /*
        buildTangents()
        
        guard let vertices = vertices, vertices.count % 3 == 0,
              let normals = normals, normals.count % 3 == 0,
              let tex0Coords = tex0Coords, tex0Coords.count % 2 == 0,
              let tex1Coords = (tex1Coords?.count != 0 ? tex1Coords : tex0Coords), tex1Coords.count % 2 == 0,
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
        vertexDescriptor.attributes[0].bufferIndex = Int(PositionAttribIndex.rawValue)
        vertexDescriptor.attributes[0].offset = 0
        // normal
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].bufferIndex = Int(NormalAttribIndex.rawValue)
        vertexDescriptor.attributes[1].offset = 0
        // uv0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = Int(UV0AttribIndex.rawValue)
        vertexDescriptor.attributes[2].offset = 0
        // uv1
        vertexDescriptor.attributes[3].format = .float2
        vertexDescriptor.attributes[3].bufferIndex = Int(UV1AttribIndex.rawValue)
        vertexDescriptor.attributes[3].offset = 0
        // tangent
        vertexDescriptor.attributes[4].format = .float3
        vertexDescriptor.attributes[4].bufferIndex = Int(TangentAttribIndex.rawValue)
        vertexDescriptor.attributes[4].offset = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.stride * 3 // vertices
        vertexDescriptor.layouts[1].stride = MemoryLayout<Float>.stride * 3 // normals
        vertexDescriptor.layouts[2].stride = MemoryLayout<Float>.stride * 2 // uv0
        vertexDescriptor.layouts[3].stride = MemoryLayout<Float>.stride * 2 // uv1
        vertexDescriptor.layouts[4].stride = MemoryLayout<Float>.stride * 3 // tangent
 */
    }
    
    public func draw(encoder: MTLRenderCommandEncoder) {

        guard let mesh = self.mesh,
              let submesh = mesh.submeshes.first else {
            return
        }
        
        encoder.setVertexBuffer(mesh.vertexBuffers[0].buffer,
                                offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: submesh.indexBuffer.buffer,
                                      indexBufferOffset: 0)
        /*
        guard let indexes = indexes
        else {
            print("Warning: invalid buffer data in PolyList")
            return
        }
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: Int(PositionAttribIndex.rawValue))
        encoder.setVertexBuffer(normalBuffer, offset: 0, index: Int(NormalAttribIndex.rawValue))
        encoder.setVertexBuffer(tex0Buffer, offset: 0, index: Int(UV0AttribIndex.rawValue))
        encoder.setVertexBuffer(tex1Buffer, offset: 0, index: Int(UV1AttribIndex.rawValue))
        encoder.setVertexBuffer(tangentBuffer, offset: 0, index: Int(TangentAttribIndex.rawValue))
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexes.count,
                                      indexType: .uint32,
                                      indexBuffer: indexBuffer, indexBufferOffset: 0)
 */
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
        var generatedIndexes: [Int:vector_float3] = [:]
        for i in stride(from: 0, to: indexes.count, by: 3) {
            let v0i = Int(indexes[i] * 3)
            let v1i = Int(indexes[i + 1] * 3)
            let v2i = Int(indexes[i + 2] * 3)
            
            let t0i = Int(indexes[i] * 2)
            let t1i = Int(indexes[i + 1] * 2)
            let t2i = Int(indexes[i + 2] * 2)
            
            let v0 = vector_float3(vertices[v0i], vertices[v0i + 1], vertices[v0i + 2])
            let v1 = vector_float3(vertices[v1i], vertices[v1i + 1], vertices[v1i + 2])
            let v2 = vector_float3(vertices[v2i], vertices[v2i + 1], vertices[v2i + 2])
        
            let t0 = vector_float2(tex0Coords[t0i], tex0Coords[t0i + 1])
            let t1 = vector_float2(tex0Coords[t1i], tex0Coords[t1i + 1])
            let t2 = vector_float2(tex0Coords[t2i], tex0Coords[t2i + 1])
            
            let edge1 = v1 - v0
            let edge2 = v2 - v0
            
            let deltaU1 = t1.x - t0.x
            let deltaV1 = t1.y - t0.y
            let deltaU2 = t2.x - t0.x
            let deltaV2 = t2.y - t0.y
            
            let den = deltaU1 * deltaV2 - deltaU2 * deltaV1
            let tangent: vector_float3
            if den == 0 {
                // Invalid tangent
                tangent = vector_float3(normals[v0i], normals[v0i + 1], normals[v0i + 2])
            } else {
                let f: Float = 1 / den
                tangent = simd_normalize(vector_float3(
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
