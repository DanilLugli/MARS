//
//  File.swift
//  MARS
//
//  Created by Danil Lugli on 07/10/24.
//

import SwiftUI
import SceneKit
import ARKit
import RoomPlan
import CoreMotion
import ComplexModule


@available(iOS 16.0, *)
@MainActor
public struct SCNViewContainer: UIViewRepresentable {
    
    public typealias UIViewType = SCNView
    
    var scnView = SCNView(frame: .zero)
    var handler = HandleTap()
    
    var cameraNode = SCNNode()
    var massCenter = SCNNode()
    var delegate = RenderDelegate()
    var dimension = SCNVector3()
    
    var rotoTraslation: [RotoTraslationMatrix] = []
    var origin = SCNNode()
    @State var rotoTraslationActive: Int = 0
    
    init() {}
    
    @MainActor
    func loadPlanimetry(scene: Any, roomsNode: [String]?, borders: Bool, nameCaller: String) {
        
        if let roomScene = scene as? Room {
            loadScene(from: roomScene.roomURL, name: roomScene.name, type: "Room")
            addLocationNode(scnView: self.scnView)
            setCamera(scnView: self.scnView, cameraNode: self.cameraNode, massCenter: self.massCenter)
            
        } else if let floorScene = scene as? Floor {
            loadScene(from: floorScene.floorURL, name: floorScene.name, type: "Floor")
            MARS.addFloorLocationNode(scnView: self.scnView)
            setCamera(scnView: self.scnView, cameraNode: self.cameraNode, massCenter: self.massCenter)
            
//            setCameraFollowPosition(scnView: self.scnView, cameraNode: cameraNode)
//            Task { await setCameraFollowPosition(scnView: self.scnView, cameraNode: cameraNode) }
            
        } else {
            print("The provided scene is neither a Room nor a Floor.")
        }
        //addOriginMarker(to: self.scnView.scene!)
        
        drawSceneObjects(borders: true)
        
        setMassCenter()
        
        if let rootNode = self.scnView.scene?.rootNode {
            for child in rootNode.childNodes {
                if child.name?.prefix(3) != "POS"{
                    //child.scale = SCNVector3(2.0, 2.0, 2.0)
                }
                
            }
        }
        
        // createAxesNode()
    }
    
    func loadScene(from baseURL: URL, name: String, type: String) {
        let fileURL = baseURL.appendingPathComponent("MapUsdz").appendingPathComponent("\(name).usdz")
        do {
            scnView.scene = nil
            scnView.scene = try SCNScene(url: fileURL)
        } catch {
            print("Failed to load SCNScene for \(type): \(error.localizedDescription)")
        }
    }
    
    func addOriginMarker(to scene: SCNScene) {
        let originNode = SCNNode()
        originNode.geometry = SCNSphere(radius: 0.2)
        originNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemPink
        originNode.position = SCNVector3(0, 0, 0)
        
        scene.rootNode.addChildNode(originNode)
    }
    
    func addLastPositionMarker() -> SCNNode {
        let originNode = SCNNode()
        originNode.geometry = SCNSphere(radius: 0.2)
        originNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        originNode.position = SCNVector3(0, 0, 0)
        originNode.name = "Originini"
        
        return originNode
    }
    
    func drawSceneObjects(borders: Bool) {
        var drawnNodes = Set<String>()
        
        let nodeMaterials: [String: UIColor] = [
            "Floor0": .green,
            "Floor": .white.withAlphaComponent(0),
            "Transi": .white,
            "Door": .white,
            "Open": .white,
            "Tabl": .brown,
            "Chai": .brown.withAlphaComponent(0.4),
            "Stor": .systemGray,
            "Sofa": UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.6),
            "Tele": .orange
            //            "Floor_Way": .blue,
            //            "Floor_Bed Marco": .orange
        ]
        
