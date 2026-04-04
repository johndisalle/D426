import SwiftUI

struct RadarChartView: View {
    let data: [(label: String, value: Double)]
    let maxValue: Double
    let color: Color

    init(data: [(String, Double)], maxValue: Double = 100, color: Color = .blue) {
        self.data = data.map { (label: $0.0, value: $0.1) }
        self.maxValue = maxValue
        self.color = color
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2.5

            ZStack {
                // Grid rings
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    PolygonShape(sides: data.count, scale: scale)
                        .stroke(.gray.opacity(0.2), lineWidth: 0.5)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }

                // Grid lines from center
                ForEach(0..<data.count, id: \.self) { i in
                    let angle = angleFor(index: i)
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: pointAt(center: center, radius: radius, angle: angle))
                    }
                    .stroke(.gray.opacity(0.15), lineWidth: 0.5)
                }

                // Data polygon
                Path { path in
                    for (i, item) in data.enumerated() {
                        let scale = item.value / maxValue
                        let angle = angleFor(index: i)
                        let point = pointAt(center: center, radius: radius * scale, angle: angle)
                        if i == 0 { path.move(to: point) }
                        else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                }
                .fill(color.opacity(0.2))

                Path { path in
                    for (i, item) in data.enumerated() {
                        let scale = item.value / maxValue
                        let angle = angleFor(index: i)
                        let point = pointAt(center: center, radius: radius * scale, angle: angle)
                        if i == 0 { path.move(to: point) }
                        else { path.addLine(to: point) }
                    }
                    path.closeSubpath()
                }
                .stroke(color, lineWidth: 2)

                // Data points
                ForEach(0..<data.count, id: \.self) { i in
                    let scale = data[i].value / maxValue
                    let angle = angleFor(index: i)
                    let point = pointAt(center: center, radius: radius * scale, angle: angle)
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                        .position(point)
                }

                // Labels
                ForEach(0..<data.count, id: \.self) { i in
                    let angle = angleFor(index: i)
                    let point = pointAt(center: center, radius: radius + 30, angle: angle)
                    Text(data[i].label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(width: 70)
                        .position(point)
                }
            }
        }
    }

    private func angleFor(index: Int) -> Double {
        let slice = (2 * .pi) / Double(data.count)
        return slice * Double(index) - .pi / 2
    }

    private func pointAt(center: CGPoint, radius: Double, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }
}

struct PolygonShape: Shape {
    let sides: Int
    let scale: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale

        for i in 0..<sides {
            let angle = (2 * .pi / Double(sides)) * Double(i) - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
