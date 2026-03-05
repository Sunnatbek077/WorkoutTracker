//
//  HomeView.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var viewModel: WorkoutViewModel

    @State private var selectedType: WorkoutType = .running
    @State private var goal: WorkoutGoal = .calories(target: 300)
    @State private var showActiveWorkout = false
    @State private var showHealthKitAlert = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {

                    // MARK: - Scroll content
                    ScrollView {
                        VStack(spacing: 24) {
                            workoutTypeSection
                            GoalPickerView(goal: $goal)
                                .padding(.horizontal)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 80 + geometry.safeAreaInsets.bottom)
                    }

                    // MARK: - Pastga yopishtirilgan tugma
                    VStack(spacing: 0) {
                        startButton
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                    }
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("Yangi mashq")
            .navigationBarTitleDisplayMode(.large)
            .alert("HealthKit ruxsati", isPresented: $showHealthKitAlert) {
                Button("Sozlamalarga o'tish") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Bekor qilish", role: .cancel) {}
            } message: {
                Text("Yurak urishi va kaloriyani kuzatish uchun HealthKit ruxsati kerak.")
            }
            .fullScreenCover(isPresented: $showActiveWorkout) {
                ActiveWorkoutView()
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - Mashq turi
    private var workoutTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mashq turi")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    WorkoutTypeCard(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedType = type
                        }
                        goal = .calories(target: type.defaultTargetCalories)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Boshlash tugmasi
    private var startButton: some View {
        Button {
            handleStart()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                Text("Boshlash")
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedType.color)
            )
            .animation(.easeInOut(duration: 0.2), value: selectedType)
        }
        .disabled(viewModel.isInProgress)
    }

    // MARK: - Start logikasi
    private func handleStart() {
        Task {
            if !viewModel.isHealthKitAuthorized {
                await viewModel.requestHealthKitAuthorization()
            }

            guard viewModel.isHealthKitAuthorized else {
                showHealthKitAlert = true
                return
            }

            await viewModel.startWorkout(type: selectedType, goal: goal)
            showActiveWorkout = true
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutViewModel.makeDefault())
}
