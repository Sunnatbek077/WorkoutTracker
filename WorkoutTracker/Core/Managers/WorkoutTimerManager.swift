//
//  WorkoutTimerManager.swift
//  WorkoutTracker
//
//  Created by Sunnatbek on 01/03/26.
//

import Foundation
import Combine

final class WorkoutTimerManager {

    // MARK: - Publishers
    // Har soniyada elapsedSeconds chiqaradi
    private let elapsedSubject = CurrentValueSubject<Int, Never>(0)
    var elapsedPublisher: AnyPublisher<Int, Never> {
        elapsedSubject.eraseToAnyPublisher()
    }

    // MARK: - Private State
    private var timer: AnyCancellable?
    private var startDate: Date?
    private var pausedAt: Date?
    private var totalPausedDuration: TimeInterval = 0

    // MARK: - Computed: haqiqiy o'tgan vaqt
    var elapsedSeconds: Int {
        guard let startDate else { return 0 }

        // Agar hozir pauza bo'lsa — pausedAt gacha hisoblash
        let effectiveNow = pausedAt ?? Date()
        let elapsed = effectiveNow.timeIntervalSince(startDate) - totalPausedDuration
        return max(0, Int(elapsed))
    }

    // MARK: - Boshlash
    func start() {
        startDate = Date()
        totalPausedDuration = 0
        pausedAt = nil
        startTicking()
    }

    // MARK: - Pause
    func pause() {
        guard pausedAt == nil else { return } // allaqachon pauza
        pausedAt = Date()
        timer?.cancel()
        timer = nil
    }

    // MARK: - Resume
    func resume() {
        guard let pausedAt else { return }

        // Pauza davomiyligini qo'shib ketamiz
        totalPausedDuration += Date().timeIntervalSince(pausedAt)
        self.pausedAt = nil
        startTicking()
    }

    // MARK: - Reset
    func reset() {
        timer?.cancel()
        timer = nil
        startDate = nil
        pausedAt = nil
        totalPausedDuration = 0
        elapsedSubject.send(0)
    }

    // MARK: - Private: timer ishga tushirish
    private func startTicking() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.elapsedSubject.send(self.elapsedSeconds)
            }
    }
}
