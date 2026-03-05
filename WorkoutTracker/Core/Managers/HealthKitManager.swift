//
//  HealthKitManager.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation
import HealthKit
import Combine

// MARK: - Protocol
// Real va Mock manager shu contractga amal qiladi
protocol HealthKitManagerProtocol: AnyObject {

    // Publisher'lar — real-vaqt ma'lumot oqimi
    var heartRatePublisher: AnyPublisher<Int, Never> { get }
    var caloriesPublisher: AnyPublisher<Double, Never> { get }
    var distancePublisher: AnyPublisher<Double, Never> { get }
    var stepsPublisher: AnyPublisher<Int, Never> { get }

    // Ruxsat
    func requestAuthorization() async throws -> Bool

    // Sessiya boshqaruvi
    func startWorkout(type: WorkoutType) async throws
    func pauseWorkout()
    func resumeWorkout()
    func stopWorkout() async throws -> HKWorkout?
}

final class HealthKitManager: NSObject, HealthKitManagerProtocol {

    // MARK: - Properties
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    // MARK: - Subjects (ichki)
    private let heartRateSubject  = PassthroughSubject<Int, Never>()
    private let caloriesSubject   = PassthroughSubject<Double, Never>()
    private let distanceSubject   = PassthroughSubject<Double, Never>()
    private let stepsSubject      = PassthroughSubject<Int, Never>()

    // MARK: - Publishers (tashqariga)
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

    // MARK: - Read/Write turlari
    private var readTypes: Set<HKObjectType> {
        [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.stepCount)
        ]
    }

    private var writeTypes: Set<HKSampleType> {
        [
            HKQuantityType(.activeEnergyBurned),
            HKObjectType.workoutType()
        ]
    }

    // MARK: - Ruxsat so'rash
    func requestAuthorization() async throws -> Bool {
        // HealthKit faqat real qurilmada ishlaydi
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }

        try await healthStore.requestAuthorization(
            toShare: writeTypes,
            read: readTypes
        )
        return true
    }

    // MARK: - Sessiya boshlash
    func startWorkout(type: WorkoutType) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType  = type.hkActivityType
        configuration.locationType  = .outdoor

        // Session va Builder yaratish
        let newSession = try HKWorkoutSession(
            healthStore: healthStore,
            configuration: configuration
        )
        let newBuilder = newSession.associatedWorkoutBuilder()

        // Delegate'larni belgilash
        newSession.delegate = self
        newBuilder.delegate = self

        // Data source — qurilmadan avtomatik o'qiydi
        newBuilder.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )

        self.session = newSession
        self.builder = newBuilder

        // Boshlash
        let startDate = Date()
        newSession.startActivity(with: startDate)
        try await newBuilder.beginCollection(at: startDate)
    }

    // MARK: - Pause
    func pauseWorkout() {
        session?.pause()
    }

    // MARK: - Resume
    func resumeWorkout() {
        session?.resume()
    }

    // MARK: - To'xtatish va saqlash
    func stopWorkout() async throws -> HKWorkout? {
        guard let session, let builder else { return nil }

        let endDate = Date()
        session.end()

        try await builder.endCollection(at: endDate)
        let workout = try await builder.finishWorkout()

        self.session = nil
        self.builder = nil

        return workout
    }
}

// MARK: - HKWorkoutSessionDelegate
extension HealthKitManager: HKWorkoutSessionDelegate {

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        // State o'zgarishlari shu yerda handle qilinadi
        // ViewModel delegate orqali xabardor bo'ladi
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        print("❌ WorkoutSession xatosi: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension HealthKitManager: HKLiveWorkoutBuilderDelegate {

    // Yangi ma'lumot kelganda chaqiriladi
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            processQuantityType(quantityType, from: workoutBuilder)
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Workout event'lari (pause, resume) — hozircha bo'sh
    }

    // MARK: - Ma'lumotni qayta ishlash
    private func processQuantityType(
        _ type: HKQuantityType,
        from builder: HKLiveWorkoutBuilder
    ) {
        switch type {

        case HKQuantityType(.heartRate):
            let unit = HKUnit.count().unitDivided(by: .minute())
            if let stats = builder.statistics(for: type),
               let value = stats.mostRecentQuantity()?.doubleValue(for: unit) {
                heartRateSubject.send(Int(value))
            }

        case HKQuantityType(.activeEnergyBurned):
            let unit = HKUnit.kilocalorie()
            if let stats = builder.statistics(for: type),
               let value = stats.sumQuantity()?.doubleValue(for: unit) {
                caloriesSubject.send(value)
            }

        case HKQuantityType(.distanceWalkingRunning):
            let unit = HKUnit.meter()
            if let stats = builder.statistics(for: type),
               let value = stats.sumQuantity()?.doubleValue(for: unit) {
                distanceSubject.send(value / 1000) // km ga
            }

        case HKQuantityType(.stepCount):
            let unit = HKUnit.count()
            if let stats = builder.statistics(for: type),
               let value = stats.sumQuantity()?.doubleValue(for: unit) {
                stepsSubject.send(Int(value))
            }

        default:
            break
        }
    }
}

enum HealthKitError: LocalizedError {

    case notAvailable
    case authorizationDenied
    case sessionFailed(Error)
    case builderFailed(Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit bu qurilmada mavjud emas"
        case .authorizationDenied:
            return "HealthKit ruxsati rad etildi"
        case .sessionFailed(let e):
            return "Sessiya xatosi: \(e.localizedDescription)"
        case .builderFailed(let e):
            return "Builder xatosi: \(e.localizedDescription)"
        }
    }
}
