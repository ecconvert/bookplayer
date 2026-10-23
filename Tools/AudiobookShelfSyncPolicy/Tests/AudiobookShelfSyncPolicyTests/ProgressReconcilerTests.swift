import XCTest
@testable import AudiobookShelfSyncPolicy

final class ProgressReconcilerTests: XCTestCase {
  let scope = ProgressScope(connectionID: "connection-a", userID: "user-a", itemID: "item-a")

  func snapshot(_ time: Double, finished: Bool = false, revision: Int64 = 1,
                duration: Double = 100, scope: ProgressScope? = nil) -> ProgressSnapshot {
    ProgressSnapshot(scope: scope ?? self.scope, currentTime: time,
                     duration: duration, isFinished: finished, serverUpdatedAt: revision)
  }

  func testRemoteUnchangedOffersUpload() {
    let baseline = snapshot(10)
    XCTAssertEqual(ProgressReconciler.decide(baseline: baseline, local: snapshot(20), remote: baseline), .offerUpload)
  }
}
