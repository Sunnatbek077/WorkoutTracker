//
//  WorkoutAttributes.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 14/03/26.
//

import Foundation
import ActivityKit

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

        // MARK: - Computed

        var formattedTime: String {
            let m = elapsedSeconds / 60
            let s = elapsedSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }

        var formattedCalories: String {
            String(format: "%.0f", calories)
        }

        var formattedPace: String {
            guard pace > 0 else { return "--:--" }
            let m = Int(pace)
            let s = Int((pace - Double(m)) * 60)
            return String(format: "%d:%02d", m, s)
        }

        var formattedSteps: String {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            return f.string(from: NSNumber(value: steps)) ?? "\(steps)"
        }

        var isActive: Bool { status == "active" }
        var isPaused: Bool { status == "paused" }
        var isFinished: Bool { status == "finished" }

        func progress(targetCalories: Int) -> Double {
            guard targetCalories > 0 else { return 0 }
            return min(calories / Double(targetCalories), 1.0)
        }
    }
}
