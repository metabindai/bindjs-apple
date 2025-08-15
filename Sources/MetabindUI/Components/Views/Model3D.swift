import SwiftUI
import SceneKit
import GLTFKit2
import OSLog

// MARK: - Model3DComponent
/// A SwiftUI component that displays a GLTF/GLB model using SceneKit with production-ready
/// threading, caching, lifecycle, and error handling.
public struct Model3DComponent: Component {
    public static var directiveName: String = "Model3D"

    // MARK: Public API
    /// Optional GLTF/GLB file name (without extension) to load from a bundle.
    public var name: String?
    /// Optional direct URL to a model. Supports file or remote URLs.
    public var url: URL?
    /// XYZ scale applied to the imported model container. Defaults to (1,1,1).
    public var scale: SIMD3<Float>
    /// Euler rotation in **radians** applied to the container. Defaults to zero.
    public var rotation: SIMD3<Float>
    /// XYZ position applied to the container. Defaults to zero.
    public var position: SIMD3<Float>
    /// Whether to continuously rotate the model around Y.
    public var autoRotate: Bool
    /// Allow user camera control via SceneKit's trackball controller.
    public var cameraControl: Bool

    /// Scene frame rate hint. Default 60.
    public var preferredFPS: Int
    /// Scene antialiasing. Default 4x.
    public var antialiasing: SCNAntialiasingMode
    /// Background color for the SceneView.
    public var backgroundColor: Color

    /// Enable HDR rendering and tone mapping.
    public var wantsHDR: Bool
    /// Optional environment map (e.g., "env.exr") located in the chosen bundle.
    public var environmentMapName: String?
    /// If true, applies a -90° rotation around X to correct Z-up assets.
    public var fixZUp: Bool

    /// Optional bundle used for `name` lookup and resources (env maps). Defaults to `.main`.
    public var resourceBundle: Bundle
}

// MARK: - Directive init (kept compatible with caller DSL)
extension Model3DComponent {
    public init?(from directive: Directive) {
        guard directive.type == Self.directiveName else { return nil }

        name = directive["name"]
        url = directive["url"]

        // Parse scale (single or [x,y,z])
        if let scaleValue: Double = directive["scale"] {
            scale = SIMD3<Float>(repeating: Float(scaleValue))
        } else if let scaleArray = directive.props["scale"] as? [Double], scaleArray.count == 3 {
            scale = SIMD3<Float>(Float(scaleArray[0]), Float(scaleArray[1]), Float(scaleArray[2]))
        } else {
            scale = SIMD3<Float>(repeating: 1.0)
        }

        // rotation is specified in degrees in the directive; convert to radians
        if let rotationArray = directive.props["rotation"] as? [Double], rotationArray.count == 3 {
            rotation = SIMD3<Float>(
                Float(rotationArray[0]) * .pi / 180,
                Float(rotationArray[1]) * .pi / 180,
                Float(rotationArray[2]) * .pi / 180
            )
        } else {
            rotation = .zero
        }

        if let positionArray = directive.props["position"] as? [Double], positionArray.count == 3 {
            position = SIMD3<Float>(Float(positionArray[0]), Float(positionArray[1]), Float(positionArray[2]))
        } else {
            position = .zero
        }

        autoRotate = directive["autoRotate"] ?? false
        cameraControl = directive["cameraControl"] ?? true

        preferredFPS = Int(directive["preferredFPS"] ?? 60)
        antialiasing = .multisampling4X
        backgroundColor = .clear
        wantsHDR = directive["wantsHDR"] ?? true
        environmentMapName = directive["environmentMapName"]
        fixZUp = directive["fixZUp"] ?? false
        resourceBundle = .main
    }
    
    public func accept<V>(visitor: inout V) -> V.Result where V : ComponentVisitor {
        visitor.visitModel3D(self)
    }
}

