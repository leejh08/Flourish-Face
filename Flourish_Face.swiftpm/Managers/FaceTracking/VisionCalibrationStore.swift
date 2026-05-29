import Foundation
import VisionCore

final class VisionCalibrationStore {
    private static let defaultsKey = "visionNeutralBaseline_v1"

    var hasCalibration: Bool {
        UserDefaults.standard.data(forKey: Self.defaultsKey) != nil
    }

    func load() -> VisionNeutralBaseline {
        guard
            let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
            let baseline = try? JSONDecoder().decode(VisionNeutralBaseline.self, from: data)
        else { return .default }
        return baseline
    }

    func save(_ baseline: VisionNeutralBaseline) {
        guard let data = try? JSONEncoder().encode(baseline) else { return }
        UserDefaults.standard.set(data, forKey: Self.defaultsKey)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
    }
}
