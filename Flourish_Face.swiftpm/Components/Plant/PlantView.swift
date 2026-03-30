import SwiftUI

struct PlantView: View {
    var growthRate: Double
    var animate: Bool = true

    var body: some View {
        GardenView(growthRate: growthRate, sessionCount: Int(growthRate * 10))
    }
}
