//
//  WorkoutSession.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation
import ActivityKit

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let type: WorkoutType
    let goal: WorkoutGoal
    let startTime: Date

    var endTime: Date?
    var status: WorkoutStatus
    var currentMetrics: WorkoutMetrics

    // Grafik uchun tarix (har 5 sekundda snapshot)
    var metricsHistory: [MetricsSnapshot]

    // MARK: - Init
    init(type: WorkoutType, goal: WorkoutGoal) {
        self.id             = UUID()
        self.type           = type
        self.goal           = goal
        self.startTime      = Date()
        self.status         = .idle
        self.currentMetrics = WorkoutMetrics()
        self.metricsHistory = []
    }

    // MARK: - Computed: umumiy davomiylik
    var totalDuration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    // MARK: - Computed: progress (0.0 → 1.0)
    var progress: Double {
        goal.progress(
            calories: currentMetrics.calories,
            elapsedSeconds: currentMetrics.elapsedSeconds
        )
    }
}

// MARK: - Grafik uchun snapshot
struct MetricsSnapshot: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let heartRate: Int
    let calories: Double
    let elapsedSeconds: Int

    init(metrics: WorkoutMetrics) {
        self.id             = UUID()
        self.timestamp      = Date()
        self.heartRate      = metrics.heartRate
        self.calories       = metrics.calories
        self.elapsedSeconds = metrics.elapsedSeconds
    }
}

// MARK: - ActivityAttributes (Live Activity uchun)
struct WorkoutAttributes: ActivityAttributes {

    // Static: mashq boshida belgilanadi, o'zgarmaydi
    let workoutType: String
    let targetCalories: Int

    // Dynamic: real-vaqtda yangilanadi
    struct ContentState: Codable, Hashable {
        var heartRate: Int
        var calories: Double
        var elapsedSeconds: Int
        var pace: Double
        var steps: Int
        var status: String       // WorkoutStatus.rawValue

        // Formatlangan vaqt (Widget UI uchun)
        var formattedTime: String {
            let m = elapsedSeconds / 60
            let s = elapsedSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }

        // Progress (0.0 → 1.0)
        func progress(targetCalories: Int) -> Double {
            guard targetCalories > 0 else { return 0 }
            return min(calories / Double(targetCalories), 1.0)
        }
    }
}
