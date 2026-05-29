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

    
    static var isAnyFaceTrackingAvailable: Bool {
        isFaceTrackingSupported ||
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager)
    }

    func makeUIView(context: Context) -> UIView {
        if ARFaceView.isFaceTrackingSupported {
            let sceneView = ARSCNView()
            sceneView.automaticallyUpdatesLighting = true
            sceneView.clipsToBounds = true
            if autoStart {
                manager.startTracking(on: sceneView, chapter: chapter, exercise: exercise)
            }
            return sceneView
        } else {
            let previewView = VisionPreviewView()
            if autoStart {
                manager.startVisionTracking(exercise: exercise)
                previewView.captureSession = manager.visionTracker?.captureSession
            }
            return previewView
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard autoStart, !manager.isTracking else { return }
        if let sceneView = uiView as? ARSCNView {
            manager.startTracking(on: sceneView, chapter: chapter, exercise: exercise)
        } else if let previewView = uiView as? VisionPreviewView {
            manager.startVisionTracking(exercise: exercise)
            previewView.captureSession = manager.visionTracker?.captureSession
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.manager.stopTracking()
    }

    class Coordinator: NSObject {
        let manager: FaceTrackingManager

        init(manager: FaceTrackingManager) {
            self.manager = manager
        }
    }
}
