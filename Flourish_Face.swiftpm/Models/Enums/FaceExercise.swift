import Foundation

enum FaceExercise: Int, CaseIterable, Hashable {
    case browRaise = 0
    case smile = 1
    case eyeClosure = 2
    case jawOpen = 3
    case mouthFrown = 4

    var shortName: String {
        switch self {
        case .browRaise: return String(localized: "Brow")
        case .smile: return String(localized: "Smile")
        case .eyeClosure: return String(localized: "Eyes")
        case .jawOpen: return String(localized: "Jaw")
        case .mouthFrown: return String(localized: "Frown")
        }
    }

    var guide: String {
        switch self {
        case .browRaise: return String(localized: "Raise your eyebrows up high")
        case .smile: return String(localized: "Give a big, wide smile")
        case .eyeClosure: return String(localized: "Close both eyes tightly")
        case .jawOpen: return String(localized: "Open your mouth wide")
        case .mouthFrown: return String(localized: "Pull your mouth corners downward")
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
        case .browRaise: return String(localized: "Lift both eyebrows to create forehead lines")
        case .smile: return String(localized: "Spread both corners of your mouth wide")
        case .eyeClosure: return String(localized: "Squeeze your eyes shut gently")
        case .jawOpen: return String(localized: "Drop your jaw as far as comfortable")
        case .mouthFrown: return String(localized: "Push your lower lip and corners downward")
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
