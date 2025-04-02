import SwiftUI
import SceneKit

struct Model3DConvertible: ComponentConvertible {
    let url: URL?
    let allowsCameraControl: Bool
    let backgroundColor: ColorConvertible
    let position: SIMD3<Float>  // Position parameter
    let rotation: SIMD3<Float>  // Rotation parameter in degrees
    
    init(_ component: Component) {
        if let urlString: String = component.decode("url") {
            self.url = URL(string: urlString)
        } else {
            self.url = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/biplane/toy_biplane_idle.usdz")
        }
        
        self.allowsCameraControl = component.decode("allowsCameraControl") ?? true
        self.backgroundColor = component.decode("backgroundColor") ?? .clear
        
        // Initialize position from x, y, z components or default to origin
        let x: Float = Float(component.decode("positionX") ?? 0.0)
        let y: Float = Float(component.decode("positionY") ?? 0.0)
        let z: Float = Float(component.decode("positionZ") ?? 0.0)
        self.position = SIMD3<Float>(x, y, z)
        
        // Initialize rotation from euler angles (in degrees) or default to zero
        let rotX: Float = Float(component.decode("rotationX") ?? 0.0)
        let rotY: Float = Float(component.decode("rotationY") ?? 0.0)
        let rotZ: Float = Float(component.decode("rotationZ") ?? 0.0)
        self.rotation = SIMD3<Float>(rotX, rotY, rotZ)
    }
    
    var component: Component {
        var props: [String: AST] = [
            "allowsCameraControl": allowsCameraControl,
            "backgroundColor": backgroundColor.component,
            "positionX": Double(position.x),
            "positionY": Double(position.y),
            "positionZ": Double(position.z),
            "rotationX": Double(rotation.x),
            "rotationY": Double(rotation.y),
            "rotationZ": Double(rotation.z)
        ]
        
        if let url = url {
            props["url"] = url.absoluteString
        }
        
        return Component(type: Self.componentName, props: props)
    }
}

extension Model3DConvertible: View {
    var body: some View {
        SceneContainer(
            url: url,
            allowsCameraControl: allowsCameraControl,
            backgroundColor: backgroundColor.swiftUI,
            position: position,
            rotation: rotation
        )
    }
}

