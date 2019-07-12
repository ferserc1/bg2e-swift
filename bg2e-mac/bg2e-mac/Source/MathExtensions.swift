//
//  MathExtensions.swift
//  bg2e-mac
//
//  Created by Fernando Serrano Carpena on 29/06/2019.
//  Copyright © 2019 Fernando Serrano Carpena. All rights reserved.
//

import simd

extension Float {
    public var radiansToDegrees: Float {
        return (self / Float.pi) * 180
    }
    
    public var degreesToRadians: Float {
        return (self / 180) * Float.pi
    }
    
    static func radians(fromDegrees degrees: Float) -> Float {
        return (degrees / 180) * Float.pi
    }
    
    static func degrees(fromRadians radians: Float) -> Float {
        return (radians / Float.pi) * 180
    }
}


extension Double {
    public var radiansToDegrees: Double {
        return (self / Double.pi) * 180
    }
    
    public var degreesToRadians: Double {
        return (self / 180) * Double.pi
    }
    
    static func radians(fromDegrees degrees: Double) -> Double {
        return (degrees / 180) * Double.pi
    }
    
    static func degrees(fromRadians radians: Double) -> Double {
        return (radians / Double.pi) * 180
    }
}

public extension float4x4 {
    init(translate: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3.x = translate.x
        columns.3.y = translate.y
        columns.3.z = translate.z
    }
    
    init(scale: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.0.x = scale.x
        columns.1.y = scale.y
        columns.2.z = scale.z
    }
    
    init(rotationX angle: Float) {
        self = matrix_identity_float4x4
        columns.1.y = cos(angle)
        columns.1.z = sin(angle)
        columns.2.y = -sin(angle)
        columns.2.z = cos(angle)
    }
    
    init(rotationY angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.z = -sin(angle)
        columns.2.x = sin(angle)
        columns.2.z = cos(angle)
    }
    
    init(rotationZ angle: Float) {
        self = matrix_identity_float4x4
        columns.0.x = cos(angle)
        columns.0.y = sin(angle)
        columns.1.x = -sin(angle)
        columns.1.y = cos(angle)
    }
    
    init(rotation angle: SIMD3<Float>) {
        let rotationX = float4x4(rotationX: angle.x)
        let rotationY = float4x4(rotationY: angle.y)
        let rotationZ = float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
    
    func upperLeft() -> float3x3 {
        let x = columns.0.xyz
        let y = columns.1.xyz
        let z = columns.2.xyz
        return float3x3(columns: (x, y, z))
    }
    
    init(perspectiveFov fov: Float, near: Float, far: Float, aspect: Float, lhs: Bool = true) {
        let y = 1 / tan(fov * 0.5)
        let x = y / aspect
        let z = lhs ? far / (far - near) : far / (near - far)
        let X = SIMD4<Float>( x,  0,  0,  0)
        let Y = SIMD4<Float>( 0,  y,  0,  0)
        let Z = lhs ? SIMD4<Float>( 0,  0,  z, 1) : SIMD4<Float>( 0,  0,  z, -1)
        let W = lhs ? SIMD4<Float>( 0,  0,  z * -near,  0) : SIMD4<Float>( 0,  0,  z * near,  0)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    // left-handed LookAt
    init(lookAtFrom eye: SIMD3<Float>, center: SIMD3<Float>, up: SIMD3<Float>) {
        let z = normalize(eye - center)
        let x = normalize(cross(up, z))
        let y = cross(z, x)
        let w = SIMD3<Float>(dot(x, -eye), dot(y, -eye), dot(z, -eye))
        
        let X = SIMD4<Float>(x.x, y.x, z.x, 0)
        let Y = SIMD4<Float>(x.y, y.y, z.y, 0)
        let Z = SIMD4<Float>(x.z, y.z, z.z, 0)
        let W = SIMD4<Float>(w.x, w.y, x.z, 1)
        self.init()
        columns = (X, Y, Z, W)
    }
    
    init(orthoLeft left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) {
        let X = SIMD4<Float>(2 / (right - left), 0, 0, 0)
        let Y = SIMD4<Float>(0, 2 / (top - bottom), 0, 0)
        let Z = SIMD4<Float>(0, 0, 1 / (far - near), 0)
        let W = SIMD4<Float>((left + right) / (left - right),
                       (top + bottom) / (bottom - top),
                       near / (near - far),
                       1)
        self.init()
        columns = (X, Y, Z, W)
    }
}

public extension float3x3 {
    init(normalFrom4x4 matrix: float4x4) {
        self.init()
        columns = matrix.upperLeft().inverse.transpose.columns
    }
}

public extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        get {
            return SIMD3<Scalar>(x,y,z)
        }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}
