//
//  MockStepProviders.swift
//  StepKit
//
//  Created by Jotaro Sugiyama on 2025/07/06.
//

import Foundation
@testable import StepKit

// MARK: - Mock HealthKit Provider

final class MockHealthKitStepProvider: HealthKitStepProviding, @unchecked Sendable {
    var isAvailable: Bool = true
    var isAuthorized: Bool = true
    
    var stepsToReturn: Int?
    var errorToThrow: Error?
    var stepsByDateToReturn: [Date: Int] = [:]
    
    func requestPermission() async throws {
        if let error = errorToThrow { throw error }
    }
    
    func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        if let error = errorToThrow { throw error }
        return stepsToReturn ?? 0
    }
    
    func fetchStepsForSpecificDate(_ date: Date) async throws -> Int {
        if let error = errorToThrow { throw error }
        return stepsByDateToReturn[date] ?? stepsToReturn ?? 0
    }
    
    func fetchTodaySteps() async throws -> Int { return stepsToReturn ?? 0 }
    func fetchStepsForLastNDays(_ days: Int) async throws -> [Date : Int] { return [:] }
    func fetchStepsForDateRange(from startDate: Date, to endDate: Date) async throws -> [Date : Int] { return [:] }
    func fetchMonthlySteps(for date: Date) async throws -> [Date : Int] { return [:] }
    func fetchWeeklySteps(for date: Date) async throws -> [Date : Int] { return [:] }
    func fetchYearlySteps(for year: Int) async throws -> [Date : Int] { return [:] }
}


// MARK: - Mock CoreMotion Provider

final class MockCoreMotionStepProvider: CoreMotionStepProviding, @unchecked Sendable {
    var isAvailable: Bool = true
    
    var stepsToReturn: Int?
    var errorToThrow: Error?
    
    var fetchStepsCallCount = 0
    
    func requestPermission() async throws {
        if let error = errorToThrow { throw error }
    }
    
    func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        fetchStepsCallCount += 1
        if let error = errorToThrow { throw error }
        return stepsToReturn ?? 0
    }
    
    func fetchTodaySteps() async throws -> Int { return stepsToReturn ?? 0 }
    func fetchStepsForSpecificDate(_ date: Date) async throws -> Int { return stepsToReturn ?? 0 }
    func startRealtimeStepUpdates(from startDate: Date, handler: @escaping @Sendable (Int) -> Void) {}
    func stopRealtimeStepUpdates() {}
}
