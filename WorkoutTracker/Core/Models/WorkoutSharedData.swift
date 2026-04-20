//
//  WorkoutSharedData.swift
//  WorkoutTracker
//
//  App Groups orqali widget extension bilan ma'lumot almashish.
//
//  SETUP: Xcode → Targets → WorkoutTracker (va WorkoutWidgetExtension) →
//  Signing & Capabilities → + Capability → App Groups →
//  group.com.sunnatbek.WorkoutTracker ni qo'shing.
//

import Foundation
import WidgetKit

// MARK: - App Group constants
let kWorkoutAppGroupID = "group.com.sunnatbek.WorkoutTracker"
let kWorkoutWidgetDataKey = "workout_widget_data"

// MARK: - Shared Data Model
// NOTE: Bu struct WorkoutHomeWidget.swift dagi bilan bir xil bo'lishi kerak
struct WorkoutWidgetData: Codable {
    var lastWorkoutType: String     = ""
    var lastWorkoutDate: Date       = .distantPast
    var lastCalories: Double        = 0
    var lastDurationSeconds: Int    = 0
    var lastDistanceKM: Double      = 0
    var lastSteps: Int              = 0
    var lastHeartRate: Int          = 0
    var todayCalories: Double       = 0
    var todaySteps: Int             = 0
    var todayActiveMinutes: Int     = 0
    var weeklyWorkoutCount: Int     = 0
    var dailyCalorieGoal: Int       = 500
    var dailyGoalType: String       = "calories"
}

// MARK: - Widget Data Manager (main app, write-side)
final class WorkoutWidgetDataManager {
    static let shared = WorkoutWidgetDataManager()

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: kWorkoutAppGroupID)
    }

    // MARK: - Mashq tugagach saqlash
    func saveWorkout(session: WorkoutSession, metrics: WorkoutMetrics) {
        var data = loadCurrentData()
        resetDailyStatsIfNeeded(&data)

        data.lastWorkoutType     = session.type.displayName
        data.lastWorkoutDate     = Date()
        data.lastCalories        = metrics.calories
        data.lastDurationSeconds = metrics.elapsedSeconds
        data.lastDistanceKM      = metrics.distanceKM
        data.lastSteps           = metrics.steps
        data.lastHeartRate       = metrics.heartRate
        data.todayCalories       += metrics.calories
        data.todaySteps          += metrics.steps
        data.todayActiveMinutes  += metrics.elapsedSeconds / 60
        data.weeklyWorkoutCount  += 1

        switch session.goal {
        case .calories(let target):
            data.dailyCalorieGoal = target
            data.dailyGoalType    = "calories"
        case .duration:
            data.dailyGoalType    = "duration"
        }

        persist(data)

        // Widget timelineni yangilash
        WidgetCenter.shared.reloadTimelines(ofKind: "WorkoutHomeWidget")
    }

    // MARK: - Private helpers
    private func loadCurrentData() -> WorkoutWidgetData {
        guard let defaults,
              let raw     = defaults.data(forKey: kWorkoutWidgetDataKey),
              let decoded = try? JSONDecoder().decode(WorkoutWidgetData.self, from: raw)
        else { return WorkoutWidgetData() }
        return decoded
    }

    private func persist(_ data: WorkoutWidgetData) {
        guard let defaults,
              let encoded = try? JSONEncoder().encode(data) else { return }
        defaults.set(encoded, forKey: kWorkoutWidgetDataKey)
    }

    // Yangi kun bo'lsa — kunlik statistikani nolga tushirish
    private func resetDailyStatsIfNeeded(_ data: inout WorkoutWidgetData) {
        guard data.lastWorkoutDate != .distantPast,
              !Calendar.current.isDateInToday(data.lastWorkoutDate)
        else { return }

        data.todayCalories      = 0
        data.todaySteps         = 0
        data.todayActiveMinutes = 0

        // Dushanba kuni haftalik hisobni nolga tushirish
        let weekday = Calendar.current.component(.weekday, from: Date())
        if weekday == 2 { data.weeklyWorkoutCount = 0 }
    }
}
