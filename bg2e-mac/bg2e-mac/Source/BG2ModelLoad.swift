//
//  BG2EModelLoad.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 01/07/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import Foundation

public class BG2ModelLoad {
    public struct Header {
        var endian: UInt8
        var majorVersion: UInt8
        var minorVersion: UInt8
        var revision: UInt8
    }
    public var header: Header = Header(endian: 0, majorVersion: 0, minorVersion: 0, revision: 0)
    public var numberOfPolyList: UInt32 = 0
    
    let currentEndian: UInt8
    var materials: [String:NSDictionary] = [:]
    var filePath: URL! = nil
    var fileContentFolder: URL! = nil

    
    public var drawableItems: [BG2DrawableItem] = []
    
    var renderer: BG2Renderer
    
    public init(renderer: BG2Renderer) {
        self.renderer = renderer
        let number: UInt32 = 0x12345678
        let converted = number.bigEndian
        if number == converted {
            currentEndian = 0
        }
        else {
            currentEndian = 1
        }
    }
}

public extension BG2ModelLoad {
    convenience init(contentsOfFile: URL, renderer: BG2Renderer) {
        self.init(renderer: renderer)
        guard let data = NSData(contentsOf: contentsOfFile) else {
            fatalError("Could not load data for resource \(contentsOfFile)")
        }
        
        self.filePath = contentsOfFile.absoluteURL
        self.fileContentFolder = contentsOfFile.absoluteURL.deletingLastPathComponent()
        
        var bufferOffset = 0
        // Header
        data.getBytes(&header, range: NSRange(location: bufferOffset, length: 4))
        bufferOffset += 4
        
        print("bg2 model version: \(header.majorVersion).\(header.minorVersion).\(header.revision)")
        
        var block = readBlock(data: data, offset: bufferOffset)
        bufferOffset += block.count
        
        if block != "hedr" {
            fatalError("Malformed data in bg2 model file. Expecting: `hedr`")
        }
        
        numberOfPolyList = readUInt32(data: data, offset: bufferOffset)
        bufferOffset += 4
        
        block = readBlock(data: data, offset: bufferOffset)
        bufferOffset += 4
        
        if block != "mtrl" {
            fatalError("Malformed data in bg2 model file. Expecting `mtlr`")
        }
        
        let materials = readString(data: data, offset: bufferOffset)
        bufferOffset += materials.count + 4 // string lengt + 4 bytes for the string size
        
        do {
            let textData = materials.data(using: .utf8)!
            let jsonData = try JSONSerialization.jsonObject(with: textData, options: []) as? NSArray
            parseMaterials(jsonData)
        } catch let parsingError {
            fatalError("Malformed data in bg2 model file. Parse error in materials section: \(parsingError) ")
        }
        
        block = readBlock(data: data, offset: bufferOffset)
        bufferOffset += 4
        let joints = readString(data: data, offset: bufferOffset)
        bufferOffset += joints.count + 4 // string length + 4 bytes for string size
        // TODO: parse joints
        
        print("Reading \(numberOfPolyList) polyList")
        var done = false
        var vArray: [Float]?
        var nArray: [Float]?
        var t0Array: [Float]?
        var t1Array: [Float]?
        var t2Array: [Float]?
        var iArray: [UInt32]?
        var name: String = ""
        var matName: String = ""
        while !done {
            block = readBlock(data: data, offset: bufferOffset)
            bufferOffset += 4
            var strData: String = ""
            switch block {
            case "pnam":
                strData = readString(data: data, offset: bufferOffset)
                bufferOffset += strData.count + 4
                name = strData
            case "mnam":
                strData = readString(data: data, offset: bufferOffset)
                bufferOffset += strData.count + 4
                matName = strData
            case "varr":
                vArray = readFloatArray(data: data, offset: bufferOffset)
                bufferOffset += vArray!.count * 4 + 4
            case "narr":
                nArray = readFloatArray(data: data, offset: bufferOffset)
                bufferOffset += nArray!.count * 4 + 4
            case "t0ar":
                t0Array = readFloatArray(data: data, offset: bufferOffset)
                bufferOffset += t0Array!.count * 4 + 4
            case "t1ar":
                t1Array = readFloatArray(data: data, offset: bufferOffset)
                bufferOffset += t1Array!.count * 4 + 4
            case "t2ar":
                t2Array = readFloatArray(data: data, offset: bufferOffset)
                bufferOffset += t2Array!.count * 4 + 4
            case "indx":
                iArray = readUIntArray(data: data, offset: bufferOffset)
                bufferOffset += iArray!.count * 4 + 4
            case "plst", "endf":
                if block == "endf" && (bufferOffset + 4) < data.count {
                    block = readBlock(data: data, offset: bufferOffset)
                    bufferOffset += 4
                    if block == "cmps" {
                        // Read components
                        let componentData = readString(data: data, offset: bufferOffset)
                        bufferOffset += componentData.count + 4
                        parseComponents(withString: componentData)
                    }
                    done = true
                }
                else if (bufferOffset + 4) >= data.count {
                    done = true
                }
                
                if vArray != nil, nArray != nil, t0Array != nil, iArray != nil {
                    let plist = BG2PolyList()
                    plist.name = name
                    plist.vertices = vArray
                    plist.normals = nArray
                    plist.tex0Coords = t0Array
                    plist.tex1Coords = t1Array
                    plist.indexes = iArray
                    plist.buildPolyList(device: renderer.device)
                    
                    // Extract groupName from material data
                    if let materialDictionary = self.materials[matName],
                        let grpName = materialDictionary.value(forKey: "groupName") as? String {
                        plist.groupName = grpName
                        let material = getMaterialWithName(matName, fromDictionary: materialDictionary)
                        drawableItems.append(BG2DrawableItem(polyList: plist, material: material, renderer: renderer))
                    }
                    else {
                        drawableItems.append(BG2DrawableItem(polyList: plist, renderer: renderer))
                    }

                    vArray = nil
                    nArray = nil
                    t0Array = nil
                    t1Array = nil
                    t2Array = nil
                    iArray = nil
                }
                
            default:
                fatalError("Malformed data in bg2 model. Unexpected polyList block: \(block)")
            }
        }
        
    }
    
