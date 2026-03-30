import Foundation

enum PlantStage: Int, Codable, CaseIterable {
    case seed = 0
    case sprout = 1
    case bloom = 2
    case tree = 3

    var displayName: String {
        switch self {
        case .seed: return "Seed"
        case .sprout: return "Sprout"
        case .bloom: return "Bloom"
        case .tree: return "Tree"
        }
    }

    var symbolName: String {
        switch self {
        case .seed: return "leaf"
        case .sprout: return "leaf.fill"
        case .bloom: return "flower.fill"
        case .tree: return "tree.fill"
        }
    }
}
