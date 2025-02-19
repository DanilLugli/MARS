//
//  Extension.swift
//  MARS
//
//  Created by Danil Lugli on 27/10/24.
//

import Foundation
import ARKit
import CoreMotion
import ComplexModule

// MARK: - ARWorldMap & Codable Wrappers

extension ARWorldMap: Encodable {
    public func encode(to encoder: Encoder) throws {
        //
    }
}

/// Struttura di supporto per la codifica/decodifica di ARWorldMap
struct ARWorldMapCodable: Codable {
    let anchors: [AnchorCodable]
    let center: simd_float3
    let extent: simd_float3
    let rawFeaturesPoints: [simd_float3]
}

/// Rappresentazione codificabile di un ancoraggio
struct AnchorCodable: Codable {
    let x: Float
    let y: Float
    let z: Float
}

// MARK: - Estensioni sulle Matrici

extension matrix_float4x4 {
    /// Inizializza una matrice di trasformazione con una traslazione
    init(translation t: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(t.x, t.y, t.z, 1.0)
    }
    
    /// Inizializza una matrice di trasformazione a partire da un oggetto CMAttitude
    init(rotation attitude: CMAttitude) {
        let rotationMatrix = attitude.rotationMatrix
        self.init(columns: (
            SIMD4<Float>(Float(rotationMatrix.m11), Float(rotationMatrix.m12), Float(rotationMatrix.m13), 0),
            SIMD4<Float>(Float(rotationMatrix.m21), Float(rotationMatrix.m22), Float(rotationMatrix.m23), 0),
            SIMD4<Float>(Float(rotationMatrix.m31), Float(rotationMatrix.m32), Float(rotationMatrix.m33), 0),
            SIMD4<Float>(0, 0, 0, 1)
        ))
    }
}

extension float4x4 {
    /// Crea una matrice di rotazione attorno all'asse Y
    static func rotationAroundY(_ angle: Float) -> float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return float4x4(columns: (
            simd_float4(c,  0, s, 0),
            simd_float4(0,  1, 0, 0),
            simd_float4(-s, 0, c, 0),
            simd_float4(0,  0, 0, 1)
        ))
    }
}

public extension simd_float4x4 {
    /// Converte la matrice in un array di 16 Float
    func toArray() -> [Float] {
        return [
            columns.0.x, columns.0.y, columns.0.z, columns.0.w,
            columns.1.x, columns.1.y, columns.1.z, columns.1.w,
            columns.2.x, columns.2.y, columns.2.z, columns.2.w,
            columns.3.x, columns.3.y, columns.3.z, columns.3.w
        ]
    }

    /// Inizializza una matrice a partire da un array di 16 Float
    init(fromArray array: [Float]) {
        self.init(
            simd_float4(array[0], array[1], array[2], array[3]),
            simd_float4(array[4], array[5], array[6], array[7]),
            simd_float4(array[8], array[9], array[10], array[11]),
            simd_float4(array[12], array[13], array[14], array[15])
        )
    }
    
    /// Restituisce una stringa formattata che rappresenta la matrice
    func formattedString() -> String {
        let rows = [
            String(format: "[%.2f, %.2f, %.2f, %.2f]", columns.0.x, columns.1.x, columns.2.x, columns.3.x),
            String(format: "[%.2f, %.2f, %.2f, %.2f]", columns.0.y, columns.1.y, columns.2.y, columns.3.y),
            String(format: "[%.2f, %.2f, %.2f, %.2f]", columns.0.z, columns.1.z, columns.2.z, columns.3.z),
            String(format: "[%.2f, %.2f, %.2f, %.2f]", columns.0.w, columns.1.w, columns.2.w, columns.3.w)
        ]
        return rows.joined(separator: "\n")
    }
}

// MARK: - Estensioni su SCNVector3

extension SCNVector3 {
    /// Calcola la distanza tra il vettore corrente e un altro vettore
    func distance(to vector: SCNVector3) -> Float {
        return sqrt(
            pow(vector.x - self.x, 2) +
            pow(vector.y - self.y, 2) +
            pow(vector.z - self.z, 2)
        )
    }
    
