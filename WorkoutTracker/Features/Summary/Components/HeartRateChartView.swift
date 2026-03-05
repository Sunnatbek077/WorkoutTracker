//
//  HeartRateChartView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI
import Charts

struct HeartRateChartView: View {
    let dataPoints: [(time: Int, hr: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Yurak urishi grafigi")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)

            if dataPoints.isEmpty {
                // Ma'lumot yo'q holat
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 120)
                    .overlay(
                        Text("Ma'lumot yetarli emas")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    )
            } else {
                Chart(dataPoints, id: \.time) { point in
                    LineMark(
                        x: .value("Vaqt", point.time),
                        y: .value("HR", point.hr)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Vaqt", point.time),
                        y: .value("HR", point.hr)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartXAxis(.hidden)
                .chartYScale(domain: hrRange)
                .frame(height: 120)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var hrRange: ClosedRange<Int> {
        let values = dataPoints.map { $0.hr }
        let min = (values.min() ?? 60) - 10
        let max = (values.max() ?? 180) + 10
        return min...max
    }
}
