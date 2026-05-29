import XCTest
@testable import VisionCore

final class VisionBlendShapeCalculatorTests: XCTestCase {

    private let calculator = VisionBlendShapeCalculator(baseline: .default)

    // MARK: - Helpers

    private func geometry(
        leftBrowToEye: Double = 0.10, rightBrowToEye: Double = 0.10,
        leftEAR: Double = 0.28, rightEAR: Double = 0.28,
        leftCornerDisp: Double = 0.19, rightCornerDisp: Double = 0.19,
        innerLipsOpen: Double = 0.02,
        leftCornerDrop: Double = 0.0, rightCornerDrop: Double = 0.0
    ) -> VisionGeometry {
        VisionGeometry(
            leftBrowToEyeRatio: leftBrowToEye,
            rightBrowToEyeRatio: rightBrowToEye,
            leftEyeAspectRatio: leftEAR,
            rightEyeAspectRatio: rightEAR,
            leftMouthCornerDisplacement: leftCornerDisp,
            rightMouthCornerDisplacement: rightCornerDisp,
            innerLipsOpenRatio: innerLipsOpen,
            leftMouthCornerDrop: leftCornerDrop,
            rightMouthCornerDrop: rightCornerDrop,
            faceHeight: 0.8,
            faceWidth: 0.6
        )
    }

    // MARK: - browRaise

    func test_browRaise_atBaseline_returnsZero() {
        let result = calculator.measurement(from: geometry(leftBrowToEye: 0.10, rightBrowToEye: 0.10))
        XCTAssertEqual(result.browInnerUp, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.browOuterUpLeft, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.browOuterUpRight, 0.0, accuracy: 0.01)
    }

    func test_browRaise_atMaximum_returnsOne() {
        // baseline=0.10, max = baseline + baseline*0.8 = 0.18
        let result = calculator.measurement(from: geometry(leftBrowToEye: 0.18, rightBrowToEye: 0.18))
        XCTAssertEqual(result.browInnerUp, 1.0, accuracy: 0.01)
    }

    func test_browRaise_atHalfway_returnsHalf() {
        // halfway = 0.10 + 0.04 = 0.14
        let result = calculator.measurement(from: geometry(leftBrowToEye: 0.14, rightBrowToEye: 0.14))
        XCTAssertEqual(result.browInnerUp, 0.5, accuracy: 0.05)
    }

    func test_browRaise_leftAndRightAreIndependent() {
        let result = calculator.measurement(from: geometry(leftBrowToEye: 0.18, rightBrowToEye: 0.10))
        XCTAssertEqual(result.browOuterUpLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.browOuterUpRight, 0.0, accuracy: 0.01)
    }

    func test_browRaise_belowBaseline_clampedToZero() {
        let result = calculator.measurement(from: geometry(leftBrowToEye: 0.05))
        XCTAssertEqual(result.browOuterUpLeft, 0.0, accuracy: 0.001)
    }

    // MARK: - eyeBlink

    func test_eyeBlink_atOpenBaseline_returnsZero() {
        let result = calculator.measurement(from: geometry(leftEAR: 0.28, rightEAR: 0.28))
        XCTAssertEqual(result.eyeBlinkLeft, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.eyeBlinkRight, 0.0, accuracy: 0.01)
    }

    func test_eyeBlink_whenClosed_returnsOne() {
        let result = calculator.measurement(from: geometry(leftEAR: 0.0, rightEAR: 0.0))
        XCTAssertEqual(result.eyeBlinkLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.eyeBlinkRight, 1.0, accuracy: 0.01)
    }

    func test_eyeBlink_atHalfway_returnsHalf() {
        let result = calculator.measurement(from: geometry(leftEAR: 0.14, rightEAR: 0.14))
        XCTAssertEqual(result.eyeBlinkLeft, 0.5, accuracy: 0.05)
    }

    func test_eyeBlink_leftAndRightAreIndependent() {
        let result = calculator.measurement(from: geometry(leftEAR: 0.0, rightEAR: 0.28))
        XCTAssertEqual(result.eyeBlinkLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.eyeBlinkRight, 0.0, accuracy: 0.01)
    }

    func test_eyeBlink_aboveBaseline_clampedToZero() {
        let result = calculator.measurement(from: geometry(leftEAR: 0.40))
        XCTAssertEqual(result.eyeBlinkLeft, 0.0, accuracy: 0.001)
    }

