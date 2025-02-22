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
    let coachingOverlay = ARCoachingOverlayView()

    private init() {
        self.arSCNView = ARSCNView(frame: .zero)
        self.configuration = ARWorldTrackingConfiguration()
        setupConfiguration()
        setupCoachingOverlay()
    }

    private func setupConfiguration() {
        configuration.planeDetection = [.horizontal, .vertical]
        arSCNView.autoenablesDefaultLighting = true
        arSCNView.automaticallyUpdatesLighting = true
    }

    private func setupCoachingOverlay() {
        coachingOverlay.session = arSCNView.session
        coachingOverlay.activatesAutomatically = false
        coachingOverlay.goal = .tracking
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false

        arSCNView.addSubview(coachingOverlay)
        arSCNView.bringSubviewToFront(coachingOverlay) 

        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arSCNView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arSCNView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arSCNView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arSCNView.heightAnchor)
        ])
    }

    func configureForImageTracking(with detectionImages: Set<ARReferenceImage>) {
        configuration.detectionImages = detectionImages
        configuration.maximumNumberOfTrackedImages = 1

        if detectionImages.isEmpty {
            print("Nessuna immagine di riferimento trovata.")
        } else {
            print("\(detectionImages.count) immagini caricate per il tracking.")
        }

        coachingOverlay.setActive(true, animated: true)
        
        arSCNView.bringSubviewToFront(coachingOverlay)
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
