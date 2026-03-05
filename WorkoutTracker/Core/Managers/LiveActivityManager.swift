//
//  LiveActivityManager.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import ActivityKit
import Foundation
import Combine

@MainActor
final class LiveActivityManager: ObservableObject {

    // MARK: - State
    @Published var isActivityRunning: Bool = false
    private var activity: Activity<WorkoutAttributes>?
    private var lastUpdateDate: Date?
    private var lastSentHeartRate: Int = 0

    // MARK: - Konstantalar
    private let minimumUpdateInterval: TimeInterval = 5  // sek
    private let heartRateChangeThreshold: Int = 10       // bpm

    // MARK: - Activity boshlash
    func startActivity(session: WorkoutSession) {
        // ActivityKit mavjudligini tekshirish
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities yoqilmagan")
            return
        }

        // Static ma'lumotlar
        let attributes = WorkoutAttributes(
            workoutType: session.type.displayName,
            targetCalories: session.goal.targetCalories
        )

        // Boshlang'ich dynamic state
        let initialState = WorkoutAttributes.ContentState(
            heartRate: 0,
            calories: 0,
            elapsedSeconds: 0,
            pace: 0,
            steps: 0,
            status: WorkoutStatus.active.rawValue
        )

        let content = ActivityContent(
            state: initialState,
            staleDate: Date().addingTimeInterval(10) // 10 sek yangilanmasa "keski"
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil // Server push yo'q, local update ishlatamiz
            )
            isActivityRunning = true
            print("✅ Live Activity boshlandi: \(activity?.id ?? "unknown")")

        } catch {
            print("❌ Live Activity boshlanmadi: \(error.localizedDescription)")
        }
    }

    // MARK: - Activity yangilash (asosiy)
    func updateActivity(metrics: WorkoutMetrics, status: WorkoutStatus) async {
        guard let activity else { return }

        let newState = WorkoutAttributes.ContentState(
            heartRate: metrics.heartRate,
            calories: metrics.calories,
            elapsedSeconds: metrics.elapsedSeconds,
            pace: metrics.pace,
            steps: metrics.steps,
            status: status.rawValue
        )

        // Keyingi yangilana olish vaqti (staleDate)
        let staleDate = Date().addingTimeInterval(minimumUpdateInterval + 2)

        let content = ActivityContent(
            state: newState,
            staleDate: staleDate
        )

        await activity.update(content)
        lastUpdateDate = Date()
        lastSentHeartRate = metrics.heartRate
    }

    // MARK: - Smart update (keraksiz updatelarni skip qiladi)
    func updateIfNeeded(metrics: WorkoutMetrics, status: WorkoutStatus) async {
        // Pauza yoki status o'zgarsa — darhol update
        if status == .paused || status == .finished {
            await updateActivity(metrics: metrics, status: status)
            return
        }

        let now = Date()

        // Minimum interval tekshiruvi
        if let lastUpdate = lastUpdateDate,
           now.timeIntervalSince(lastUpdate) < minimumUpdateInterval {

            // HR keskin o'zgarmagan bo'lsa — skip
            let hrDelta = abs(metrics.heartRate - lastSentHeartRate)
            if hrDelta < heartRateChangeThreshold {
                return
            }
        }

        await updateActivity(metrics: metrics, status: status)
    }

    // MARK: - Activity tugatish
    func endActivity(finalMetrics: WorkoutMetrics) async {
        guard let activity else { return }

        let finalState = WorkoutAttributes.ContentState(
            heartRate: finalMetrics.heartRate,
            calories: finalMetrics.calories,
            elapsedSeconds: finalMetrics.elapsedSeconds,
            pace: finalMetrics.pace,
            steps: finalMetrics.steps,
            status: WorkoutStatus.finished.rawValue
        )

        let finalContent = ActivityContent(
            state: finalState,
            staleDate: nil
        )

        // 30 sekund ko'rinib turadi — foydalanuvchi natijani ko'rsin
        let dismissPolicy = ActivityUIDismissalPolicy.after(
            Date().addingTimeInterval(30)
        )

        await activity.end(finalContent, dismissalPolicy: dismissPolicy)

        self.activity = nil
        isActivityRunning = false
        print("✅ Live Activity tugadi")
    }

    // MARK: - Barcha aktiv activity'larni tozalash
    // (app crash bo'lsa qolgan activitylarni tozalash uchun)
    func cleanupStaleActivities() async {
        for oldActivity in Activity<WorkoutAttributes>.activities {
            await oldActivity.end(
                oldActivity.content,
                dismissalPolicy: .immediate
            )
        }
        self.activity = nil
        isActivityRunning = false
    }
}
