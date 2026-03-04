//
//  Double+Formatting.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation

extension Double {
    var oneDecimal: String {
        String(format: "%.1f", self)
    }
    
    var noDecimal: String {
        String(format: "%.0f", self)
    }
}
