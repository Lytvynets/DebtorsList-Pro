

import SwiftUI

struct DonutChartView: View {

    let values: [Double]
    let colors: [Color]
    let lineWidth: CGFloat

    init(values: [Double], colors: [Color], lineWidth: CGFloat = 22) {
        self.values = values
        self.colors = colors
        self.lineWidth = lineWidth
    }

    private var total: Double {
        values.reduce(0, +)
    }

    var body: some View {
        ZStack {
            if total <= 0 {
                Circle()
                    .stroke(AppTheme.divider, lineWidth: lineWidth)
            } else {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    let range = segmentRange(at: index)
                    Circle()
                        .trim(from: range.start, to: range.end)
                        .stroke(
                            colors[index % colors.count],
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }


    private func segmentRange(at index: Int) -> (start: Double, end: Double) {
        let before = values.prefix(index).reduce(0, +)
        let rawStart = before / total
        let rawEnd = (before + values[index]) / total

        let gap = values.count > 1 ? 0.006 : 0.0
        let start = rawStart + gap / 2
        let end = max(start, rawEnd - gap / 2)
        return (start, end)
    }
}