    /// Calcola la lunghezza (modulo) del vettore
    func length() -> Float {
        return sqrt(x * x + y * y + z * z)
    }
    
    /// Restituisce il vettore normalizzato
    func normalized() -> SCNVector3 {
        let len = self.length()
        return len == 0 ? SCNVector3(0, 0, 0) : SCNVector3(x / len, y / len, z / len)
    }
    
    /// Calcola il prodotto vettoriale (cross product) tra due vettori
    func cross(to vector: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            y * vector.z - z * vector.y,
            z * vector.x - x * vector.z,
            x * vector.y - y * vector.x
        )
    }
    
    /// Calcola il prodotto scalare (dot product) tra due vettori
    func dot(to vector: SCNVector3) -> Float {
        return x * vector.x + y * vector.y + z * vector.z
    }
    
    /// Calcola la differenza tra due vettori
    func difference(_ other: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z
        )
    }
    
    /// Calcola la somma di due vettori
    func sum(_ other: SCNVector3) -> SCNVector3 {
        return SCNVector3(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )
    }
    
    /// Ruota il vettore attorno all'origine di un angolo specificato (in radianti)
    func rotateAroundOrigin(_ angle: Float) -> SCNVector3 {
        // Utilizza numeri complessi per ruotare il vettore sul piano XZ
        var a = Complex<Float>.i
        a.real = cos(angle)
        a.imaginary = sin(angle)
        var b = Complex<Float>.i
        b.real = self.x
        b.imaginary = self.z
        let position = a * b
        return SCNVector3(
            position.real,
            self.y,
            position.imaginary
        )
    }
}

// MARK: - Estensioni su SCNVector4

extension SCNVector4 {
    /// Calcola la rotazione (quaternion in forma vettoriale) necessaria per passare da `fromVector` a `toVector`
    static func rotation(from fromVector: SCNVector3, to toVector: SCNVector3) -> SCNVector4 {
        let cross = fromVector.cross(to: toVector)
        let dot = fromVector.dot(to: toVector)
        let angle = acos(dot / (fromVector.length() * toVector.length()))
        
        // Se l'angolo non è definito o nullo, restituisce una rotazione nulla
        if angle.isNaN || angle == 0 {
            return SCNVector4(0, 1, 0, 0)
        }
        
        return SCNVector4(cross.x, cross.y, cross.z, angle)
    }
}

// MARK: - Estensioni su SCNQuaternion

extension SCNQuaternion {
    /// Calcola la differenza tra due quaternioni
    func difference(_ other: SCNQuaternion) -> SCNQuaternion {
        return SCNQuaternion(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z,
            self.w - other.w
        )
    }
    
    /// Calcola la somma tra due quaternioni
    func sum(_ other: SCNQuaternion) -> SCNQuaternion {
        return SCNQuaternion(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z,
            self.w + other.w
        )
    }
}

// MARK: - Estensioni su Float

extension Float {
    /// Converte un angolo in radianti in gradi
    var radiansToDegrees: Float {
        return self * 180 / .pi
    }
}

// MARK: - Estensioni su SCNNode

extension SCNNode {
    /// Altezza del nodo calcolata dal bounding box
    var height: CGFloat {
        return CGFloat(self.boundingBox.max.y - self.boundingBox.min.y)
    }
    
    /// Larghezza del nodo calcolata dal bounding box
    var width: CGFloat {
        return CGFloat(self.boundingBox.max.x - self.boundingBox.min.x)
    }
    
    /// Lunghezza del nodo calcolata dal bounding box
    var length: CGFloat {
        return CGFloat(self.boundingBox.max.z - self.boundingBox.min.z)
    }
    
    /// Metà altezza in CGFloat
    var halfCGHeight: CGFloat {
        return height / 2.0
    }
    
    /// Metà altezza in Float
    var halfHeight: Float {
        return Float(height / 2.0)
    }
    
    /// Metà altezza scalata in base alla scala del nodo
    var halfScaledHeight: Float {
        return halfHeight * self.scale.y
    }
}
