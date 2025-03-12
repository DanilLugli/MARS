//
//  ARSCNDelegateMultiplexer.swift
//  MARS
//
//  Created on 11/03/25.
//

import Foundation
import ARKit
import SwiftUICore

/// A multiplexer that forwards ARSCNViewDelegate callbacks to multiple delegates
@available(iOS 16.0, *)
public class ARSCNDelegateMultiplexer: NSObject, ARSCNViewDelegate {
    
    // Array of weak references to delegates to avoid retain cycles
    private var delegates: [WeakDelegate] = []
    
    // Private wrapper to hold weak references to delegates
    private class WeakDelegate {
        weak var delegate: ARSCNViewDelegate?
        
        init(_ delegate: ARSCNViewDelegate) {
            self.delegate = delegate
        }
    }
    
    /// Add a delegate to receive AR callbacks
    public func addDelegate(_ delegate: ARSCNViewDelegate) {
        // Check if the delegate already exists to avoid duplicates
        if !delegates.contains(where: { $0.delegate === delegate }) {
            delegates.append(WeakDelegate(delegate))
        }
    }
    
    /// Remove a delegate from receiving AR callbacks
    public func removeDelegate(_ delegate: ARSCNViewDelegate) {
        delegates.removeAll { $0.delegate === delegate }
    }
    
    /// Clean up any nil delegates (whose objects were deallocated)
    private func cleanupDelegates() {
        delegates.removeAll { $0.delegate == nil }
    }
    
    // MARK: - ARSCNViewDelegate Methods
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.renderer?(renderer, didAdd: node, for: anchor)
        }
    }
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.renderer?(renderer, didUpdate: node, for: anchor)
        }
    }
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.renderer?(renderer, didRemove: node, for: anchor)
        }
    }
    
    public nonisolated func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.renderer?(renderer, willUpdate: node, for: anchor)
        }
    }
    
    public nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.session?(session, didFailWithError: error)
        }
    }
    
    public nonisolated func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.session?(session, cameraDidChangeTrackingState: camera)
        }
    }
    
    public nonisolated func sessionWasInterrupted(_ session: ARSession) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.sessionWasInterrupted?(session)
        }
    }
    
    public nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        // Forward to all delegates
        for delegateRef in delegates {
            delegateRef.delegate?.sessionInterruptionEnded?(session)
        }
    }
    
    // Handle other ARSCNViewDelegate methods similarly...
}
