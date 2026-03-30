import Foundation
import SwiftData

@Model
class Flower {
    var id: UUID
    var type: FlowerType
    var earnedDate: Date

    init(type: FlowerType, earnedDate: Date = .now) {
        self.id = UUID()
        self.type = type
        self.earnedDate = earnedDate
    }
}
