//
//  ProgressRingView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double       // 0.0 → 1.0
    let color: Color
    var lineWidth: CGFloat = 14
    var size: CGFloat = 160

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: progress)

            // Foiz ko'rsatish
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.4), value: progress)

                Text("maqsad")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
