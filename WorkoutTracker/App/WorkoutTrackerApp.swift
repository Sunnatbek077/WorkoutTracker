//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import SwiftUI

@main
struct WorkoutTrackerApp: App {

    @StateObject private var workoutViewModel = WorkoutViewModel(
        healthKitManager: HealthKitManager(),
        timerManager: WorkoutTimerManager(),
        liveActivityManager: LiveActivityManager()
    )

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(workoutViewModel)  // ← shu kerak edi
                .task {
                    await workoutViewModel.liveActivityManager.cleanupStaleActivities()
                }
        }
    }
}
