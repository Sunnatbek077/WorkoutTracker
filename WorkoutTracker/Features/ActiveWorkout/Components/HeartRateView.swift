//
//  HeartRateView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct HeartRateView: View {
    let heartRate: Int
    let zone: HeartRateZone

    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 8) {
            // Yurak animatsiyasi
            ZStack {
                // Pulse ring
                Circle()
                    .fill(zoneColor.opacity(0.15))
                    .frame(width: isPulsing ? 90 : 75)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: isPulsing
                    )

                Image(systemName: "heart.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(zoneColor)
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
            }
            .frame(width: 90, height: 90)

            // HR raqami
            Text("\(heartRate)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.4), value: heartRate)

            Text("bpm")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Zona badge
            Text(zone.label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(zoneColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(zoneColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .onAppear { isPulsing = true }
    }

    private var zoneColor: Color {
        switch zone {
        case .rest:     return .gray
        case .warmup:   return .blue
        case .fatBurn:  return .green
        case .cardio:   return .orange
        case .peak:     return .red
        }
    }
}
