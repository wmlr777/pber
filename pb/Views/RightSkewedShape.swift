import SwiftUI

struct RightSkewedShape: Shape {
    var offset: CGFloat = 20
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0)) // Top-left straight
        path.addLine(to: CGPoint(x: rect.maxX, y: 0)) // Top-right straight
        path.addLine(to: CGPoint(x: rect.maxX - offset, y: rect.maxY)) // Bottom-right skewed
        path.addLine(to: CGPoint(x: 0, y: rect.maxY)) // Bottom-left straight
        path.closeSubpath()
        return path
    }
}
