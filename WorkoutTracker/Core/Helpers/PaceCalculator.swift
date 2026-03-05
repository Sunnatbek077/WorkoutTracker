//
//  PaceCalculator.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import Foundation

struct PaceCalculator {

    // MARK: - Pace hisoblash
    // distanceKM: bosib o'tilgan masofa
    // elapsedSeconds: o'tgan vaqt
    // return: min/km formatida (masalan 5.7 = 5:42 /km)
    static func calculate(
        distanceKM: Double,
        elapsedSeconds: Int
    ) -> Double {
        guard distanceKM > 0.05 else { return 0 } // juda kam masofada hisoblama

        let elapsedMinutes = Double(elapsedSeconds) / 60.0
        return elapsedMinutes / distanceKM
    }

    // MARK: - Pace ni "5:42 /km" formatiga o'girish
    static func format(_ pace: Double) -> String {
        guard pace > 0 else { return "--:-- /km" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    // MARK: - ETA hisoblash (maqsadga qancha qoldi)
    // targetKM: maqsad masofa
    // currentPace: hozirgi temp
    // return: qolgan sekund
    static func estimatedTimeRemaining(
        targetKM: Double,
        coveredKM: Double,
        currentPace: Double
    ) -> Int? {
        guard currentPace > 0 else { return nil }
        let remainingKM = targetKM - coveredKM
        guard remainingKM > 0 else { return 0 }
        let remainingMinutes = remainingKM * currentPace
        return Int(remainingMinutes * 60)
    }
}
