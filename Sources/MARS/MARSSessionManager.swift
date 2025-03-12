//
//  MARSSessionManager.swift
//  MARS
//
//  Created on 11/03/25.
//

import SwiftUI
import ARKit
import RoomPlan
import Foundation

@available(iOS 16.0, *)
public class MARSSessionManager {
    
    private var arSCNView: ARSCNView?
    
    private let delegateMultiplexer: ARSCNDelegateMultiplexer
    
    private let marsDelegate: ARSCNDelegate
    
    @MainActor
    public lazy var coachingOverlay: ARCoachingOverlayView = {
        let overlay = ARCoachingOverlayView()
        return overlay
    }()
    
    private var isActive: Bool = false
    
    @MainActor
    public init(arSCNView: ARSCNView, marsDelegate: ARSCNDelegate) {
        self.arSCNView = arSCNView
        self.marsDelegate = marsDelegate
        self.delegateMultiplexer = ARSCNDelegateMultiplexer()
        
        arSCNView.delegate = delegateMultiplexer
        
        delegateMultiplexer.addDelegate(marsDelegate)
        
        setupCoachingOverlay()
        
        marsDelegate.setSceneView(arSCNView)
    }
    
    @MainActor
    func setupCoachingOverlay() {
        guard let arView = arSCNView else { return }
        
        coachingOverlay.session = arView.session
        coachingOverlay.activatesAutomatically = false
        coachingOverlay.goal = .tracking
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false

        arView.addSubview(coachingOverlay)
        arView.bringSubviewToFront(coachingOverlay)

        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
    }

    @MainActor
    /// Adds MARS image detection to the current AR configuration, allowing only one marker at a time.
    public func addImageTrackingToConfiguration(with detectionImages: Set<ARReferenceImage>) {
        guard let arView = arSCNView else {
            return
        }
        guard isActive else {
            return
        }
        
        guard let firstMarker = detectionImages.first else {
            return
        }

        let currentConfig = ARWorldTrackingConfiguration()
        currentConfig.detectionImages = detectionImages
        currentConfig.maximumNumberOfTrackedImages = 1
        
        coachingOverlay.setActive(true, animated: true)
        arView.bringSubviewToFront(coachingOverlay)
        
        arView.session.run(currentConfig, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @MainActor
    public func addWorldMapToConfiguration(
        with room: Room,
        configure: ((ARWorldTrackingConfiguration) -> Void)? = nil
    ) {
        guard let arView = arSCNView, isActive else {
            return
        }

        var currentConfig = arView.session.configuration as? ARWorldTrackingConfiguration
                          ?? ARWorldTrackingConfiguration()

        currentConfig.detectionImages = nil
        currentConfig.initialWorldMap = room.arWorldMap

        // Applica la closure di configurazione se fornita
        configure?(currentConfig)

        arView.session.pause()
        arView.session.run(currentConfig, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /// Activates MARS functionality within the AR session
    public func activate() {
        isActive = true
    }
    
    /// Deactivates MARS functionality, but doesn't affect the AR session
    public func deactivate() {
        isActive = false
    }
}
