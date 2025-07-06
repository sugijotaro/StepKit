import Testing
@testable import StepKit
import Foundation

@Suite("StepServiceのテスト")
final class StepServiceTests {
    
    var healthKitProvider: MockHealthKitStepProvider!
    var coreMotionProvider: MockCoreMotionStepProvider!
    var stepService: StepService!
    
    @Test("ハイブリッドモード: CoreMotionの歩数が多い場合、CoreMotionの値が採用される")
    func fetchHybridSteps_CoreMotionIsHigher() async throws {
        // 1. 準備 (Arrange)
        healthKitProvider = MockHealthKitStepProvider()
        coreMotionProvider = MockCoreMotionStepProvider()
        
        healthKitProvider.stepsToReturn = 100
        coreMotionProvider.stepsToReturn = 120
        
        stepService = await StepService(
            healthKitProvider: healthKitProvider,
            coreMotionProvider: coreMotionProvider
        )
        
        // 2. 実行 (Act)
        let today = Date()
        let result = try await stepService.fetchSteps(from: today, to: today)
        
        // 3. 検証 (Assert)
        #expect(result.steps == 120, "より多い歩数が選択されるべき")
        #expect(result.source == .hybrid, "データソースはhybridであるべき")
    }
    
    @Test("ハイブリッドモード: HealthKitの歩数が多い場合、HealthKitの値が採用される")
    func fetchHybridSteps_HealthKitIsHigher() async throws {
        // 1. 準備
        healthKitProvider = MockHealthKitStepProvider()
        coreMotionProvider = MockCoreMotionStepProvider()
        
        healthKitProvider.stepsToReturn = 150
        coreMotionProvider.stepsToReturn = 120
        
        stepService = await StepService(
            healthKitProvider: healthKitProvider,
            coreMotionProvider: coreMotionProvider
        )
        
        // 2. 実行
        let today = Date()
        let result = try await stepService.fetchSteps(from: today, to: today)
        
        // 3. 検証
        #expect(result.steps == 150, "より多い歩数が選択されるべき")
        #expect(result.source == .hybrid, "データソースはhybridであるべき")
    }
    
    @Test("フォールバック: CoreMotionがエラーの場合、HealthKitの値が使用される")
    func fetchHybridSteps_CoreMotionFails() async throws {
        // 1. 準備
        healthKitProvider = MockHealthKitStepProvider()
        coreMotionProvider = MockCoreMotionStepProvider()
        
        healthKitProvider.stepsToReturn = 100
        coreMotionProvider.errorToThrow = CoreMotionStepError.dataNotAvailable
        
        stepService = await StepService(
            healthKitProvider: healthKitProvider,
            coreMotionProvider: coreMotionProvider
        )
        
        // 2. 実行
        let today = Date()
        let result = try await stepService.fetchSteps(from: today, to: today)
        
        // 3. 検証
        #expect(result.steps == 100, "HealthKitの歩数がフォールバックとして使用されるべき")
        #expect(result.source == .healthKit, "データソースはhealthKitであるべき")
    }
    
    @Test("古いデータ: 7日より前のデータはHealthKitのみを使用する")
    func fetchOldData_usesHealthKitOnly() async throws {
        // 1. 準備
        healthKitProvider = MockHealthKitStepProvider()
        coreMotionProvider = MockCoreMotionStepProvider()
        
        healthKitProvider.stepsToReturn = 500
        coreMotionProvider.stepsToReturn = 999 // この値は呼ばれないはず
        
        stepService = await StepService(
            healthKitProvider: healthKitProvider,
            coreMotionProvider: coreMotionProvider
        )
        
        // 2. 実行
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
        let result = try await stepService.fetchSteps(from: eightDaysAgo, to: eightDaysAgo)
        
        // 3. 検証
        #expect(result.steps == 500, "HealthKitの値が使用されるべき")
        #expect(result.source == .healthKit, "データソースはhealthKitであるべき")
        #expect(coreMotionProvider.fetchStepsCallCount == 0, "CoreMotionProviderは呼ばれるべきではない")
    }
}
