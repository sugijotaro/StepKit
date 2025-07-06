# StepKit

HealthKitとCoreMotionから歩数データを取得し、インテリジェントなハイブリッドデータ集約を提供するSwiftライブラリです。

## 機能

- **ハイブリッドデータソース**: HealthKitとCoreMotionの間で最適なデータソースを自動選択
- **インテリジェントフォールバック**: CoreMotionデータが利用できない場合やエラー時にHealthKitを使用
- **リアルタイム更新**: CoreMotionによるリアルタイム歩数更新
- **履歴データ**: HealthKitを通じた包括的な履歴歩数データへのアクセス
- **モダンSwift**: async/await、アクター、Swift 6並行性で構築

## 要件

- iOS 16.0+

## インストール

### Swift Package Manager

XcodeまたはPackage.swiftにStepKitを追加してプロジェクトに追加します：

```swift
dependencies: [
    .package(url: "https://github.com/sugijotaro/StepKit.git", from: "1.0.0")
]
```

## 使用方法

### 基本セットアップ

```swift
import StepKit

// サービスインスタンスの作成
let stepService = await StepService()

// 権限の要求
try await stepService.requestPermissions()
```

### 歩数データの取得

```swift
// 今日の歩数を取得
let todaySteps = try await stepService.fetchTodaySteps()
print("今日の歩数: \(todaySteps.steps) ソース: \(todaySteps.source)")

// 特定の期間の歩数を取得
let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
let endDate = Date()
let weekSteps = try await stepService.fetchSteps(from: startDate, to: endDate)
print("今週の歩数: \(weekSteps.steps)")

// 特定の日付の歩数を取得
let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
let yesterdaySteps = try await stepService.fetchStepsForSpecificDate(yesterday)
```

### リアルタイム歩数更新

```swift
// リアルタイム更新の開始
stepService.startRealtimeStepUpdates { stepData in
    print("現在の歩数: \(stepData.steps)")
}

// 完了時に更新を停止
stepService.stopRealtimeStepUpdates()
```

### 高度な設定

```swift
// カスタム設定
let config = StepService.Configuration(
    useHybridMode: true,
    coreMotionLookbackDays: 7
)

let stepService = await StepService(
    healthKitProvider: customHealthKitProvider,
    coreMotionProvider: customCoreMotionProvider,
    configuration: config
)
```

## データソース

### ハイブリッドモード

StepKitは複数のソースからデータをインテリジェントに結合します：

- **最近のデータ（≤7日）**: HealthKitとCoreMotionを比較するハイブリッドアプローチを使用し、より高い値を選択
- **履歴データ（>7日）**: 履歴の正確性のためHealthKitのみを使用
- **フォールバック**: 一方が失敗した場合、利用可能なプロバイダーに自動的にフォールバック

### データソースの優先順位

1. **ハイブリッド**（最近のデータ）: `max(HealthKit, CoreMotion)`
2. **HealthKit**（履歴データまたはCoreMotion利用不可）
3. **CoreMotion**（HealthKit利用不可）

## エラーハンドリング

```swift
do {
    let steps = try await stepService.fetchTodaySteps()
} catch StepServiceError.noProviderAvailable {
    print("歩数データプロバイダーが利用できません")
} catch StepServiceError.permissionDenied {
    print("歩数データアクセスの権限が拒否されました")
} catch StepServiceError.dataNotAvailable {
    print("要求された期間の歩数データが利用できません")
}
```

## テスト

StepKitには、アプリケーションのテストを容易にするモックプロバイダーを使用した包括的なユニットテストが含まれています。

```bash
swift test
```

## アーキテクチャ

### コアコンポーネント

- **StepService**: 統一された歩数データアクセスを提供するメインサービスクラス
- **HealthKitStepProvider**: 包括的な履歴データのためのHealthKit統合
- **CoreMotionStepProvider**: 最近のデータとリアルタイム更新のためのCoreMotion統合
- **StepData**: ソース追跡機能付きの統一データモデル

### プロトコルベース設計

すべてのプロバイダーはプロトコル（`HealthKitStepProviding`、`CoreMotionStepProviding`）を実装し、簡単なテストとカスタマイズを可能にします。

## プライバシーと権限

StepKitには適切な権限が必要です：

- **HealthKit**: 歩数の読み取り権限
- **CoreMotion**: モーション活動の権限

歩数データにアクセスする前に常に権限を要求してください：

```swift
try await stepService.requestPermissions()
```

## データ取得戦略

### 直近データ（7日以内）
- HealthKitとCoreMotionの両方からデータを取得
- より高い値を選択（通常、より正確）
- 一方がエラーの場合、もう一方にフォールバック

### 履歴データ（7日より前）
- HealthKitのみを使用（CoreMotionは7日間の制限があるため）
- 長期間の履歴データにはHealthKitが最適

### リアルタイムデータ
- CoreMotionを使用してリアルタイム更新を提供
- バックグラウンドでの継続的な監視が可能

## 貢献

1. リポジトリをフォーク
2. 機能ブランチを作成
3. 新機能のテストを追加
4. すべてのテストが通ることを確認
5. プルリクエストを送信

## ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細についてはLICENSEファイルを参照してください。

## サポート

質問、問題、機能リクエストについては、GitHubでissueを開いてください。

---

**注意**: このライブラリは、インテリジェントなソース選択とフォールバックメカニズムを備えた信頼性の高い歩数データが必要なiOSアプリケーション向けに設計されています。
