//
//  WorkoutStatus.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation

enum WorkoutStatus: String, Codable, Equatable {
    case idle // Mashq boshlanmagan
    case active // Mashq ketmoqda
    case paused // To'xtatilgan
    case finishing // Tugash jarayonida
    case finished // Tugadi
    
    var isInProgress: Bool {
        self == .active || self == .paused
    }
    
    var displayName: String {
        switch self {
        case .idle:
            return "Ready"
        case .active:
            return "Active"
        case .paused:
            return "Paused"
        case .finishing:
            return "Finishing"
        case .finished:
            return "Finished"
        }
    }
}
