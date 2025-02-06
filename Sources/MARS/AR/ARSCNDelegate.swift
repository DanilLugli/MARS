//
//  File.swift
//  MARS
//
//  Created by Danil Lugli on 16/10/24.
//

import Foundation
import ARKit
import SwiftUICore

@available(iOS 16.0, *)
class ARSCNDelegate: NSObject, LocationSubject, ARSCNViewDelegate {
    
    var positionObservers: [PositionObserver] = []
    private var sceneView: ARSCNView?
    private var trackingState: ARCamera.TrackingState?
    private var isFirstPosition = true
    
    weak var positionProvider: PositionProvider?
    
    override init(){
        super.init()
    }
    
    func setSceneView(_ scnV: ARSCNView) {
        sceneView = scnV
    }
    
    nonisolated func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                positionProvider?.findRoomFromMarker(markerName: imageAnchor.referenceImage.name ?? "Error")
            }
        }
    }
    
    nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    
        DispatchQueue.main.async {
            guard let currentFrame = self.sceneView?.session.currentFrame else {
                print("Frame non disponibile")
                return
            }
            
            let camera = currentFrame.camera
            
            let trackingState = camera.trackingState
            let newPosition = currentFrame.camera.transform
            self.notifyLocationUpdate(newLocation: newPosition, newTrackingState: trackingStateToString(trackingState))
        }
    }
    
    nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("🔄 Stato Tracking: \(camera.trackingState)")
    }
    
    func addLocationObserver(positionObserver: PositionObserver) {

        if !self.positionObservers.contains(where: { $0.id == positionObserver.id}) {
            self.positionObservers.append(positionObserver)
        }
    }
    
    func removeLocationObserver(positionObserver: PositionObserver) {
        self.positionObservers = self.positionObservers.filter { $0.id != positionObserver.id }
    }
    
    func notifyLocationUpdate(newLocation: simd_float4x4, newTrackingState: String) {
        
        for positionObserver in self.positionObservers {
            positionObserver.onLocationUpdate(newLocation, newTrackingState)
        }
    }
}