        scnView.scene?
            .rootNode
            .childNodes(passingTest: { node, _ in
                guard let nodeName = node.name else { return false }
                return nodeName != "Room" &&
                nodeName != "Floor0" &&
                nodeName != "Geom" &&
                !nodeName.hasSuffix("_grp") &&
                nodeName != "__selected__"
            })
            .forEach { node in
                guard let nodeName = node.name else { return }
                
                let material = SCNMaterial()
                material.diffuse.contents = nodeMaterials.first { nodeName.hasPrefix($0.key) }?.value ?? UIColor.black
                material.lightingModel = .physicallyBased
                
                if nodeName.hasPrefix("Wall") {
                    node.scale = SCNVector3(node.scale.x,
                                            node.scale.y,
                                            node.scale.z * 0.7)
                }
                
                if nodeName.hasPrefix("Door") || nodeName.hasPrefix("Open") {
                    // Rialza di 2 metri
                    node.position.y += 2.0
                    
                    // Ingrandisci di un fattore 1.5 in tutte le dimensioni
                    node.scale = SCNVector3(node.scale.x,
                                            node.scale.y,
                                            node.scale.z * 3)
                }
                
                node.geometry?.materials = [material]
                drawnNodes.insert(nodeName)
            }
    }
    
    func setMassCenter() {
        let massCenter = SCNNode()
        massCenter.worldPosition = SCNVector3(0, 0, 0)
        
        if let nodes = scnView.scene?.rootNode.childNodes(passingTest: { n, _ in
            n.name != nil && n.name! != "Room" && n.name! != "Geom" && String(n.name!.suffix(4)) != "_grp"
        }) {
            let calculatedMassCenter = findMassCenter(nodes)
            massCenter.worldPosition = calculatedMassCenter.worldPosition
            // drawCross(at: massCenter)
        }
        
        scnView.scene?.rootNode.addChildNode(massCenter)
    }
    
    func findMassCenter(_ nodes: [SCNNode]) -> SCNNode {
        let massCenter = SCNNode()
        
        // Variabili per calcolare la media delle posizioni dei nodi
        var totalX: Float = 0.0
        var totalY: Float = 0.0
        var totalZ: Float = 0.0
        var nodeCount: Float = 0.0
        
        // Itera su tutti i nodi per calcolare la somma delle posizioni
        for node in nodes {
            totalX += node.worldPosition.x
            totalY += node.worldPosition.y
            totalZ += node.worldPosition.z
            nodeCount += 1.0
        }
        
        // Evita la divisione per zero nel caso non ci siano nodi
        guard nodeCount > 0 else {
            massCenter.worldPosition = SCNVector3(0, 0, 0)
            return massCenter
        }
        
        // Calcola la posizione media (centro geometrico)
        let averageX = totalX / nodeCount
        let averageY = totalY / nodeCount
        let averageZ = totalZ / nodeCount
        
        // Imposta la posizione del nodo centro di massa
        massCenter.worldPosition = SCNVector3(averageX, averageY, averageZ)
        return massCenter
    }
    
    private func drawCross(at node: SCNNode) {
        let lineMaterial = SCNMaterial()
        lineMaterial.diffuse.contents = UIColor.green.withAlphaComponent(0.8) // Verde fluorescente
        
        // Linea lungo l'asse X
        let xLineGeometry = SCNCylinder(radius: 0.02, height: 1.0)
        xLineGeometry.materials = [lineMaterial]
        let xLineNode = SCNNode(geometry: xLineGeometry)
        xLineNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2) // Ruota lungo l'asse Z
        xLineNode.position = SCNVector3(0, 0, 0) // Centro
        
        // Linea lungo l'asse Z
        let zLineGeometry = SCNCylinder(radius: 0.02, height: 1.0)
        zLineGeometry.materials = [lineMaterial]
        let zLineNode = SCNNode(geometry: zLineGeometry)
        zLineNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // Ruota lungo l'asse X
        zLineNode.position = SCNVector3(0, 0, 0) // Centro
        
        // Aggiungi le linee al nodo
        node.addChildNode(xLineNode)
        node.addChildNode(zLineNode)
    }
    
    ///Manage Camera Node
    func setCamera(scnView: SCNView, cameraNode: SCNNode, massCenter: SCNNode) {
        
        cameraNode.camera = SCNCamera()
        
        //        guard let floorNode = scnView.scene?.rootNode.childNode(withName: "POS_FLOOR", recursively: true) else {
        //
        //            print("Error")
        //            return
        //        }
        
        cameraNode.worldPosition = SCNVector3(
            massCenter.worldPosition.x,
            massCenter.worldPosition.y + 10,
            massCenter.worldPosition.z
        )
        
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 5
        cameraNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0)
        
        scnView.scene?.rootNode.childNodes
            .filter { $0.light?.type == .ambient }
            .forEach { $0.removeFromParentNode() }
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        ambientLight.light!.intensity = 1200
        scnView.scene?.rootNode.addChildNode(ambientLight)
        
        scnView.pointOfView = cameraNode
        scnView.scene?.rootNode.addChildNode(cameraNode)
        cameraNode.constraints = []
    }
    
    @MainActor
    func setCameraFollowPosition(scnView: SCNView, cameraNode: SCNNode) {
        
        print("Called from: \(Thread.isMainThread ? "Main Thread" : "Background Thread")")
        assert(Thread.isMainThread, "❌ Errore: setCameraFollowPosition chiamata da un thread in background!")
        

            // 1) Crea la camera
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.usesOrthographicProjection = true
            cameraNode.camera?.orthographicScale = 5
            
            // Rimuovi eventuali luci ambient già presenti
            scnView.scene?.rootNode.childNodes
                .filter { $0.light?.type == .ambient }
                .forEach { $0.removeFromParentNode() }
            
            // Aggiungi una luce ambient
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        ambientLight.light?.intensity = 1200
        scnView.scene?.rootNode.addChildNode(ambientLight)
        
        // 2) Aggiungi il cameraNode alla scena e impostalo come pointOfView
        scnView.scene?.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
        
        let followFloorConstraint = SCNTransformConstraint(inWorldSpace: true) { cameraNode, _ in
            var position = SCNVector3Zero
            
            DispatchQueue.main.sync {
                if let floorNode = scnView.scene?.rootNode.childNode(withName: "POS_FLOOR", recursively: true) {
                    position = SCNVector3(
                        floorNode.worldPosition.x,
                        floorNode.worldPosition.y + 10,
                        floorNode.worldPosition.z
                    )
                }
            }
            
            cameraNode.worldPosition = position
            cameraNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            
            return cameraNode.transform
        }
        
        // 4) Assegna il constraint al cameraNode
        cameraNode.constraints = [followFloorConstraint]
        
    }
    
    func setCameraUp(scnView: SCNView, cameraNode: SCNNode, massCenter: SCNNode) {
        cameraNode.camera = SCNCamera()
        
        // Add the camera node to the scene
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        // Position the camera at the same Y level as the mass center, and at a certain distance along the Z-axis
        let cameraDistance: Float = 10.0 // Distance in front of the mass center
        let cameraHeight: Float = massCenter.worldPosition.y + 2.0 // Slightly above the mass center
        
        cameraNode.worldPosition = SCNVector3(massCenter.worldPosition.x, cameraHeight, massCenter.worldPosition.z + cameraDistance)
        
        // Set the camera to use perspective projection
        cameraNode.camera?.usesOrthographicProjection = false
        
        // Optionally set the field of view
        cameraNode.camera?.fieldOfView = 60.0 // Adjust as needed
        
        // Make the camera look at the mass center
        //        let lookAtConstraint = SCNLookAtConstraint(target: massCenter)
        //        lookAtConstraint.isGimbalLockEnabled = true
        //        cameraNode.constraints = [lookAtConstraint]
        
        // Add ambient light to the scene
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor(white: 0.5, alpha: 1.0)
        scnView.scene?.rootNode.addChildNode(ambientLight)
        
        // Add a directional light to simulate sunlight
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light!.type = .directional
        directionalLight.light!.color = UIColor(white: 1.0, alpha: 1.0)
        directionalLight.eulerAngles = SCNVector3(-Float.pi / 3, 0, 0) // Adjust angle as needed
        scnView.scene?.rootNode.addChildNode(directionalLight)
        
        // Set the point of view of the scene to the camera node
        scnView.pointOfView = cameraNode
    }
    
    func generatePositionNode(_ color: UIColor, _ radius: CGFloat) -> SCNNode {
        
        let houseNode = SCNNode() //3 Sphere
        
        let sphere = SCNSphere(radius: radius)
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        let sphere2 = SCNSphere(radius: radius)
        let sphereNode2 = SCNNode()
        sphereNode2.geometry = sphere2
        var color2 = color
        sphereNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.6)
        sphereNode2.position = SCNVector3(0,    //y = altezza
                                          0,    //x = orizzontale
                                          -1)   //z = profondità
        
        let sphere3 = SCNSphere(radius: radius)
        let sphereNode3 = SCNNode()
        sphereNode3.geometry = sphere3
        var color3 = color
        sphereNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.blue.withAlphaComponent(0.4)
        sphereNode3.position = SCNVector3(0,    //y = altezza
                                          -0.5, //x = orizzontale a sx negativo
                                          0)    //z = profondità
        
        houseNode.addChildNode(sphereNode)
        houseNode.addChildNode(sphereNode2)
        houseNode.addChildNode(sphereNode3)
        //houseNode.worldPosition = SCNVector3(0.0, 3.0, 0.0)
        return houseNode
    }
    
    func createAxesNode(length: CGFloat = 1.0, radius: CGFloat = 0.02) {
        let axisNode = SCNNode()
        
        // X Axis (Red)
        let xAxis = SCNNode(geometry: SCNCylinder(radius: radius, height: length))
        xAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        xAxis.position = SCNVector3(length / 2, 0, 0) // Offset by half length
        xAxis.eulerAngles = SCNVector3(0, 0, Float.pi / 2) // Rotate cylinder along X-axis
        
        // Y Axis (Green)
        let yAxis = SCNNode(geometry: SCNCylinder(radius: radius, height: length))
        yAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        yAxis.position = SCNVector3(0, length / 2, 0) // Offset by half length
        
        // Z Axis (Blue)
        let zAxis = SCNNode(geometry: SCNCylinder(radius: radius, height: length))
        zAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        zAxis.position = SCNVector3(0, 0, length / 2) // Offset by half length
        zAxis.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // Rotate cylinder along Z-axis
        
        // Add axes to parent node
        axisNode.addChildNode(xAxis)
        axisNode.addChildNode(yAxis)
        axisNode.addChildNode(zAxis)
        self.scnView.scene?.rootNode.addChildNode(axisNode)
        
    }
    
    @MainActor func addRoomLocationNode() {
        
        if scnView.scene == nil {
            scnView.scene = SCNScene()
        }
        
        var userLocation = generatePositionNode(UIColor(red: 0, green: 0, blue: 255, alpha: 1.0), 0.2)
        userLocation.simdWorldTransform = simd_float4x4(0)
        userLocation.name = "POS_ROOM"
        scnView.scene?.rootNode.addChildNode(userLocation)
    }
    
    @MainActor func addFloorLocationNode() {
        
        if scnView.scene == nil {
            scnView.scene = SCNScene()
        }
        
        let sphere = SCNSphere(radius: 1.0)
        
        var userLocation = generatePositionNode(UIColor(red: 255, green: 0, blue: 0, alpha: 1.0), 0.2)
        userLocation.simdWorldTransform = simd_float4x4(0)
        //        userLocation.simdWorldTransform.columns.3.y = 3
        userLocation.renderingOrder = 10
        userLocation.geometry?.firstMaterial?.readsFromDepthBuffer = false
        userLocation.name = "POS_FLOOR"
        scnView.scene?.rootNode.addChildNode(userLocation)
    }
    
    func drawContent(roomsNode: [String]?, borders: Bool) {
        let excludedNames = ["Room", "Floor0", "Geom", "__selected__"]
        var drawnNodes = Set<String>()
        
        scnView.scene?.rootNode.childNodes(passingTest: { node, _ in
            guard let name = node.name else { return false }
            return !excludedNames.contains(name) && !name.hasSuffix("_grp")
        })
        .forEach { node in
            guard let nodeName = node.name else { return }
            
            //            resetNodeMaterial(node)
            
            node.geometry?.materials = [materialForNode(named: nodeName, roomsNode: roomsNode)]
            
            drawnNodes.insert(nodeName)
        }
    }
    
    private func materialForNode(named name: String, roomsNode: [String]?) -> SCNMaterial {
        let material = SCNMaterial()
        switch name {
        case "Floor0":
            material.diffuse.contents = UIColor.white.withAlphaComponent(0)
        case _ where name.hasPrefix("Floor"):
            material.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
        case _ where roomsNode?.contains(name) == true:
            material.diffuse.contents = UIColor.blue.withAlphaComponent(0.2)
        case _ where name.hasPrefix("Transi"):
            material.diffuse.contents = UIColor.white
        case _ where name.hasPrefix("Door") && name.hasPrefix("Open"):
            material.diffuse.contents = UIColor.white
        case _ where name.hasPrefix("Wall"):
            material.diffuse.contents = UIColor.black
        case _ where name.hasPrefix("Tabl"):
            material.diffuse.contents = UIColor.systemBrown
        case _ where name.hasPrefix("Chai"):
            material.diffuse.contents = UIColor.brown
        case _ where name.hasPrefix("Stor"):
            material.diffuse.contents = UIColor.gray
        case _ where name.hasPrefix("Sofa"):
            material.diffuse.contents = UIColor.blue
        case _ where name.hasPrefix("Tele"):
            material.diffuse.contents = UIColor.orange
        default:
            material.diffuse.contents = UIColor.black
        }
        material.lightingModel = .physicallyBased
        return material
    }
    
    private func resetNodeMaterial(_ node: SCNNode) {
        // Reimposta il materiale del nodo eliminando eventuali trasparenze o modifiche precedenti
        node.geometry?.materials = [SCNMaterial()] // Crea un materiale vuoto come reset
    }
    
    @MainActor
    func updatePosition(_ newPosition: simd_float4x4, _ matrix: RotoTraslationMatrix?, floor: Floor) {
        
        if matrix == nil {
            self.scnView.scene?.rootNode.childNodes.first(where: { $0.name == "POS_ROOM" })?.simdWorldTransform = newPosition
            
                self.scnView.scene?.rootNode.childNodes.first(where: { $0.name == "POS_FLOOR" })?.simdWorldTransform = newPosition
            
        }
        
        if let r = matrix {
                updateFloorPositionNode(in: self.scnView, newPosition: newPosition, rotoTranslationMatrix: matrix!, floor: floor)
            
        }
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func updateFloorPositionNode(in scnView: SCNView, newPosition: simd_float4x4, rotoTranslationMatrix r: RotoTraslationMatrix, floor: Floor) {
        
        var nodePosition = scnView.scene?.rootNode.childNodes.first(where: { $0.name == "POS_FLOOR" })
        nodePosition?.simdWorldTransform = newPosition
        applyRotoTraslation(to: nodePosition!, with: r)
        
    }
    
    public func makeUIView(context: Context) -> SCNView {
        
        handler.scnView = scnView
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        scnView.backgroundColor = UIColor.white
        
        return scnView
    }
    
    public func updateUIView(_ uiView: SCNView, context: Context) {}
    
    public func makeCoordinator() -> SCNViewContainerCoordinator {
        SCNViewContainerCoordinator(self)
    }
    
    public class SCNViewContainerCoordinator: NSObject {
        public var parent: SCNViewContainer
        
        public init(_ parent: SCNViewContainer) {
            self.parent = parent
        }
        
        @MainActor @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let camera = parent.cameraNode.camera else { return }
            
            if gesture.state == .changed {
                let newScale = camera.orthographicScale / Double(gesture.scale)
                camera.orthographicScale = max(1.0, min(newScale, 200.0))
                gesture.scale = 1
            }
        }
        
        @MainActor @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            
            let translation = gesture.translation(in: parent.scnView)
            
            parent.cameraNode.position.x -= Float(translation.x) * 0.04
            parent.cameraNode.position.z -= Float(translation.y) * 0.04
            
            gesture.setTranslation(.zero, in: parent.scnView)
            
        }
    }
}

@available(iOS 16.0, *)
public struct SCNViewContainer_Previews: PreviewProvider {
    public static var previews: some View {
        SCNViewContainer()
    }
}

@MainActor
class HandleTap: UIViewController {
    var scnView: SCNView?
    
    @objc func handleTap(_ gestureRecognize: UITapGestureRecognizer) {
        print("handleTap")
        
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView!.hitTest(p, options: nil)
        if let tappedNode = hitResults.first?.node {
            print(tappedNode)
        }
    }
}

@MainActor
class RenderDelegate: NSObject, @preconcurrency SCNSceneRendererDelegate {
    
    var lastRenderer: SCNSceneRenderer!
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        lastRenderer = renderer
    }
}




