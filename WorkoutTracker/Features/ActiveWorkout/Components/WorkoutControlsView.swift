//
//  WorkoutControlsView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct WorkoutControlsView: View {
    let status: WorkoutStatus
    let onPause: () -> Void
    let onResume: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            // Stop tugmasi
            ControlButton(
                icon: "stop.fill",
                label: "To'xtat",
                color: .red,
                action: onStop
            )

            // Pause / Resume tugmasi
            if status == .active {
                ControlButton(
                    icon: "pause.fill",
                    label: "Pauza",
                    color: .orange,
                    action: onPause
                )
            } else {
                ControlButton(
                    icon: "play.fill",
                    label: "Davom et",
                    color: .green,
                    action: onResume
                )
            }
        }
    }
}

// MARK: - Yordamchi tugma
struct ControlButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 72, height: 72)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
