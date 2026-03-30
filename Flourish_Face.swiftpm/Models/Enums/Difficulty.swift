import SwiftUI

enum Difficulty: String, CaseIterable {
    case basic = "basic"
    case advanced = "advanced"

    var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .advanced: return "Advanced"
        }
    }

    var description: String {
        switch self {
        case .basic: return "3 simple exercises\nfor beginners"
        case .advanced: return "5 exercises\nfor a full workout"
        }
    }

    var exerciseCount: Int {
        switch self {
        case .basic: return 3
        case .advanced: return 5
        }
    }

    var iconName: String {
        switch self {
        case .basic: return "leaf"
        case .advanced: return "flame"
        }
    }

    var iconColor: Color {
        switch self {
        case .basic: return .primaryGreen
        case .advanced: return .amberDark
        }
    }
}