#if os(iOS)
private struct SceneContainer: UIViewRepresentable {
    let url: URL?
    let allowsCameraControl: Bool
    let backgroundColor: Color
    let position: SIMD3<Float>
    let rotation: SIMD3<Float>
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.delegate = context.coordinator
        configureSceneView(sceneView)
        return sceneView
    }
    
    func updateUIView(_ sceneView: SCNView, context: Context) {
        updateSceneView(sceneView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#elseif os(macOS)
private struct SceneContainer: NSViewRepresentable {
    let url: URL?
    let allowsCameraControl: Bool
    let backgroundColor: Color
    let position: SIMD3<Float>
    let rotation: SIMD3<Float>
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.delegate = context.coordinator
        configureSceneView(sceneView)
        return sceneView
    }
    
    func updateNSView(_ sceneView: SCNView, context: Context) {
        updateSceneView(sceneView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
#endif

class Coordinator: NSObject, SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let camera = renderer.pointOfView else { return }
        
        let position = camera.position
        let rotation = camera.eulerAngles
        
        // Implement camera constraints if needed
        constrainCamera(camera, in: renderer)
    }
    
    private func constrainCamera(_ camera: SCNNode, in renderer: SCNSceneRenderer) {
        guard let scene = renderer.scene else { return }
        
        // Get the bounding sphere of the entire scene
        let boundingSphere = scene.rootNode.boundingSphere
        let radius = CGFloat(boundingSphere.radius)
        
        // Set minimum and maximum distance from center
        let minDistance: CGFloat = radius * 0.5
        let maxDistance: CGFloat = radius * 5.0
        
        // Calculate current distance from center
        let distance = CGFloat(sqrt(
            pow(camera.position.x, 2) +
            pow(camera.position.y, 2) +
            pow(camera.position.z, 2)
        ))
        
        // Constrain distance
        if CGFloat(distance) < minDistance || CGFloat(distance) > maxDistance {
            let normalizedDirection = SCNVector3(
                CGFloat(camera.position.x) / CGFloat(distance),
                CGFloat(camera.position.y) / CGFloat(distance),
                CGFloat(camera.position.z) / CGFloat(distance)
            )
            
            let constrainedDistance = min(max(distance, minDistance), maxDistance)
            camera.position = SCNVector3(
                CGFloat(normalizedDirection.x) * CGFloat(constrainedDistance),
                CGFloat(normalizedDirection.y) * CGFloat(constrainedDistance),
                CGFloat(normalizedDirection.z) * CGFloat(constrainedDistance)
            )
        }
    }
}

private extension SceneContainer {
    func configureSceneView(_ sceneView: SCNView) {
        // Basic setup
        sceneView.allowsCameraControl = allowsCameraControl
        #if os(iOS)
        sceneView.backgroundColor = UIColor(backgroundColor)
        #elseif os(macOS)
        sceneView.backgroundColor = NSColor(backgroundColor)
        #endif
        
        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true
        
        if let url = url {
            loadModel(in: sceneView, from: url)
        }
    }
    
    func updateSceneView(_ sceneView: SCNView) {
        sceneView.allowsCameraControl = allowsCameraControl
        #if os(iOS)
        sceneView.backgroundColor = UIColor(backgroundColor)
        #elseif os(macOS)
        sceneView.backgroundColor = NSColor(backgroundColor)
        #endif
        
        // Update model position and rotation
        if let rootNode = sceneView.scene?.rootNode.childNodes.first {
            rootNode.position = SCNVector3(position)
            rootNode.eulerAngles = SCNVector3(
                rotation.x * .pi / 180,  // Convert degrees to radians
                rotation.y * .pi / 180,
                rotation.z * .pi / 180
            )
        }
    }
    
    func loadModel(in sceneView: SCNView, from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("Failed to download model: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Save to temporary file
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("model.usdz")
            try? data.write(to: tempUrl)
            
            DispatchQueue.main.async {
                do {
                    // Try to load the scene directly
                    let scene = try SCNScene(url: tempUrl)
                    
                    // Calculate the bounding sphere of the model
                    let boundingSphere = scene.rootNode.boundingSphere
                    
                    // Configure camera
                    let cameraNode = SCNNode()
                    cameraNode.camera = SCNCamera()
                    
                    // Set camera clipping planes based on model size
                    cameraNode.camera?.zNear = 0.1
                    cameraNode.camera?.zFar = CGFloat(boundingSphere.radius) * 100
                    
                    // Calculate initial camera position based on bounding sphere
                    let radius = boundingSphere.radius
                    let initialDistance = radius * 2.5
                    #if os(iOS)
                    cameraNode.position = SCNVector3(
                        x: Float(initialDistance),
                        y: Float(initialDistance * 0.5),
                        z: Float(initialDistance)
                    )
                    #elseif os(macOS)
                    cameraNode.position = SCNVector3(
                        x: Double(initialDistance),
                        y: Double(initialDistance * 0.5),
                        z: Double(initialDistance)
                    )
                    #endif
                    
                    // Look at the center of the model
                    cameraNode.look(at: boundingSphere.center)
                    
                    // Set initial model position and rotation
                    if let modelNode = scene.rootNode.childNodes.first {
                        modelNode.position = SCNVector3(position)
                        modelNode.eulerAngles = SCNVector3(
                            rotation.x * .pi / 180,  // Convert degrees to radians
                            rotation.y * .pi / 180,
                            rotation.z * .pi / 180
                        )
                    }
                    
                    scene.rootNode.addChildNode(cameraNode)
                    
                    // Set the scene and camera
                    sceneView.scene = scene
                    sceneView.pointOfView = cameraNode
                    
                    print("Model loaded successfully")
                } catch {
                    print("Failed to load scene: \(error)")
                }
            }
        }.resume()
    }
}
