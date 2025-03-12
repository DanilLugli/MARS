//
//  ARSCNDelegate.swift
//  MARS
//
//  Created by Danil Lugli on 16/10/24.
//  Modified on 11/03/25.
//

import Foundation
import ARKit
import SwiftUICore

@available(iOS 16.0, *)
public class ARSCNDelegate: NSObject, LocationSubject, ARSCNViewDelegate {
    
    var positionObservers: [PositionObserver] = []
    private weak var sceneView: ARSCNView?
    private var trackingState: ARCamera.TrackingState?
    private var isFirstPosition = true
    
    public weak var positionProvider: PositionProvider?
    
    public override init(){
        super.init()
    }
    
    public func setSceneView(_ scnV: ARSCNView) {
        sceneView = scnV
    }
    
    // MARK: - ARSCNViewDelegate Methods
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                positionProvider?.findRoomFromMarker(markerName: imageAnchor.referenceImage.name ?? "Error")
            }
        }
    }
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let currentFrame = self.sceneView?.session.currentFrame else {
                return
            }

            let camera = currentFrame.camera
            let trackingState = camera.trackingState
            let newPosition = currentFrame.camera.transform
            
            print("AGGIORNAMENTO POSIZIONE")
            printSimdFloat4x4(newPosition)

            self.notifyLocationUpdate(newLocation: newPosition, newTrackingState: trackingStateToString(trackingState))
        }
    }
    
    public nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("MARS Tracking Change: \(camera.trackingState)")
    }
    
    // MARK: - LocationSubject Methods
    
    public func addLocationObserver(positionObserver: PositionObserver) {
        if !self.positionObservers.contains(where: { $0.id == positionObserver.id}) {
            self.positionObservers.append(positionObserver)
        }
    }
    
    public func removeLocationObserver(positionObserver: PositionObserver) {
        self.positionObservers = self.positionObservers.filter { $0.id != positionObserver.id }
    }
    
    @MainActor
    public func notifyLocationUpdate(newLocation: simd_float4x4, newTrackingState: String) {
        for positionObserver in self.positionObservers {
            positionObserver.onLocationUpdate(newLocation, newTrackingState)
        }
    }
}
