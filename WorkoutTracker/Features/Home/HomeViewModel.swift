//
//  HomeViewModel.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - So'nggi mashqlar (keyingi bosqichda HealthKit dan o'qiladi)
    @Published var recentSessions: [WorkoutSession] = []

    func loadRecentSessions() async {
        // TODO: HealthKit dan so'nggi 3 ta mashqni o'qish
    }
}