    // MARK: - jawOpen

    func test_jawOpen_atBaseline_returnsZero() {
        let result = calculator.measurement(from: geometry(innerLipsOpen: 0.02))
        XCTAssertEqual(result.jawOpen, 0.0, accuracy: 0.01)
    }

    func test_jawOpen_atMaximum_returnsOne() {
        // baseline=0.02, max = 0.02 + 0.15 = 0.17
        let result = calculator.measurement(from: geometry(innerLipsOpen: 0.17))
        XCTAssertEqual(result.jawOpen, 1.0, accuracy: 0.01)
    }

    func test_jawOpen_atHalfway_returnsHalf() {
        // halfway = 0.02 + 0.075 = 0.095
        let result = calculator.measurement(from: geometry(innerLipsOpen: 0.095))
        XCTAssertEqual(result.jawOpen, 0.5, accuracy: 0.05)
    }

    func test_jawOpen_belowBaseline_clampedToZero() {
        let result = calculator.measurement(from: geometry(innerLipsOpen: 0.0))
        XCTAssertEqual(result.jawOpen, 0.0, accuracy: 0.001)
    }

    // MARK: - smile

    func test_smile_atBaseline_returnsZero() {
        let result = calculator.measurement(from: geometry(leftCornerDisp: 0.19, rightCornerDisp: 0.19))
        XCTAssertEqual(result.mouthSmileLeft, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthSmileRight, 0.0, accuracy: 0.01)
    }

    func test_smile_atMaximum_returnsOne() {
        // baseline=0.19, max = 0.19 + 0.08 = 0.27
        let result = calculator.measurement(from: geometry(leftCornerDisp: 0.27, rightCornerDisp: 0.27))
        XCTAssertEqual(result.mouthSmileLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthSmileRight, 1.0, accuracy: 0.01)
    }

    func test_smile_leftAndRightAreIndependent() {
        let result = calculator.measurement(from: geometry(leftCornerDisp: 0.27, rightCornerDisp: 0.19))
        XCTAssertEqual(result.mouthSmileLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthSmileRight, 0.0, accuracy: 0.01)
    }

    func test_smile_belowBaseline_clampedToZero() {
        let result = calculator.measurement(from: geometry(leftCornerDisp: 0.10))
        XCTAssertEqual(result.mouthSmileLeft, 0.0, accuracy: 0.001)
    }

    // MARK: - mouthFrown

    func test_mouthFrown_atBaseline_returnsZero() {
        let result = calculator.measurement(from: geometry(leftCornerDrop: 0.0, rightCornerDrop: 0.0))
        XCTAssertEqual(result.mouthFrownLeft, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthFrownRight, 0.0, accuracy: 0.01)
    }

    func test_mouthFrown_atMaximum_returnsOne() {
        // max drop = 0.06
        let result = calculator.measurement(from: geometry(leftCornerDrop: 0.06, rightCornerDrop: 0.06))
        XCTAssertEqual(result.mouthFrownLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthFrownRight, 1.0, accuracy: 0.01)
    }

    func test_mouthFrown_leftAndRightAreIndependent() {
        let result = calculator.measurement(from: geometry(leftCornerDrop: 0.06, rightCornerDrop: 0.0))
        XCTAssertEqual(result.mouthFrownLeft, 1.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthFrownRight, 0.0, accuracy: 0.01)
    }

    func test_mouthFrown_negativeValue_clampedToZero() {
        let result = calculator.measurement(from: geometry(leftCornerDrop: -0.02))
        XCTAssertEqual(result.mouthFrownLeft, 0.0, accuracy: 0.001)
    }

    // MARK: - neutralGeometry produces all zeros

    func test_neutralGeometry_allValuesNearZero() {
        let neutral = VisionGeometry.neutral(baseline: .default)
        let result = calculator.measurement(from: neutral)
        XCTAssertEqual(result.browInnerUp,     0.0, accuracy: 0.01)
        XCTAssertEqual(result.eyeBlinkLeft,    0.0, accuracy: 0.01)
        XCTAssertEqual(result.eyeBlinkRight,   0.0, accuracy: 0.01)
        XCTAssertEqual(result.jawOpen,         0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthSmileLeft,  0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthSmileRight, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthFrownLeft,  0.0, accuracy: 0.01)
        XCTAssertEqual(result.mouthFrownRight, 0.0, accuracy: 0.01)
    }
}
