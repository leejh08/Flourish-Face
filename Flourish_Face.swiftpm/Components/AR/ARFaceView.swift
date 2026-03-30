import SwiftUI
import ARKit
import AVFoundation

struct ARFaceView: UIViewRepresentable {
    let manager: FaceTrackingManager
    let chapter: Chapter
    let exercise: FaceExercise
    var autoStart: Bool = true

    #if DEBUG
    static var forceUnsupported: Bool = false
    #endif

    static var isFaceTrackingSupported: Bool {
        #if DEBUG
        if forceUnsupported { return false }
        #endif
        return ARFaceTrackingConfiguration.isSupported
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.automaticallyUpdatesLighting = true
        sceneView.clipsToBounds = true

        if autoStart {
            manager.startTracking(on: sceneView, chapter: chapter, exercise: exercise)
        }

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        guard autoStart, !manager.isTracking else { return }
        manager.startTracking(on: uiView, chapter: chapter, exercise: exercise)
    }

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        coordinator.manager.stopTracking()
    }

    class Coordinator: NSObject {
        let manager: FaceTrackingManager

        init(manager: FaceTrackingManager) {
            self.manager = manager
        }
    }
}
