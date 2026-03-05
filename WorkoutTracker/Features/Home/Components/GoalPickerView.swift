//
//  GoalPickerView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct GoalPickerView: View {

    @Binding var goal: WorkoutGoal

    // Local state
    @State private var goalType: GoalType = .calories
    @State private var calorieTarget: Int = 300
    @State private var durationMinutes: Int = 30

    enum GoalType: String, CaseIterable {
        case calories = "Kaloriya"
        case duration = "Vaqt"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Sarlavha
            Text("Maqsad")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)

            // Toggle
            Picker("Maqsad turi", selection: $goalType) {
                ForEach(GoalType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: goalType) { _ in updateGoal() }

            // Miqdor
            HStack {
                if goalType == .calories {
                    CalorieStepperView(value: $calorieTarget)
                        .onChange(of: calorieTarget) { _ in updateGoal() }
                } else {
                    DurationStepperView(value: $durationMinutes)
                        .onChange(of: durationMinutes) { _ in updateGoal() }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func updateGoal() {
        switch goalType {
        case .calories:
            goal = .calories(target: calorieTarget)
        case .duration:
            goal = .duration(second: durationMinutes * 60)
        }
    }
}

// MARK: - Kaloriya Stepper
struct CalorieStepperView: View {
    @Binding var value: Int
    private let step = 50
    private let range = 100...1000

    var body: some View {
        HStack {
            Button {
                if value - step >= range.lowerBound { value -= step }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if value + step <= range.upperBound { value += step }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Davomiylik Stepper
struct DurationStepperView: View {
    @Binding var value: Int
    private let step = 5
    private let range = 5...120

    var body: some View {
        HStack {
            Button {
                if value - step >= range.lowerBound { value -= step }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text("daqiqa")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if value + step <= range.upperBound { value += step }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 8)
    }
}