// MARK: - View conformance
extension Model3DComponent: View {
    public var body: some View {
        Model3DView(
            name: name,
            url: url,
            scale: scale,
            rotation: rotation,
            position: position,
            autoRotate: autoRotate,
            cameraControl: cameraControl,
            preferredFPS: preferredFPS,
            antialiasing: antialiasing,
            backgroundColor: backgroundColor,
            wantsHDR: wantsHDR,
            environmentMapName: environmentMapName,
            fixZUp: fixZUp,
            resourceBundle: resourceBundle
        )
    }
}

// MARK: - Scene Cache
private final class SceneCache {
    static let shared = SceneCache()
    private let cache = NSCache<NSString, SCNScene>()
    private init() { cache.countLimit = 16 }

    func scene(for key: String) -> SCNScene? { cache.object(forKey: key as NSString) }
    func set(_ scene: SCNScene, for key: String) { cache.setObject(scene, forKey: key as NSString) }
}

// MARK: - Internal View
private struct Model3DView: View {
    let name: String?
    let url: URL?
    let scale: SIMD3<Float>
    let rotation: SIMD3<Float>
    let position: SIMD3<Float>
    let autoRotate: Bool
    let cameraControl: Bool
    let preferredFPS: Int
    let antialiasing: SCNAntialiasingMode
    let backgroundColor: Color
    let wantsHDR: Bool
    let environmentMapName: String?
    let fixZUp: Bool
    let resourceBundle: Bundle

