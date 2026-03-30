import Foundation

enum FaceExercise: Int, CaseIterable, Hashable {
    case browRaise = 0
    case smile = 1
    case eyeClosure = 2
    case jawOpen = 3
    case mouthFrown = 4

    var shortName: String {
        switch self {
        case .browRaise: return "Brow"
        case .smile: return "Smile"
        case .eyeClosure: return "Eyes"
        case .jawOpen: return "Jaw"
        case .mouthFrown: return "Frown"
        }
    }

    var guide: String {
        switch self {
        case .browRaise: return "Raise your eyebrows up high"
        case .smile: return "Give a big, wide smile"
        case .eyeClosure: return "Close both eyes tightly"
        case .jawOpen: return "Open your mouth wide"
        case .mouthFrown: return "Pull your mouth corners downward"
        }
    }

    var symbolName: String {
        switch self {
        case .browRaise: return "eyebrow"
        case .smile: return "face.smiling"
        case .eyeClosure: return "eye.slash"
        case .jawOpen: return "mouth.fill"
        case .mouthFrown: return "mouth"
        }
    }

    var tip: String {
        switch self {
        case .browRaise: return "Lift both eyebrows to create forehead lines"
        case .smile: return "Spread both corners of your mouth wide"
        case .eyeClosure: return "Squeeze your eyes shut gently"
        case .jawOpen: return "Drop your jaw as far as comfortable"
        case .mouthFrown: return "Push your lower lip and corners downward"
        }
    }

    static func exercises(for difficulty: Difficulty) -> [FaceExercise] {
        switch difficulty {
        case .basic:
            return [.browRaise, .smile, .eyeClosure]
        case .advanced:
            return FaceExercise.allCases
        }
    }
}