    func readBlock(data: NSData, offset: Int) -> String {
        var block: [UInt8] = [UInt8](repeating: 0, count: 4)
        data.getBytes(&block, range: NSRange(location: offset, length: 4))
        guard let result = String(bytes: block, encoding: .ascii) else {
            return "    "
        }
        return result
    }
    
    func readUInt32(data: NSData, offset: Int) -> UInt32 {
        var bufferValue: UInt32 = 0
        data.getBytes(&bufferValue, range: NSRange(location: offset, length: 4))
        if header.endian != currentEndian {
            bufferValue = CFSwapInt32(bufferValue)
        }
        return bufferValue
    }
    
    func readString(data: NSData, offset: Int) -> String {
        let dataLength = readUInt32(data: data, offset: offset)
        var bufferValue: [UInt8] = [UInt8](repeating: 0, count: Int(dataLength))
        data.getBytes(&bufferValue, range: NSRange(location: offset + 4, length: Int(dataLength)))
        guard let result = String(bytes: bufferValue, encoding: .ascii) else {
            return "";
        }
        return result
    }
    
    func readFloatArray(data: NSData, offset: Int) -> [Float] {
        let dataLength = readUInt32(data: data, offset: offset)
        var result: [Float]
        if header.endian != currentEndian {
            var temp = [UInt32](repeating: 0, count: Int(dataLength))
            data.getBytes(&temp, range: NSRange(location: offset + 4, length: Int(dataLength * 4)))
            result = temp.map { v in
                Float(bitPattern: CFSwapInt32(v))
            }
        }
        else {
            result = [Float](repeating: 0, count: Int(dataLength))
            data.getBytes(&result, range: NSRange(location: offset + 4, length: Int(dataLength * 4)))
        }
        return result
    }
    
    func readIntArray(data: NSData, offset: Int) -> [Int32] {
        let dataLength = readUInt32(data: data, offset: offset)
        var result: [Int32] = [Int32](repeating: 0, count: Int(dataLength))
        data.getBytes(&result, range: NSRange(location: offset + 4, length: Int(dataLength * 4)))
        if header.endian != currentEndian {
            result = result.map { Int32(bigEndian: $0) }
        }
        return result
    }
    
    func readUIntArray(data: NSData, offset: Int) -> [UInt32] {
        let dataLength = readUInt32(data: data, offset: offset)
        var result: [UInt32] = [UInt32](repeating: 0, count: Int(dataLength))
        data.getBytes(&result, range: NSRange(location: offset + 4, length: Int(dataLength * 4)))
        if header.endian != currentEndian {
            result = result.map { UInt32(bigEndian: $0) }
        }
        return result
    }
    
    func parseMaterials(_ matDict: NSArray?) {
        guard let matDict = matDict else {
            return
        }
        for matItem in matDict {
            guard let matItem = matItem as? NSDictionary else {
                continue
            }
            parseMaterial(matItem)
        }
    }
    
