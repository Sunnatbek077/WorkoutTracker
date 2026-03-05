//
//  WorkoutGoals.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import Foundation

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