    @State private var scene: SCNScene?
    @State private var cameraNode: SCNNode?
    @State private var isLoading = false
    @State private var loadError: String?
    @State private var cacheKey: String = ""

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Model3D", category: "Model3DView")

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let scene, let pov = cameraNode {
                    SceneView(
                        scene: scene,
                        pointOfView: pov,
                        options: cameraControl ? [.allowsCameraControl] : [],
                        preferredFramesPerSecond: preferredFPS,
                        antialiasingMode: antialiasing,
                        delegate: nil,
                        technique: nil
                    )
                    .background(backgroundColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .accessibilityLabel("3D model viewer")
                } else if let error = loadError {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle").font(.largeTitle)
                                Text(error).font(.caption).multilineTextAlignment(.center)
                                Button("Retry") { reload() }
                            }.padding()
                        )
                } else if isLoading {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                        .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle()))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.quaternary)
                        .overlay(
                            Text("No model specified").foregroundColor(.secondary)
                        )
                }
            }
            .task(id: effectiveURLKey) { // reload when the input URL/name changes
                await loadIfNeeded()
            }
            .onDisappear { cleanup() }
            .onChange(of: autoRotate) { _, newValue in
                updateAutoRotate(newValue)
            }
        }
    }

    // A stable key representing the chosen source
    private var effectiveURLKey: String {
        if let url { return url.absoluteString }
        if let name { return "bundle://\(name)" }
        return ""
    }

    private func reload() { Task { await loadIfNeeded(force: true) } }

    // MARK: Loading
    private func loadIfNeeded(force: Bool = false) async {
        guard !effectiveURLKey.isEmpty else { return }
        if !force, cacheKey == effectiveURLKey, scene != nil { return }

        await MainActor.run {
            isLoading = true
            loadError = nil
            scene = nil
            cameraNode = nil
        }

        do {
            let localURL = try await resolveLocalURL()
            let key = localURL.absoluteString

            if let cached = SceneCache.shared.scene(for: key) {
                try buildSceneUsingCached(cached, cacheKey: key)
                return
            }

            // Parse GLTF off the main thread
            let asset: GLTFAsset = try await withCheckedThrowingContinuation { cont in
                DispatchQueue.global(qos: .userInitiated).async {
                    do { cont.resume(returning: try GLTFAsset(url: localURL)) }
                    catch { cont.resume(throwing: error) }
                }
            }

            // Build SceneKit objects on main
            try await MainActor.run {
                let source = GLTFSCNSceneSource(asset: asset)
                guard let importedScene = source.defaultScene else { throw ModelLoadError.invalidAsset }

                let scnScene = SCNScene()
                scnScene.background.contents = PlatformColor.clear

                // Environment / HDR
                if wantsHDR { scnScene.lightingEnvironment.intensity = 1.0 }
                if let env = environmentMapName, let envURL = resourceBundle.url(forResource: env, withExtension: nil) {
                    scnScene.lightingEnvironment.contents = envURL
                }

                let container = SCNNode()
                container.name = "container"

                let importedRoot = importedScene.rootNode.clone()
                container.addChildNode(importedRoot)

                // Apply transforms
                container.scale = SCNVector3(scale.x, scale.y, scale.z)
                var euler = SCNVector3(rotation.x, rotation.y, rotation.z)
                if fixZUp { euler.x += -.pi / 2 }
                container.eulerAngles = euler
                container.position = SCNVector3(position.x, position.y, position.z)

                if autoRotate {
                    let rotateAction = SCNAction.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 10))
                    container.runAction(rotateAction, forKey: "rotation")
                }

                scnScene.rootNode.addChildNode(container)

                setupLighting(for: scnScene)
                let pov = setupCameraWithAutoFraming(for: scnScene, target: container)

                // Cache
                SceneCache.shared.set(scnScene, for: key)

                // Commit state
                self.scene = scnScene
                self.cameraNode = pov
                self.isLoading = false
                self.cacheKey = key
            }

            Self.logger.debug("Successfully loaded model from \(localURL.absoluteString)")
        } catch {
            Self.logger.error("Failed to load model: \(error.localizedDescription)")
            await MainActor.run {
                self.loadError = userFacing(error)
                self.isLoading = false
            }
        }
    }

    // Resolve URL from name or remote, downloading if needed
    private func resolveLocalURL() async throws -> URL {
        if let direct = url {
            if direct.isFileURL { return direct }
            // Download remote file to cache directory
            return try await downloadToCache(from: direct)
        }
        if let name {
            if let u = resourceBundle.url(forResource: name, withExtension: "gltf") ??
                       resourceBundle.url(forResource: name, withExtension: "glb") {
                return u
            }
            throw ModelLoadError.loadingFailed("Model ‘\(name)’ not found in bundle")
        }
        throw ModelLoadError.loadingFailed("No model specified")
    }

    // MARK: Networking (simple, size-capped)
    private func downloadToCache(from remoteURL: URL) async throws -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = remoteURL.lastPathComponent.isEmpty ? UUID().uuidString : remoteURL.lastPathComponent
        let destination = caches.appendingPathComponent("Model3D_\(fileName)")

        if FileManager.default.fileExists(atPath: destination.path) { return destination }

        var request = URLRequest(url: remoteURL)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw ModelLoadError.loadingFailed("Failed to download model")
        }
        // Basic size cap: 200 MB
        guard data.count < 200 * 1024 * 1024 else { throw ModelLoadError.loadingFailed("Model too large") }
        try data.write(to: destination, options: [.atomic])
        return destination
    }

    // Use cached scene
    @MainActor private func buildSceneUsingCached(_ cached: SCNScene, cacheKey: String) throws {
        // Copy the cached scene so we can safely mutate camera/IBL per instance if desired.
        // (SCNScene is a reference type; when reusing, avoid double-adding nodes.)
        let scnScene = cached

        // Ensure environment and HDR settings are applied (idempotent)
        if wantsHDR { scnScene.lightingEnvironment.intensity = 1.0 }
        if let env = environmentMapName, let envURL = resourceBundle.url(forResource: env, withExtension: nil) {
            scnScene.lightingEnvironment.contents = envURL
        }

        // Find container
        guard let container = scnScene.rootNode.childNode(withName: "container", recursively: false) else {
            throw ModelLoadError.loadingFailed("Cached scene missing container node")
        }
        // Re-apply user transforms (in case caller changed them)
        container.scale = SCNVector3(scale.x, scale.y, scale.z)
        var euler = SCNVector3(rotation.x, rotation.y, rotation.z)
        if fixZUp { euler.x += -.pi / 2 }
        container.eulerAngles = euler
        container.position = SCNVector3(position.x, position.y, position.z)

        updateAutoRotate(autoRotate, on: container)

        // Reframe & camera
        let pov = setupCameraWithAutoFraming(for: scnScene, target: container)

        // Commit state
        self.scene = scnScene
        self.cameraNode = pov
        self.isLoading = false
        self.cacheKey = cacheKey
    }

    // MARK: Lighting / Camera
    @MainActor private func setupLighting(for scene: SCNScene) {
        // Ambient
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

        // Directional
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

    /// Creates and positions a camera that frames the target's world bounds.
    @MainActor private func setupCameraWithAutoFraming(for scene: SCNScene, target: SCNNode) -> SCNNode {
        // Remove old camera if any
        if let old = cameraNode { old.removeFromParentNode() }

        let cameraNode = SCNNode()
        cameraNode.name = "pov"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = wantsHDR

        // Compute world-space bounds
        let (localMin, localMax) = target.boundingBox
        let corners = [
            SCNVector3(localMin.x, localMin.y, localMin.z),
            SCNVector3(localMin.x, localMin.y, localMax.z),
            SCNVector3(localMin.x, localMax.y, localMin.z),
            SCNVector3(localMin.x, localMax.y, localMax.z),
            SCNVector3(localMax.x, localMin.y, localMin.z),
            SCNVector3(localMax.x, localMin.y, localMax.z),
            SCNVector3(localMax.x, localMax.y, localMin.z),
            SCNVector3(localMax.x, localMax.y, localMax.z)
        ]
        let worldCorners = corners.map { target.convertPosition($0, to: nil) }
        var minCorner = worldCorners.first ?? SCNVector3Zero
        var maxCorner = worldCorners.first ?? SCNVector3Zero
        for c in worldCorners {
            minCorner.x = Swift.min(minCorner.x, c.x)
            minCorner.y = Swift.min(minCorner.y, c.y)
            minCorner.z = Swift.min(minCorner.z, c.z)
            maxCorner.x = Swift.max(maxCorner.x, c.x)
            maxCorner.y = Swift.max(maxCorner.y, c.y)
            maxCorner.z = Swift.max(maxCorner.z, c.z)
        }

        let size = SCNVector3(maxCorner.x - minCorner.x, maxCorner.y - minCorner.y, maxCorner.z - minCorner.z)
        let center = SCNVector3((minCorner.x + maxCorner.x)/2, (minCorner.y + maxCorner.y)/2, (minCorner.z + maxCorner.z)/2)
        let maxDimension = max(size.x, max(size.y, size.z))
        let epsilon: Float = 1e-4
        let distance = max(0.5, Double(max(Float(maxDimension), epsilon)) * 2.5)

        cameraNode.position = SCNVector3(center.x, center.y, center.z + CGFloat(distance))
        cameraNode.look(at: center, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))

        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar  = distance * 50
        cameraNode.camera?.automaticallyAdjustsZRange = true

        scene.rootNode.addChildNode(cameraNode)
        return cameraNode
    }

    // MARK: Auto-rotate
    @MainActor private func updateAutoRotate(_ enabled: Bool) {
        guard let container = scene?.rootNode.childNode(withName: "container", recursively: false) else { return }
        updateAutoRotate(enabled, on: container)
    }

    @MainActor private func updateAutoRotate(_ enabled: Bool, on node: SCNNode) {
        node.removeAction(forKey: "rotation")
        if enabled {
            let rotate = SCNAction.repeatForever(.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 10))
            node.runAction(rotate, forKey: "rotation")
        }
    }

    // MARK: Cleanup
    @MainActor private func cleanup() {
        if let node = scene?.rootNode.childNode(withName: "container", recursively: false) {
            node.removeAllActions()
        }
        cameraNode?.removeFromParentNode()
        cameraNode = nil
        scene = nil // release GPU resources
    }

    // MARK: Error surfaces
    private func userFacing(_ error: Error) -> String {
        switch error {
        case ModelLoadError.invalidAsset:
            return "The model file appears to be invalid."
        case ModelLoadError.loadingFailed(let message):
            return message
        default:
            return "Failed to load model."
        }
    }
}

// MARK: - Errors
private enum ModelLoadError: Error {
    case invalidAsset
    case loadingFailed(String)
}

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
public typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
public typealias PlatformColor = NSColor
#endif
