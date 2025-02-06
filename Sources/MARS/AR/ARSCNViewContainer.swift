//
//  File.swift
//  MARS
//
//  Created by Danil Lugli on 16/10/24.
//

//
//import SwiftUI
//import ARKit
//import RoomPlan
//import Foundation
//
//@available(iOS 16.0, *)
//
//struct ARSCNViewContainer: UIViewRepresentable {
//    
//    typealias UIViewType = ARSCNView
//    
//    var roomActive: String = ""
//    private let arSCNView = ARSCNView(frame: .zero)
//    private let configuration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
//    private let delegate: ARSCNDelegate
//    
//    init(delegate: ARSCNDelegate) {
//        self.delegate = delegate
//        setupConfiguration()
//    }
//    
//    private func setupConfiguration() {
//        configuration.planeDetection = [.horizontal, .vertical]
//    }
//    
//    func makeUIView(context: Context) -> ARSCNView {
//        arSCNView.delegate = delegate
//        delegate.setSceneView(arSCNView)
//        configureSceneView()
//        return arSCNView
//    }
//    
//    func updateUIView(_ uiView: ARSCNView, context: Context) {}
//
//    
//    private func configureSceneView() {
//        arSCNView.autoenablesDefaultLighting = true
//        arSCNView.automaticallyUpdatesLighting = true
//    }
//    
//    mutating func startARSCNView(with room: Room, for start: Bool, from building: Building) -> Room {
//        switch start {
//        case true:
//            
//            configuration.maximumNumberOfTrackedImages = 1
//            arSCNView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
//            
//            configuration.isAutoFocusEnabled = true
//            
//            configuration.detectionImages = building.detectionImages
//            
//            if building.detectionImages.isEmpty {
//                print("WARNING: Nessuna immagine di riferimento trovata! Controlla il caricamento.")
//            } else {
//                print("DEBUG: \(configuration.detectionImages?.count ?? 0) immagini di riferimento caricate in ARKit.")
//                
//                for image in building.detectionImages {
//                    print("DEBUG: Immagine caricata - Nome: \(image.name ?? "No Name"), Larghezza: \(image.physicalSize) metri")
//                }
//                
//                print("DEBUG CHECK: \(building.detectionImages.count) immagini di riferimento caricate correttamente.")
//                
//                self.arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//            }
//            
//            return room
//            
//        case false:
//            
//            self.roomActive = room.name
//            configuration.detectionImages = nil
//
//            configuration.initialWorldMap = room.arWorldMap
//            arSCNView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
//            self.arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//
//        }
//        return room
//    }
//}

import SwiftUI
import ARKit
import RoomPlan
import Foundation

@available(iOS 16.0, *)
struct ARSCNViewContainer: UIViewRepresentable {
    
    typealias UIViewType = ARSCNView
    private let arSCNView = ARSessionManager.shared.arSCNView
    private let delegate: ARSCNDelegate

    init(delegate: ARSCNDelegate) {
        self.delegate = delegate
    }

    func makeUIView(context: Context) -> ARSCNView {
        arSCNView.delegate = delegate
        delegate.setSceneView(arSCNView)
        return arSCNView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func startARSCNView(with room: Room, for start: Bool, from building: Building) {
        let session = ARSessionManager.shared

        switch start {
        case true:
            session.configureForImageTracking(with: building.detectionImages)
        case false:
            session.configureForWorldMap(with: room)
        }
    }
}

@MainActor
@available(iOS 16.0, *)
class ARSessionManager {
    @MainActor static let shared = ARSessionManager()
    
    let arSCNView: ARSCNView
    private let configuration: ARWorldTrackingConfiguration


    private init() {
        self.arSCNView = ARSCNView(frame: .zero)
        self.configuration = ARWorldTrackingConfiguration()
        setupConfiguration()
    }

  private func setupConfiguration() {
        configuration.planeDetection = [.horizontal, .vertical]
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
    }

     func configureForImageTracking(with detectionImages: Set<ARReferenceImage>) {
        configuration.detectionImages = detectionImages
        configuration.maximumNumberOfTrackedImages = 1

        if detectionImages.isEmpty {
            print(" Nessuna immagine di riferimento trovata.")
        } else {
            print("\(detectionImages.count) immagini caricate per il tracking.")
        }

        restartSession(with: [.resetTracking, .removeExistingAnchors])
    }

     func configureForWorldMap(with room: Room) {
        configuration.detectionImages = nil
        configuration.initialWorldMap = room.arWorldMap

        arSCNView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        restartSession(with: [.resetTracking, .removeExistingAnchors])
    }

     func restartSession(with options: ARSession.RunOptions) {
        arSCNView.session.pause()
        arSCNView.session.run(configuration, options: options)
    }
}
