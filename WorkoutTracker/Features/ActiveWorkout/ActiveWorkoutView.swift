//
//  ActiveWorkoutView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct ActiveWorkoutView: View {

    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var showStopConfirm = false
    @State private var showSummary = false

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground).ignoresSafeArea()

            // MARK: - Asosiy kontent
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 16)

                Spacer()

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

                Spacer()

                metricsGrid
                    .padding(.horizontal, 16)

                Spacer()

                WorkoutControlsView(
                    status: viewModel.status,
                    onPause: { viewModel.pauseWorkout() },
                    onResume: { viewModel.resumeWorkout() },
                    onStop: { showStopConfirm = true }
                )
                .padding(.bottom, 40)
            }

            // MARK: - Pauza overlay (ZStack ichida — gesture'larni bloklamaydi)
            if viewModel.isPaused {
                pausedOverlay
            }

            // MARK: - LiveActivity badge (yuqorida)
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
        .fullScreenCover(isPresented: $showSummary) {
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

            Text(viewModel.metrics.formattedTime)
                .font(.system(.title2, design: .monospaced, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
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

    // MARK: - Pauza overlay
    private var pausedOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 12) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)

                Text("Pauza")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text(viewModel.metrics.formattedTime)
                    .font(.system(.title3, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .allowsHitTesting(false)
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
