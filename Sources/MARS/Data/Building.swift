//
//  Building.swift
//
//
//  Created by Danil Lugli on 03/10/24.
//

import Foundation
import SwiftUI
import ARKit


@available(iOS 16.0, *)
public final class Building: Decodable, ObservableObject, Hashable{
    
    public var id: UUID = UUID()
    public let name: String
    public let floors: [Floor]
    
    @Published public var detectionImages: Set<ARReferenceImage> = []
    
    // MARK: - Initializer
    public init(name: String, floors: [Floor]) {
        self.name = name
        self.floors = floors
    }
    
    public init(){
        self.name = ""
        self.floors = []
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.floors = try container.decode([Floor].self, forKey: .floors)
        
        // detectionImages viene generato a runtime
        self.detectionImages = Set<ARReferenceImage>()
    }
    
    // MARK: - Equatable
    public static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.floors == rhs.floors
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(floors)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, floors
    }
}