    func parseMaterial(_ dict: NSDictionary?) {
        guard let matName = dict?.value(forKey: "name") as? String else {
            return
        }
        materials[matName] = dict
    }
    
    func parseComponents(withString: String) {
        // Prevent a bug in C++ API version 2.0, that inserts a comma after
        // the last elemento of some array objects
        // TODO: fix bug using the following regular expressions and parse components
        //      data.replace(/,[\s\r\n]*\]/g,']')
        //      data.replace(/,[\s\r\n]*\}/g,'}')
        // TODO: Parse json component data
        print(withString)
    }
    
    func getMaterialWithName(_ name: String, fromDictionary dict: NSDictionary?) -> BG2Material {
        let result = BG2Material()
        
        if dict?.value(forKey: "class") as? String == "PBRMaterial" {
            
            /*
             name string
             groupName string
             
             diffuse texture o color
             diffuseUV int
             diffuseScale vec2
             alphaCutoff float
             isTransparent bool
             
             ambientOcclussion texture
             ambientOcclussionUV int
             
             metallic texture o float
             metallicScale vec2
             metallicChannel int
             metallicUV int
        
             roughness texture o float
             roughnessScale vec2
             roughnessChannel int
             roughnessUV int
             
             fresnel color
             
             normal texture
             normalScale vec2
             normalUV int
     
             castShadows bool
             unlit bool
             visibleToShadows bool
             cullFace true
             visible bool
             */
            
            if let albedo = dict?.value(forKey: "diffuse") as? SIMD4<Float> {
                result.albedo = albedo
            }
            else if let albedoTexture = dict?.value(forKey: "diffuse") as? String {
                let albedoUrl: URL = self.fileContentFolder.appendingPathComponent(albedoTexture)
                do {
                    try result.setAlbedoTexture(withPath: albedoUrl, renderer: renderer)
                } catch {
                    print("Warning: albedo texture not found at \(albedoUrl)")
                }
            }
            if let albedoUV = dict?.value(forKey: "diffuseUV") as? Int {
                result.albedoUV = albedoUV
            }
            if let albedoScale = dict?.value(forKey: "diffuseScale") as? SIMD2<Float> {
                result.albedoScale = albedoScale
            }
            
            // TODO: Implement pbr material load
            
            
            if let normal = dict?.value(forKey: "normalMap") as? String {
                let normalUrl: URL = self.fileContentFolder.appendingPathComponent(normal)
                do {
                    try result.setNormalTexture(withPath: normalUrl, renderer: renderer)
                } catch {
                    print("Warning: normal texture not found at \(normalUrl)")
                }
            }
            if let ao = dict?.value(forKey: "lightmap") as? String {
                let aoUrl: URL = self.fileContentFolder.appendingPathComponent(ao)
                do {
                    try result.setAmbientOcclussionTexture(withPath: aoUrl, renderer: renderer)
                } catch {
                    print("Warning: ambient occlussion texture not found at\(aoUrl)")
                }
            }
            if let roughness = dict?.value(forKey: "reflectionAmount") as? String {
                let roughnessUrl: URL = self.fileContentFolder.appendingPathComponent(roughness)
                do {
                    try result.setRoughnessTexture(withPath: roughnessUrl, renderer: renderer)
                } catch {
                    print("Warning: roughness texture not found at \(roughness)")
                }
            }
            // Metalicity: is imported from shininess and sininess mask
            if let sh = dict?.value(forKey: "shininess") as? Float {
                result.metallic = sh == 0.0 ? 255.0 : sh
            }
            if let metallic = dict?.value(forKey: "shininessMask") as? String {
                let metallicUrl: URL = self.fileContentFolder.appendingPathComponent(metallic)
                do {
                    try result.setMetallicTexture(withPath: metallicUrl, renderer: renderer)
                } catch {
                    print("Warning: metallic texture not found at \(metallicUrl)")
                }
            }
            
            
            
            // TODO:
            //  alphaCutoff
            //  lightEmission
            //  lightEmissionMaskChannel
            //  normalMapScaleX
            //  normalMapScaleY
            //  normalMapOffsetX
            //  normalMapOffsetY
            //  cullFace
            //  castShadows
            //  receiveShadows
            //  visible
            //  textureOffsetX
            //  textureOffsetY
            //  textureScaleX
            //  textureScaleY
            
        }
        else {
            print("Warning: non-pbr materials are not compatible with bg2e Swift API")
        }

        
        return result
    }
}
