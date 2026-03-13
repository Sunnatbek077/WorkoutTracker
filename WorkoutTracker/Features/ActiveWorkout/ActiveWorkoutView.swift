//
//  ActiveWorkoutView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct ActiveWorkoutView: View {

    @EnvironmentObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showStopConfirm = false
    @State private var showSummary = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Header
                header
                    .padding(.horizontal)
                    .padding(.top, 16)

                Spacer()

                // MARK: - HR + Progress Ring
                HStack(alignment: .center, spacing: 24) {
                    HeartRateView(
                        heartRate: viewModel.metrics.heartRate,
                        zone: viewModel.heartRateZone
                    )

                    ProgressRingView(
                        progress: viewModel.progress,
                        color: viewModel.workoutType?.color ?? .orange
                    )
                }
                .padding(.horizontal, 24)
                .opacity(viewModel.isPaused ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isPaused)

                Spacer()

                // MARK: - Metrikalar
                metricsGrid
                    .padding(.horizontal, 16)
                    .opacity(viewModel.isPaused ? 0.4 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isPaused)

                Spacer()

                // MARK: - Kontrollar
                WorkoutControlsView(
                    status: viewModel.status,
                    onPause: { viewModel.pauseWorkout() },
                    onResume: { viewModel.resumeWorkout() },
                    onStop: { showStopConfirm = true }
                )
                .padding(.bottom, 40)
            }

            // MARK: - LiveActivity badge
            if viewModel.liveActivityActive {
                VStack {
                    liveActivityBadge
                        .padding(.top, 8)
                    Spacer()
                }
            }
        }
        .confirmationDialog(
            "Mashqni to'xtatish",
            isPresented: $showStopConfirm,
            titleVisibility: .visible
        ) {
            Button("To'xtat", role: .destructive) {
                Task {
                    await viewModel.stopWorkout()
                    showSummary = true
                }
            }
            Button("Bekor qilish", role: .cancel) {}
        } message: {
            Text("Mashqni to'xtatib natijani saqlaysizmi?")
        }
        .fullScreenCover(isPresented: $showSummary, onDismiss: {
            dismiss()
        }) {
            SummaryView()
                .environmentObject(viewModel)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: viewModel.workoutType?.icon ?? "figure.run")
                    .foregroundStyle(viewModel.workoutType?.color ?? .orange)
                Text(viewModel.workoutType?.displayName ?? "")
                    .font(.system(.headline, design: .rounded))
            }

            Spacer()

            if viewModel.isPaused {
                HStack(spacing: 4) {
                    Image(systemName: "pause.fill")
                        .font(.caption2)
                    Text("Pauza")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.orange.opacity(0.15))
                .clipShape(Capsule())
                .transition(.scale.combined(with: .opacity))
            }

            Text(viewModel.metrics.formattedTime)
                .font(.system(.title2, design: .monospaced, weight: .semibold))
                .foregroundStyle(viewModel.isPaused ? .secondary : .primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .animation(.spring(duration: 0.3), value: viewModel.isPaused)
    }

    // MARK: - Metrikalar
    private var metricsGrid: some View {
        HStack(spacing: 12) {
            MetricCard(
                icon: "flame.fill",
                value: viewModel.metrics.formattedCalories,
                unit: "kcal",
                color: .orange
            )
            MetricCard(
                icon: "figure.walk",
                value: viewModel.metrics.formattedSteps,
                unit: "qadam",
                color: .green
            )
            MetricCard(
                icon: "speedometer",
                value: viewModel.metrics.formattedPace,
                unit: "/km",
                color: .blue
            )
        }
    }

    // MARK: - LiveActivity badge
    private var liveActivityBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(.green)
                .frame(width: 6, height: 6)
            Text("Lock Screen da ko'rinmoqda")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    ActiveWorkoutView()
        .environmentObject(WorkoutViewModel(
            healthKitManager: MockHealthKitManager(),
            timerManager: WorkoutTimerManager(),
            liveActivityManager: LiveActivityManager()
        ))
}
