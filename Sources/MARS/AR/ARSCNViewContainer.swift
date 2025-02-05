//
//  File.swift
//  MARS
//
//  Created by Danil Lugli on 16/10/24.
//


import SwiftUI
import ARKit
import RoomPlan
import Foundation

@available(iOS 16.0, *)

struct ARSCNViewContainer: UIViewRepresentable {
    
    typealias UIViewType = ARSCNView
    
    var roomActive: String = ""
    private let arSCNView = ARSCNView(frame: .zero)
    private let configuration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
    private let delegate: ARSCNDelegate
    
    init(delegate: ARSCNDelegate) {
        self.delegate = delegate
        setupConfiguration()
    }
    
    private func setupConfiguration() {
        configuration.planeDetection = [.horizontal, .vertical]
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        arSCNView.delegate = delegate
        delegate.setSceneView(arSCNView)
        configureSceneView()
        return arSCNView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    
    private func configureSceneView() {
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
    }
    
    mutating func startARSCNView(with room: Room, for start: Bool, from building: Building) -> Room {
        switch start {
        case true:
            
            configuration.maximumNumberOfTrackedImages = 1
            arSCNView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
            
            configuration.isAutoFocusEnabled = true
            
            configuration.detectionImages = building.detectionImages
            
            if building.detectionImages.isEmpty {
                print("WARNING: Nessuna immagine di riferimento trovata! Controlla il caricamento.")
            } else {
                print("DEBUG: \(configuration.detectionImages?.count ?? 0) immagini di riferimento caricate in ARKit.")
                
                for image in building.detectionImages {
                    print("DEBUG: Immagine caricata - Nome: \(image.name ?? "No Name"), Larghezza: \(image.physicalSize) metri")
                }
                
                print("DEBUG CHECK: \(building.detectionImages.count) immagini di riferimento caricate correttamente.")
                
                self.arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            }
            
            return room
            
        case false:
            
            self.roomActive = room.name
            configuration.detectionImages = nil

            configuration.initialWorldMap = room.arWorldMap
            arSCNView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
            self.arSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        }
        return room
    }
}
