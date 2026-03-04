//
//  WorkoutMetrics.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation

struct WorkoutMetrics: Codable, Equatable {
    var heartRate: Int        = 0   // bpm
    var calories: Double      = 0   // kcal
    var elapsedSeconds: Int   = 0   // soniya
    var pace: Double          = 0   // min/km
    var steps: Int            = 0
    var distanceKM: Double    = 0

    // MARK: - Computed: formatlangan vaqt "24:35"
    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Computed: formatlangan temp "5:42 /km"
    var formattedPace: String {
        guard pace > 0 else { return "--:-- /km" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    // MARK: - Computed: formatlangan kaloriya "310 kcal"
    var formattedCalories: String {
        return String(format: "%.0f kcal", calories)
    }

    // MARK: - Computed: formatlangan masofa "3.2 km"
    var formattedDistance: String {
        return String(format: "%.1f km", distanceKM)
    }

    // MARK: - Computed: formatlangan qadam "4,820"
    var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }
}
