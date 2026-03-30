import SwiftUI

struct ExpressionGuidePath: Shape {
    let exercise: FaceExercise
    let geoSize: CGSize

    func path(in rect: CGRect) -> Path {
        let centerX = geoSize.width / 2
        var path = Path()

        switch exercise {
        case .browRaise:
            let browY = geoSize.height * 0.32
            let browWidth: CGFloat = geoSize.width * 0.12

            let leftBrowX = centerX - geoSize.width * 0.08
            path.move(to: CGPoint(x: leftBrowX - browWidth / 2, y: browY))
            path.addQuadCurve(
                to: CGPoint(x: leftBrowX + browWidth / 2, y: browY),
                control: CGPoint(x: leftBrowX, y: browY - 14)
            )

            let rightBrowX = centerX + geoSize.width * 0.12
            path.move(to: CGPoint(x: rightBrowX - browWidth / 2, y: browY))
            path.addQuadCurve(
                to: CGPoint(x: rightBrowX + browWidth / 2, y: browY),
                control: CGPoint(x: rightBrowX, y: browY - 14)
            )

        case .smile:
            let mouthY = geoSize.height * 0.52
            let startX = centerX + 4
            let endX = centerX + geoSize.width * 0.18

            path.move(to: CGPoint(x: startX, y: mouthY - 6))
            path.addQuadCurve(
                to: CGPoint(x: endX, y: mouthY - 3),
                control: CGPoint(x: (startX + endX) / 2, y: mouthY - 10)
            )

            path.move(to: CGPoint(x: startX, y: mouthY + 6))
            path.addQuadCurve(
                to: CGPoint(x: endX, y: mouthY + 3),
                control: CGPoint(x: (startX + endX) / 2, y: mouthY + 10)
            )

            path.move(to: CGPoint(x: endX, y: mouthY - 3))
            path.addQuadCurve(
                to: CGPoint(x: endX, y: mouthY + 3),
                control: CGPoint(x: endX + 4, y: mouthY)
            )

        case .eyeClosure:
            let eyeY = geoSize.height * 0.38
            let eyeWidth: CGFloat = geoSize.width * 0.10

            let leftEyeX = centerX - geoSize.width * 0.08
            path.move(to: CGPoint(x: leftEyeX - eyeWidth, y: eyeY))
            path.addQuadCurve(
                to: CGPoint(x: leftEyeX + eyeWidth, y: eyeY),
                control: CGPoint(x: leftEyeX, y: eyeY + 8)
            )
            path.move(to: CGPoint(x: leftEyeX - eyeWidth, y: eyeY))
            path.addQuadCurve(
                to: CGPoint(x: leftEyeX + eyeWidth, y: eyeY),
                control: CGPoint(x: leftEyeX, y: eyeY - 8)
            )

            let rightEyeX = centerX + geoSize.width * 0.12
            path.move(to: CGPoint(x: rightEyeX - eyeWidth, y: eyeY))
            path.addQuadCurve(
                to: CGPoint(x: rightEyeX + eyeWidth, y: eyeY),
                control: CGPoint(x: rightEyeX, y: eyeY + 8)
            )
            path.move(to: CGPoint(x: rightEyeX - eyeWidth, y: eyeY))
            path.addQuadCurve(
                to: CGPoint(x: rightEyeX + eyeWidth, y: eyeY),
                control: CGPoint(x: rightEyeX, y: eyeY - 8)
            )

        case .jawOpen:
            let mouthY = geoSize.height * 0.52
            let mouthCenterX = centerX + geoSize.width * 0.02
            let radiusX: CGFloat = geoSize.width * 0.08
            let radiusY: CGFloat = geoSize.width * 0.10

            path.addEllipse(in: CGRect(
                x: mouthCenterX - radiusX,
                y: mouthY - radiusY / 2,
                width: radiusX * 2,
                height: radiusY * 2
            ))

        case .mouthFrown:
            let mouthY = geoSize.height * 0.53
            let mouthCenterX = centerX + geoSize.width * 0.02

            let leftX = mouthCenterX - geoSize.width * 0.12
            let rightX = mouthCenterX + geoSize.width * 0.12

            path.move(to: CGPoint(x: leftX, y: mouthY + 10))
            path.addQuadCurve(
                to: CGPoint(x: mouthCenterX, y: mouthY),
                control: CGPoint(x: (leftX + mouthCenterX) / 2, y: mouthY + 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: rightX, y: mouthY + 10),
                control: CGPoint(x: (mouthCenterX + rightX) / 2, y: mouthY + 2)
            )
        }

        return path
    }
}
