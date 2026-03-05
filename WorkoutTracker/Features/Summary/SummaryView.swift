//
//  SummaryView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct SummaryView: View {

    @EnvironmentObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Header
                    summaryHeader

                    // MARK: - Asosiy statistika
                    statsSection

                    // MARK: - HR grafik
                    HeartRateChartView(dataPoints: viewModel.heartRateDataPoints)
                        .padding(.horizontal)

                    // MARK: - Maqsad natijasi
                    goalResultSection

                    // MARK: - Tugmalar
                    actionButtons
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Natija")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Yopish") {
                        viewModel.resetWorkout()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header
    private var summaryHeader: some View {
        VStack(spacing: 12) {
            // Mashq icon
            ZStack {
                Circle()
                    .fill(workoutColor.opacity(0.15))
                    .frame(width: 90, height: 90)

                Image(systemName: workoutIcon)
                    .font(.system(size: 40))
                    .foregroundStyle(workoutColor)
            }

            Text("Mashq tugadi!")
                .font(.system(.title2, design: .rounded, weight: .bold))

            Text(viewModel.session?.startTime.workoutDate ?? "")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 16)
    }

    // MARK: - Statistika
    private var statsSection: some View {
        VStack(spacing: 0) {
            StatRow(
                icon: "timer",
                title: "Jami vaqt",
                value: viewModel.formattedTotalDuration,
                color: .blue
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "flame.fill",
                title: "Kaloriya",
                value: viewModel.metrics.formattedCalories,
                color: .orange
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "heart.fill",
                title: "O'rtacha HR",
                value: "\(viewModel.averageHeartRate) bpm",
                color: .red
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "heart.circle.fill",
                title: "Maks HR",
                value: "\(viewModel.maxHeartRate) bpm",
                color: .red
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "figure.walk",
                title: "Qadam",
                value: viewModel.metrics.formattedSteps,
                color: .green
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "speedometer",
                title: "O'rtacha temp",
                value: viewModel.metrics.formattedPace,
                color: .blue
            )
            Divider().padding(.leading, 54)

            StatRow(
                icon: "map.fill",
                title: "Masofa",
                value: viewModel.metrics.formattedDistance,
                color: .purple
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // MARK: - Maqsad natijasi
    private var goalResultSection: some View {
        HStack(spacing: 16) {
            // Progress ring (kichik)
            ProgressRingView(
                progress: viewModel.progress,
                color: workoutColor,
                lineWidth: 10,
                size: 80
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isGoalReached ? "🎯 Maqsadga yetildi!" : "Maqsad bajarilishi")
                    .font(.system(.headline, design: .rounded))

                Text("\(Int(viewModel.progress * 100))% — \(viewModel.goalDescription)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    // MARK: - Tugmalar
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Yangi mashq
            Button {
                viewModel.resetWorkout()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Yangi mashq")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(workoutColor)
                )
            }

            // HealthKit ga saqlash (hozircha disabled — keyingi bosqich)
            Button {
                // TODO: HealthKit ga saqlash
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.square.fill")
                    Text("Sog'liqqa saqlash")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(workoutColor)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(workoutColor.opacity(0.12))
                )
            }
        }
    }

    // MARK: - Helpers
    private var workoutColor: Color {
        viewModel.workoutType?.color ?? .orange
    }

    private var workoutIcon: String {
        viewModel.workoutType?.icon ?? "figure.run"
    }
}

#Preview {
    SummaryView()
        .environmentObject(WorkoutViewModel(
            healthKitManager: MockHealthKitManager(),
            timerManager: WorkoutTimerManager(),
            liveActivityManager: LiveActivityManager()
        ))
}
