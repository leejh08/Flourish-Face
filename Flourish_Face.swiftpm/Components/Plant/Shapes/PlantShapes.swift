import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.addEllipse(in: CGRect(x: 0, y: h * 0.3, width: w * 0.4, height: h * 0.7))
        path.addEllipse(in: CGRect(x: w * 0.2, y: 0, width: w * 0.5, height: h))
        path.addEllipse(in: CGRect(x: w * 0.5, y: h * 0.2, width: w * 0.5, height: h * 0.8))
        return path
    }
}

struct GrassEdgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))

        let heights: [CGFloat] = [0.7, 0.5, 0.9, 0.6, 0.8, 0.5, 0.75, 0.6, 0.85, 0.55, 0.7, 0.65]
        let segments = heights.count
        let segWidth = rect.width / CGFloat(segments)
        for i in 0..<segments {
            let x = CGFloat(i) * segWidth
            let peakY = rect.maxY - rect.height * heights[i]
            path.addQuadCurve(
                to: CGPoint(x: x + segWidth, y: rect.maxY),
                control: CGPoint(x: x + segWidth / 2, y: peakY)
            )
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct GrassBlade: Shape {
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + 2, y: rect.maxY - height),
            control: CGPoint(x: rect.midX - 3, y: rect.midY)
        )
        return path
    }
}

struct TrunkShape: Shape {
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomWidth: CGFloat = rect.width
        let topWidth: CGFloat = rect.width * 0.6

        path.move(to: CGPoint(x: rect.midX - bottomWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - topWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + topWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + bottomWidth / 2, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}
