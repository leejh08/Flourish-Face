import Foundation

enum Chapter: Int, CaseIterable, Identifiable, Hashable {
    case seed = 1
    case sprout = 2
    case bloom = 3
    case breeze = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .seed: return "Awaken the Seed"
        case .sprout: return "Grow the Sprout"
        case .bloom: return "Bloom the Flower"
        case .breeze: return "Feel the Breeze"
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
        case .seed: return "Gently move your facial muscles"
        case .sprout: return "Your movements are growing"
        case .bloom: return "It's becoming more natural"
        case .breeze: return "Move freely and relax"
        }
    }

    var story: String {
        switch self {
        case .seed: return "A tiny seed is waking up\nBreathe life into it\nwith gentle movements"
        case .sprout: return "The sprout is reaching for sunlight\nGive it strength\nwith a warm expression"
        case .bloom: return "The bud is about to open\nNatural movements\nwill make it bloom"
        case .breeze: return "A breeze wraps around the garden\nFreely relax\nyour expression"
        }
    }
}
