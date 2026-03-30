import SwiftUI

enum FlowerType: String, Codable, CaseIterable {
    case rose = "rose"
    case tulip = "tulip"
    case sunflower = "sunflower"
    case daisy = "daisy"
    case cherry = "cherry"
    case lavender = "lavender"
    case hibiscus = "hibiscus"
    case lotus = "lotus"

    var emoji: String {
        switch self {
        case .rose: return "\u{1F339}"
        case .tulip: return "\u{1F337}"
        case .sunflower: return "\u{1F33B}"
        case .daisy: return "\u{1F33C}"
        case .cherry: return "\u{1F338}"
        case .lavender: return "\u{1FABB}"
        case .hibiscus: return "\u{1F33A}"
        case .lotus: return "\u{1FAB7}"
        }
    }

    var name: String {
        switch self {
        case .rose: return "Rose"
        case .tulip: return "Tulip"
        case .sunflower: return "Sunflower"
        case .daisy: return "Daisy"
        case .cherry: return "Cherry Blossom"
        case .lavender: return "Lavender"
        case .hibiscus: return "Hibiscus"
        case .lotus: return "Lotus"
        }
    }

    var color: Color {
        switch self {
        case .rose: return .flowerRose
        case .tulip: return .accentPink
        case .sunflower: return .accentAmber
        case .daisy: return .flowerDaisy
        case .cherry: return .flowerCherry
        case .lavender: return .flowerLavender
        case .hibiscus: return .flowerHibiscus
        case .lotus: return .pinkLight
        }
    }

    static func randomSelection(excluding collectedTypes: Set<FlowerType> = []) -> [FlowerType] {
        let all = FlowerType.allCases
        let uncollected = all.filter { !collectedTypes.contains($0) }.shuffled()
        let collected = all.filter { collectedTypes.contains($0) }.shuffled()

        let combined = uncollected + collected
        return Array(combined.prefix(3))
    }
}
