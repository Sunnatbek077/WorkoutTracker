//
//  WorkoutLiveActivityWidget.swift
//  WorkoutWidgetExtension
//
//  Created by Sunnatbek on 13/03/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Widget Entry Point
struct WorkoutLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in

            // MARK: - Lock Screen UI
            LockScreenLiveActivityView(
                attributes: context.attributes,
                state: context.state
            )
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {

                // MARK: - Expanded (bosganda)
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(
                        attributes: context.attributes,
                        state: context.state
                    )
                }

                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(state: context.state)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(
                        state: context.state,
                        attributes: context.attributes
                    )
                }

            } compactLeading: {
                // MARK: - Compact chap
                CompactLeadingView(attributes: context.attributes)

            } compactTrailing: {
                // MARK: - Compact o'ng
                CompactTrailingView(state: context.state)

            } minimal: {
                // MARK: - Minimal (boshqa app ham activity ishlatganda)
                MinimalView(state: context.state)
            }
            .keylineTint(workoutColor(for: context.attributes.workoutType))
        }
    }

    private func workoutColor(for type: String) -> Color {
        switch type {
        case "Running": return .orange
        case "Cycling": return .blue
        case "Walking": return .green
        default:        return .red
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenLiveActivityView: View {
    let attributes: WorkoutAttributes
    let state: WorkoutAttributes.ContentState

    var body: some View {
        VStack(spacing: 10) {

            // Header qator
            HStack {
                // Mashq turi
                Label(attributes.workoutType, systemImage: workoutIcon)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(state.isActive ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(state.isActive ? "Faol" : "Pauza")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.1))
                .clipShape(Capsule())
            }

            // Metrikalar
            HStack(spacing: 0) {
                LockScreenMetric(
                    icon: "heart.fill",
                    value: "\(state.heartRate)",
                    unit: "bpm",
                    color: .red
                )

                Divider()
                    .frame(height: 30)
                    .background(.white.opacity(0.3))

                LockScreenMetric(
                    icon: "flame.fill",
                    value: state.formattedCalories,
                    unit: "kcal",
                    color: .orange
                )

                Divider()
                    .frame(height: 30)
                    .background(.white.opacity(0.3))

                LockScreenMetric(
                    icon: "timer",
                    value: state.formattedTime,
                    unit: "",
                    color: .white
                )

                Divider()
                    .frame(height: 30)
                    .background(.white.opacity(0.3))

                LockScreenMetric(
                    icon: "figure.walk",
                    value: "\(state.steps)",
                    unit: "qadam",
                    color: .green
                )
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(state.isActive ? Color.green : Color.orange)
                        .frame(
                            width: geo.size.width * state.progress(targetCalories: attributes.targetCalories),
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.5), value: state.calories)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
    }

    private var workoutIcon: String {
        switch attributes.workoutType {
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Walking": return "figure.walk"
        default:        return "figure.highintensity.intervaltraining"
        }
    }
}

// MARK: - Lock Screen Metric
struct LockScreenMetric: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dynamic Island: Expanded Leading
struct ExpandedLeadingView: View {
    let attributes: WorkoutAttributes
    let state: WorkoutAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: workoutIcon)
                    .font(.caption2)
                    .foregroundStyle(workoutColor)
                Text(attributes.workoutType)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text(state.formattedTime)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.leading, 4)
    }

    private var workoutIcon: String {
        switch attributes.workoutType {
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Walking": return "figure.walk"
        default:        return "figure.highintensity.intervaltraining"
        }
    }

    private var workoutColor: Color {
        switch attributes.workoutType {
        case "Running": return .orange
        case "Cycling": return .blue
        case "Walking": return .green
        default:        return .red
        }
    }
}

// MARK: - Dynamic Island: Expanded Trailing
struct ExpandedTrailingView: View {
    let state: WorkoutAttributes.ContentState

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundStyle(.red)
                Text("\(state.heartRate)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("bpm")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.trailing, 4)
    }
}

// MARK: - Dynamic Island: Expanded Bottom
struct ExpandedBottomView: View {
    let state: WorkoutAttributes.ContentState
    let attributes: WorkoutAttributes

    var body: some View {
        VStack(spacing: 8) {

            // 3 ta metrika
            HStack {
                ExpandedMetric(
                    icon: "flame.fill",
                    value: state.formattedCalories,
                    unit: "kcal",
                    color: .orange
                )

                Spacer()

                ExpandedMetric(
                    icon: "figure.walk",
                    value: state.formattedSteps,
                    unit: "qadam",
                    color: .green
                )

                Spacer()

                ExpandedMetric(
                    icon: "speedometer",
                    value: state.formattedPace,
                    unit: "/km",
                    color: .blue
                )
            }
            .padding(.horizontal, 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(.white.opacity(0.15))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(state.isActive ? Color.green : Color.orange)
                        .frame(
                            width: geo.size.width * state.progress(targetCalories: attributes.targetCalories),
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.5), value: state.calories)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Expanded Metric
struct ExpandedMetric: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)

            Text(unit)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Dynamic Island: Compact Leading
struct CompactLeadingView: View {
    let attributes: WorkoutAttributes

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: workoutIcon)
                .font(.caption2)
                .foregroundStyle(workoutColor)

            Image(systemName: "heart.fill")
                .font(.system(size: 9))
                .foregroundStyle(.red)
        }
        .padding(.leading, 4)
    }

    private var workoutIcon: String {
        switch attributes.workoutType {
        case "Running": return "figure.run"
        case "Cycling": return "figure.outdoor.cycle"
        case "Walking": return "figure.walk"
        default:        return "figure.highintensity.intervaltraining"
        }
    }

    private var workoutColor: Color {
        switch attributes.workoutType {
        case "Running": return .orange
        case "Cycling": return .blue
        case "Walking": return .green
        default:        return .red
        }
    }
}

// MARK: - Dynamic Island: Compact Trailing
struct CompactTrailingView: View {
    let state: WorkoutAttributes.ContentState

    var body: some View {
        HStack(spacing: 2) {
            Text("\(state.heartRate)")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .contentTransition(.numericText())

            Text("bpm")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.trailing, 4)
    }
}

// MARK: - Dynamic Island: Minimal
struct MinimalView: View {
    let state: WorkoutAttributes.ContentState

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.caption2)
            .foregroundStyle(.red)
    }
}
