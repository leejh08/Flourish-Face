import Foundation

enum Chapter: Int, CaseIterable, Identifiable, Hashable {
    case seed = 1
    case sprout = 2
    case bloom = 3
    case breeze = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .seed: return String(localized: "Awaken the Seed")
        case .sprout: return String(localized: "Grow the Sprout")
        case .bloom: return String(localized: "Bloom the Flower")
        case .breeze: return String(localized: "Feel the Breeze")
        }
    }

    var symbolName: String {
        switch self {
        case .seed: return "leaf"
        case .sprout: return "leaf.fill"
        case .bloom: return "flower.fill"
        case .breeze: return "wind"
        }
    }

    var guide: String {
        switch self {
        case .seed: return String(localized: "Gently move your facial muscles")
        case .sprout: return String(localized: "Your movements are growing")
        case .bloom: return String(localized: "It's becoming more natural")
        case .breeze: return String(localized: "Move freely and relax")
        }
    }

    var story: String {
        switch self {
        case .seed: return String(localized: "A tiny seed is waking up\nBreathe life into it\nwith gentle movements")
        case .sprout: return String(localized: "The sprout is reaching for sunlight\nGive it strength\nwith a warm expression")
        case .bloom: return String(localized: "The bud is about to open\nNatural movements\nwill make it bloom")
        case .breeze: return String(localized: "A breeze wraps around the garden\nFreely relax\nyour expression")
        }
    }
}
