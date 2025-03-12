import SwiftUI
import ARKit
import RoomPlan
import Foundation


@available(iOS 16.0, *)
public struct ARSCNViewContainer: UIViewRepresentable {
    
    public typealias UIViewType = ARSCNView
    
    // Instead of creating ARSCNView, we now receive it
    private let arSCNView: ARSCNView
    private let marsDelegate: ARSCNDelegate
    private let sessionManager: MARSSessionManager
    
    public init(arSCNView: ARSCNView, delegate: ARSCNDelegate) {
        self.arSCNView = arSCNView
        self.marsDelegate = delegate
        
        self.sessionManager = MARSSessionManager(arSCNView: arSCNView, marsDelegate: delegate)
    }
    
    public func makeUIView(context: Context) -> ARSCNView {
        return arSCNView
    }
    
    public func updateUIView(_ uiView: ARSCNView, context: Context) {
    }
    
    public func startARSCNView(with room: Room, for start: Bool, from building: Building) {
        
        sessionManager.activate()
        
        switch start {
        case true:
            print("TRUE CASE")
            sessionManager.addImageTrackingToConfiguration(with: building.detectionImages)
        case false:
            print("FALSE CASE")
            sessionManager.addWorldMapToConfiguration(with: room)
        }
    }
    
    // Provide access to the session manager
    public func getSessionManager() -> MARSSessionManager {
        return sessionManager
    }
}
