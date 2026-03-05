//
//  MockHealthKitManager.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 05/03/26.
//

import Foundation
import Combine
import HealthKit

final class MockHealthKitManager: HealthKitManagerProtocol {

    // MARK: - Subjects
    private let heartRateSubject  = PassthroughSubject<Int, Never>()
    private let caloriesSubject   = PassthroughSubject<Double, Never>()
    private let distanceSubject   = PassthroughSubject<Double, Never>()
    private let stepsSubject      = PassthroughSubject<Int, Never>()

    // MARK: - Publishers
    var heartRatePublisher: AnyPublisher<Int, Never> {
        heartRateSubject.eraseToAnyPublisher()
    }
    var caloriesPublisher: AnyPublisher<Double, Never> {
        caloriesSubject.eraseToAnyPublisher()
    }
    var distancePublisher: AnyPublisher<Double, Never> {
        distanceSubject.eraseToAnyPublisher()
    }
    var stepsPublisher: AnyPublisher<Int, Never> {
        stepsSubject.eraseToAnyPublisher()
    }

    // MARK: - Mock State
    private var mockTimer: AnyCancellable?
    private var mockCalories: Double = 0
    private var mockDistance: Double = 0
    private var mockSteps: Int = 0
    private var isRunning = false

    // MARK: - Ruxsat (mock — har doim true)
    func requestAuthorization() async throws -> Bool {
        return true
    }

    // MARK: - Boshlash
    func startWorkout(type: WorkoutType) async throws {
        isRunning = true
        startMockDataGeneration()
    }

    // MARK: - Pause
    func pauseWorkout() {
        isRunning = false
    }

    // MARK: - Resume
    func resumeWorkout() {
        isRunning = true
    }

    // MARK: - Stop
    func stopWorkout() async throws -> HKWorkout? {
        isRunning = false
        mockTimer?.cancel()
        mockTimer = nil
        return nil // Mock — HKWorkout saqlanmaydi
    }

    // MARK: - Mock ma'lumot generatsiyasi
    private func startMockDataGeneration() {
        mockTimer = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isRunning else { return }
                self.generateMockData()
            }
    }

    private func generateMockData() {
        // HR: 125-165 oralig'ida realistic o'zgarish
        let baseHR = 142
        let variation = Int.random(in: -8...8)
        let newHR = max(120, min(170, baseHR + variation))
        heartRateSubject.send(newHR)

        // Kaloriya: har 2 sekundda ~0.15-0.25 kcal
        mockCalories += Double.random(in: 0.15...0.25)
        caloriesSubject.send(mockCalories)

        // Masofa: har 2 sekundda ~0.01-0.015 km
        mockDistance += Double.random(in: 0.01...0.015)
        distanceSubject.send(mockDistance)

        // Qadam: har 2 sekundda 3-5 qadam
        mockSteps += Int.random(in: 3...5)
        stepsSubject.send(mockSteps)
    }
}

enum HealthKitManagerFactory {

    static func make() -> HealthKitManagerProtocol {
        #if targetEnvironment(simulator)
            return MockHealthKitManager()
        #else
            return HealthKitManager()
        #endif
    }
}   
