import SwiftUI
import SceneKit
import GLTFKit2
import OSLog

public struct Model3DComponent: Component {
    public static var directiveName: String = "Model3D"
    
    public var name: String?
    public var url: URL?
    public var scale: SIMD3<Float>
    public var rotation: SIMD3<Float>
    public var position: SIMD3<Float>
    public var autoRotate: Bool
    public var cameraControl: Bool
}

extension Model3DComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }
        
        name = directive["name"]
        url = directive["url"]
        
        // Parse scale (can be a single number or array of 3)
        if let scaleValue: Double = directive["scale"] {
            scale = SIMD3<Float>(repeating: Float(scaleValue))
        } else if let scaleArray = directive.props["scale"] as? [Double], scaleArray.count == 3 {
            scale = SIMD3<Float>(Float(scaleArray[0]), Float(scaleArray[1]), Float(scaleArray[2]))
        } else {
            scale = SIMD3<Float>(repeating: 1.0)
        }
        
        // Parse rotation (in degrees, will convert to radians)
        if let rotationArray = directive.props["rotation"] as? [Double], rotationArray.count == 3 {
            rotation = SIMD3<Float>(
                Float(rotationArray[0]) * .pi / 180,
                Float(rotationArray[1]) * .pi / 180,
                Float(rotationArray[2]) * .pi / 180
            )
        } else {
            rotation = SIMD3<Float>.zero
        }
        
        // Parse position
        if let positionArray = directive.props["position"] as? [Double], positionArray.count == 3 {
            position = SIMD3<Float>(Float(positionArray[0]), Float(positionArray[1]), Float(positionArray[2]))
        } else {
            position = SIMD3<Float>.zero
        }
        
        autoRotate = directive["autoRotate"] ?? false
        cameraControl = directive["cameraControl"] ?? true
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitModel3D(self)
    }
}

extension Model3DComponent: View {
    public var body: some View {
        if let url = url {
            Model3DView(
                url: url,
                scale: scale,
                rotation: rotation,
                position: position,
                autoRotate: autoRotate,
                cameraControl: cameraControl
            )
        } else if let name = name {
            // Try to load from bundle resources
            if let bundleURL = Bundle.main.url(forResource: name, withExtension: "gltf") ??
                              Bundle.main.url(forResource: name, withExtension: "glb") {
                Model3DView(
                    url: bundleURL,
                    scale: scale,
                    rotation: rotation,
                    position: position,
                    autoRotate: autoRotate,
                    cameraControl: cameraControl
                )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary)
                    .overlay(
                        Text("Model not found")
                            .foregroundColor(.secondary)
                    )
            }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
                .overlay(
                    Text("No model specified")
                        .foregroundColor(.secondary)
                )
        }
    }
}

// MARK: - SceneKit View
private struct Model3DView: View {
    let url: URL
    let scale: SIMD3<Float>
    let rotation: SIMD3<Float>
    let position: SIMD3<Float>
    let autoRotate: Bool
    let cameraControl: Bool
    
    @State private var scene: SCNScene?
    @State private var isLoading = true
    @State private var loadError: String?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Model3D", category: "Model3DView")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let scene = scene {
                    SceneView(
                        scene: scene,
                        options: cameraControl ? [.allowsCameraControl] : [],
                        preferredFramesPerSecond: 60,
                        antialiasingMode: .multisampling4X
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                } else if let error = loadError {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        )
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
            }
            .task {
                await loadModel()
            }
        }
    }
    
    private func loadModel() async {
        do {
            // Load GLTF/GLB file
            let asset = try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let asset = try GLTFAsset(url: url)
                        continuation.resume(returning: asset)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Asset is non-optional now after successful creation
            
            // Convert to SceneKit
            let scnScene = await withCheckedContinuation { continuation in
                let scene = SCNScene()
                let source = GLTFSCNSceneSource(asset: asset)
                
                if let defaultScene = source.defaultScene {
                    for node in defaultScene.rootNode.childNodes {
                        let modelNode = node.clone()
                        
                        // Apply transformations
                        modelNode.scale = SCNVector3(scale.x, scale.y, scale.z)
                        modelNode.eulerAngles = SCNVector3(rotation.x, rotation.y, rotation.z)
                        modelNode.position = SCNVector3(position.x, position.y, position.z)
                        
                        // Add auto-rotation if enabled
                        if autoRotate {
                            let rotateAction = SCNAction.repeatForever(
                                SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 10)
                            )
                            modelNode.runAction(rotateAction, forKey: "rotation")
                        }
                        
                        scene.rootNode.addChildNode(modelNode)
                    }
                }
                
                continuation.resume(returning: scene)
            }
            
            // Setup lighting
            setupLighting(for: scnScene)
            
            // Setup camera with auto-framing
            setupCameraWithAutoFraming(for: scnScene)
            
            await MainActor.run {
                self.scene = scnScene
                self.isLoading = false
            }
            
            logger.debug("Successfully loaded model from \(url.absoluteString)")
            
        } catch {
            await MainActor.run {
                self.loadError = "Failed to load model"
                self.isLoading = false
            }
            logger.error("Failed to load model: \(error.localizedDescription)")
        }
    }
    
    private func setupLighting(for scene: SCNScene) {
        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        #if os(iOS) || os(tvOS) || os(watchOS)
        ambientLight.light?.color = UIColor.white
        #elseif os(macOS)
        ambientLight.light?.color = NSColor.white
        #endif
        scene.rootNode.addChildNode(ambientLight)
        
        // Directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 1000
        #if os(iOS) || os(tvOS) || os(watchOS)
        directionalLight.light?.color = UIColor.white
        #elseif os(macOS)
        directionalLight.light?.color = NSColor.white
        #endif
        directionalLight.position = SCNVector3(x: 0, y: 10, z: 10)
        directionalLight.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func setupCameraWithAutoFraming(for scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Calculate bounding box of the entire scene
        let (min, max) = scene.rootNode.boundingBox
        let boundingBox = SCNVector3(
            x: max.x - min.x,
            y: max.y - min.y,
            z: max.z - min.z
        )
        
        // Calculate the center of the bounding box
        let center = SCNVector3(
            x: (min.x + max.x) / 2,
            y: (min.y + max.y) / 2,
            z: (min.z + max.z) / 2
        )
        
        // Calculate the maximum dimension of the bounding box
        let maxDimension = Swift.max(boundingBox.x, Swift.max(boundingBox.y, boundingBox.z))
        
        // Position camera at a distance proportional to the model size
        // Using a factor of 2.5 to ensure the entire model is visible
        let cameraDistance = maxDimension * 2.5
        
        // Position camera looking at the center of the model
        cameraNode.position = SCNVector3(
            x: center.x,
            y: center.y,
            z: center.z + cameraDistance
        )
        
        // Look at the center of the model
        cameraNode.look(at: center, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        
        // Set camera properties
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = cameraDistance * 10
        
        // Enable automatic adaptation to lighting
        cameraNode.camera?.automaticallyAdjustsZRange = true
        
        scene.rootNode.addChildNode(cameraNode)
    }
}

private enum ModelLoadError: Error {
    case invalidAsset
    case loadingFailed(String)
}
