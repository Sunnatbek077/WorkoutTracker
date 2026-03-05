//
//  WorkoutViewModel+Computed.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import Foundation

extension WorkoutViewModel {

    // MARK: - Progress (0.0 → 1.0)
    var progress: Double {
        guard let session else { return 0 }
        return session.goal.progress(
            calories: metrics.calories,
            elapsedSeconds: metrics.elapsedSeconds
        )
    }

    // MARK: - Maqsad tavsifi
    var goalDescription: String {
        session?.goal.description ?? ""
    }

    // MARK: - Mashq turi
    var workoutType: WorkoutType? {
        session?.type
    }

    // MARK: - Holat tekshiruvlari
    var isActive: Bool {
        status == .active
    }

    var isPaused: Bool {
        status == .paused
    }

    var isFinished: Bool {
        status == .finished
    }

    var isInProgress: Bool {
        status == .active || status == .paused
    }

    // MARK: - O'rtacha HR (history dan)
    var averageHeartRate: Int {
        guard let session, !session.metricsHistory.isEmpty else {
            return metrics.heartRate
        }
        let total = session.metricsHistory.reduce(0) { $0 + $1.heartRate }
        return total / session.metricsHistory.count
    }

    // MARK: - Maksimal HR
    var maxHeartRate: Int {
        session?.metricsHistory
            .max(by: { $0.heartRate < $1.heartRate })?
            .heartRate ?? metrics.heartRate
    }

    // MARK: - Minimal HR
    var minHeartRate: Int {
        session?.metricsHistory
            .min(by: { $0.heartRate < $1.heartRate })?
            .heartRate ?? metrics.heartRate
    }

    // MARK: - Jami davomiylik (formatlangan)
    var formattedTotalDuration: String {
        guard let session else { return "00:00" }
        let total = Int(session.totalDuration)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - HR grafik uchun data points
    var heartRateDataPoints: [(time: Int, hr: Int)] {
        session?.metricsHistory.map {
            (time: $0.elapsedSeconds, hr: $0.heartRate)
        } ?? []
    }

    // MARK: - Maqsadga yetildimi?
    var isGoalReached: Bool {
        progress >= 1.0
    }

    // MARK: - HR zonasi (mashq intensivligi)
    var heartRateZone: HeartRateZone {
        HeartRateZone.from(bpm: metrics.heartRate)
    }
}

// MARK: - HR Zone
enum HeartRateZone {
    case rest       // < 100
    case warmup     // 100–114
    case fatBurn    // 115–133
    case cardio     // 134–152
    case peak       // 153+

    var label: String {
        switch self {
        case .rest:     return "Dam olish"
        case .warmup:   return "Isitish"
        case .fatBurn:  return "Yog' yoqish"
        case .cardio:   return "Kardio"
        case .peak:     return "Yuqori intensiv"
        }
    }

    var color: String {
        switch self {
        case .rest:     return "gray"
        case .warmup:   return "blue"
        case .fatBurn:  return "green"
        case .cardio:   return "orange"
        case .peak:     return "red"
        }
    }

    static func from(bpm: Int) -> HeartRateZone {
        switch bpm {
        case ..<100:  return .rest
        case 100..<115: return .warmup
        case 115..<134: return .fatBurn
        case 134..<153: return .cardio
        default:        return .peak
        }
    }
}
