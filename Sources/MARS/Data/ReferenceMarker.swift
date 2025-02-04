//
//  ReferenceMarker.swift
//  
//
//  Created by Danil Lugli on 03/10/24.
//
import SwiftUI
import Foundation
import ARKit

public class ReferenceMarker: ObservableObject, Identifiable, Decodable {
    public var id: UUID
    public var arReferenceImage: ARReferenceImage?
    public var width: CGFloat
    public var roomName: String = ""
    public var name: String
    
    public init(id: UUID = UUID(), image: ARReferenceImage? = nil, width: CGFloat, name: String) {
        self.id = id
        self.arReferenceImage = image
        self.width = width
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case width
        case name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID()
        self.width = try container.decode(CGFloat.self, forKey: .width)
        self.name = try container.decode(String.self, forKey: .name)
        self.arReferenceImage = nil
    }

    public func loadARReferenceImage(from imageSource: UIImage) {
        var cgImage: CGImage? = imageSource.cgImage

        if cgImage == nil, let ciImage = imageSource.ciImage {
            let context = CIContext()
            cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        }

        guard let finalCGImage = cgImage else {
            print("DEBUG: Impossibile ottenere cgImage per '\(self.name)'")
            return
        }

        let meterWidth = self.width / 100.0

        self.arReferenceImage = ARReferenceImage(finalCGImage, orientation: .up, physicalWidth: meterWidth)

        if let image = self.arReferenceImage {
            image.name = self.name
            print("DEBUG: ARReferenceImage creata correttamente per '\(self.name)' con larghezza: \(image.physicalSize.width) metri")
        } else {
            print("DEBUG: Creazione ARReferenceImage fallita per '\(self.name)'")
        }
    }
    
    struct MarkerData: Codable {
        var name: String
        var width: CGFloat
    }
}

