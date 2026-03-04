//
//  HealthKitManager.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import SwiftUI
import HealthKit

enum WorkoutType: String, CaseIterable, Codable {
    case running = "Running"
    case cycling = "Cycling"
    case walking = "Walking"
    case hiit = "HIIT"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .walking: return "walk"
        case .hiit: return "figure.highintensity.intervaltraining"
        }
    }
    
    var color: Color {
        switch self {
        case .running: return .orange
        case .cycling: return .blue
        case .walking: return .green
        case .hiit: return .red
        }
    }
    
    var defaultTargetCalories: Int {
        switch self {
        case .running:
            return 400
        case .cycling:
            return 350
        case .walking:
            return 200
        case .hiit:
            return 300
        }
    }
    
    var hkActivityType: HKWorkoutActivityType {
        switch self {
        case .running:
            return .running
        case .cycling:
            return .cycling
        case .walking:
            return .walking
        case .hiit:
            return .highIntensityIntervalTraining
        }
    }
}

enum WorkoutGoal: Codable, Equatable {
    case calories(target: Int)
    case duration(second: Int)
    
    // Maqsadga nisbatan progress (0.0 -> 1.0)
    func progress(calories: Double, elapsedSeconds: Int) -> Double {
        switch self {
        case .calories(target: let target):
            return min(calories / Double(target), 1.0)
        case .duration(second: let target):
            return min(Double(elapsedSeconds) / Double(target), 1.0)
        }
    }
    
    var description: String {
        switch self {
        case .calories(let t): return "\(t) kcal"
        case .duration(let t): return "\(t / 60) daqiqa"
        }
    }
    
    var targetCalories: Int {
        switch self {
        case .calories(let t): return t
        case .duration: return 0
        }
    }
}
