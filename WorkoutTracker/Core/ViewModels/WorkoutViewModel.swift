//
//  WorkoutViewModel.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation
import Combine
import HealthKit

@MainActor
final class WorkoutViewModel: ObservableObject {

    // MARK: - Published (UI ga)
    @Published var session: WorkoutSession?
    @Published var status: WorkoutStatus = .idle
    @Published var metrics: WorkoutMetrics = WorkoutMetrics()
    @Published var errorMessage: String?
    @Published var isHealthKitAuthorized: Bool = false
    @Published var liveActivityActive: Bool = false

    // MARK: - Managers
    private let healthKitManager: HealthKitManagerProtocol
    private let timerManager: WorkoutTimerManager
    let liveActivityManager: LiveActivityManager

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Snapshot timer (grafik uchun har 5 sek)
    private var snapshotTimer: AnyCancellable?

    // MARK: - Init
    @MainActor
    init(
        healthKitManager: HealthKitManagerProtocol,
        timerManager: WorkoutTimerManager,
        liveActivityManager: LiveActivityManager
    ) {
        self.healthKitManager    = healthKitManager
        self.timerManager        = timerManager
        self.liveActivityManager = liveActivityManager

        setupSubscriptions()
    }

    @MainActor
    static func makeDefault() -> WorkoutViewModel {
        WorkoutViewModel(
            healthKitManager: HealthKitManagerFactory.make(),
            timerManager: WorkoutTimerManager(),
            liveActivityManager: LiveActivityManager()
        )
    }

    // MARK: - HealthKit ruxsat so'rash
    func requestHealthKitAuthorization() async {
        do {
            isHealthKitAuthorized = try await healthKitManager.requestAuthorization()
        } catch {
            errorMessage = "HealthKit ruxsati: \(error.localizedDescription)"
        }
    }

    // MARK: - Mashqni boshlash
    func startWorkout(type: WorkoutType, goal: WorkoutGoal) async {
        guard status == .idle else { return }

        let newSession = WorkoutSession(type: type, goal: goal)
        self.session = newSession
        self.metrics = WorkoutMetrics()

        do {
            try await healthKitManager.startWorkout(type: type)
            timerManager.start()
            status = .active
            session?.status = .active
            startLiveActivity(session: newSession)
            startSnapshotTimer()
        } catch {
            errorMessage = "Mashq boshlanmadi: \(error.localizedDescription)"
            session = nil
            status = .idle
        }
    }

    // MARK: - Pause
    func pauseWorkout() {
        guard status == .active else { return }

        healthKitManager.pauseWorkout()
        timerManager.pause()
        status = .paused
        session?.status = .paused
        snapshotTimer?.cancel()
        updateLiveActivity()
    }

    // MARK: - Resume
    func resumeWorkout() {
        guard status == .paused else { return }

        healthKitManager.resumeWorkout()
        timerManager.resume()
        status = .active
        session?.status = .active
        startSnapshotTimer()
        updateLiveActivity()
    }

    // MARK: - Stop
    func stopWorkout() async {
        guard status == .active || status == .paused else { return }

        status = .finishing
        timerManager.pause()
        snapshotTimer?.cancel()

        do {
            let hkWorkout = try await healthKitManager.stopWorkout()
            session?.endTime = Date()
            session?.status = .finished
            session?.currentMetrics = metrics
            status = .finished
            endLiveActivity()
            // Widget ma'lumotini saqlash
            if let finishedSession = session {
                WorkoutWidgetDataManager.shared.saveWorkout(
                    session: finishedSession,
                    metrics: metrics
                )
            }
            print("✅ Mashq saqlandi: \(hkWorkout?.uuid.uuidString ?? "mock")")
        } catch {
            errorMessage = "Mashq saqlanmadi: \(error.localizedDescription)"
            status = .finished
        }
    }

    // MARK: - Reset (summary dan keyin)
    func resetWorkout() {
        session = nil
        metrics = WorkoutMetrics()
        status = .idle
        timerManager.reset()
        errorMessage = nil
    }
}

// MARK: - Private: Subscriptions
private extension WorkoutViewModel {

    func setupSubscriptions() {

        // Timer → elapsedSeconds + pace
        timerManager.elapsedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] seconds in
                guard let self, self.status == .active else { return }
                self.metrics.elapsedSeconds = seconds
                self.metrics.pace = PaceCalculator.calculate(
                    distanceKM: self.metrics.distanceKM,
                    elapsedSeconds: seconds
                )
            }
            .store(in: &cancellables)

        // HealthKit → heartRate
        healthKitManager.heartRatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] hr in
                self?.metrics.heartRate = hr
                self?.updateLiveActivityIfNeeded()
            }
            .store(in: &cancellables)

        // HealthKit → calories
        healthKitManager.caloriesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] kcal in
                self?.metrics.calories = kcal
            }
            .store(in: &cancellables)

        // HealthKit → distance
        healthKitManager.distancePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] km in
                self?.metrics.distanceKM = km
            }
            .store(in: &cancellables)

        // HealthKit → steps
        healthKitManager.stepsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] steps in
                self?.metrics.steps = steps
            }
            .store(in: &cancellables)
    }

    // MARK: - Snapshot timer
    func startSnapshotTimer() {
        snapshotTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let snapshot = MetricsSnapshot(metrics: self.metrics)
                self.session?.metricsHistory.append(snapshot)
                self.updateLiveActivity()
            }
    }
}

// MARK: - Private: Live Activity
private extension WorkoutViewModel {

    func startLiveActivity(session: WorkoutSession) {
        liveActivityManager.startActivity(session: session)
        liveActivityActive = liveActivityManager.isActivityRunning
    }

    func updateLiveActivity() {
        guard status == .active || status == .paused else { return }
        Task {
            await liveActivityManager.updateActivity(
                metrics: metrics,
                status: status
            )
        }
    }

    func updateLiveActivityIfNeeded() {
        guard status == .active else { return }
        Task {
            await liveActivityManager.updateIfNeeded(
                metrics: metrics,
                status: status
            )
        }
    }

    func endLiveActivity() {
        Task {
            await liveActivityManager.endActivity(finalMetrics: metrics)
            liveActivityActive = false
        }
    }
}
