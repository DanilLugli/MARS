//
//  RotoTraslationMatrix.swift
//  
//
//  Created by Danil Lugli on 03/10/24.
//

import Foundation
import simd

public struct RotoTraslationMatrix: Codable {
    public let name: String
    public var translation: simd_float4x4
    public var r_Y: simd_float4x4
    
    public init(name: String, translation: simd_float4x4, r_Y: simd_float4x4) {
        self.name = name
        self.translation = translation
        self.r_Y = r_Y
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case translation
        case r_Y
    }

    // Custom encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(translation.toArray(), forKey: .translation)
        try container.encode(r_Y.toArray(), forKey: .r_Y)
    }

    // Custom decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        let translationArray = try container.decode([Float].self, forKey: .translation)
        let r_YArray = try container.decode([Float].self, forKey: .r_Y)
        
        self.translation = simd_float4x4(fromArray: translationArray)
        self.r_Y = simd_float4x4(fromArray: r_YArray)
    }
}

// Helper extensions to handle simd_float4x4 conversion to and from an array
