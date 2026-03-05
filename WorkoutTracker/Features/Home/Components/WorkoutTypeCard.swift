//
//  WorkoutTypeCard.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct WorkoutTypeCard: View {
    let type: WorkoutType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: type.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(isSelected ? .white : type.color)

                Text(type.displayName)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100) // ← fixed height
            // WorkoutTypeCard.swift ichida
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                        ? type.color
                        : Color(.tertiarySystemBackground) // ← opacity emas
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.clear : type.color.opacity(0.4),
                                lineWidth: 1.5
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? type.color : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
