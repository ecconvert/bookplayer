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

  func testConservativeDecisionMatrix() {
    let base = snapshot(10)
    let otherUser = ProgressScope(connectionID: "connection-a", userID: "user-b", itemID: "item-a")
    let otherServer = ProgressScope(connectionID: "connection-b", userID: "user-a", itemID: "item-a")
    let otherItem = ProgressScope(connectionID: "connection-a", userID: "user-a", itemID: "item-b")
    let emptyScope = ProgressScope(connectionID: "", userID: "user-a", itemID: "item-a")
    let whitespaceScope = ProgressScope(connectionID: " \n", userID: "user-a", itemID: "item-a")
    let cases: [(String, ProgressSnapshot?, ProgressSnapshot, ProgressSnapshot, ProgressDecision)] = [
      ("same values, different revision", base, base, snapshot(10, revision: 2), .inSync),
      ("no baseline, same values", nil, base, base, .inSync),
      ("no baseline, different values", nil, snapshot(20), base, .conflict),
      ("remote changed only", base, base, snapshot(30, revision: 2), .offerDownload),
      ("both changed", base, snapshot(20), snapshot(30, revision: 2), .conflict),
      ("local rewind is intentional", base, snapshot(5), base, .offerUpload),
      ("remote rewind is intentional", base, base, snapshot(5, revision: 2), .offerDownload),
      ("local finished toggle", base, snapshot(10, finished: true), base, .offerUpload),
      ("remote finished toggle", base, base, snapshot(10, finished: true, revision: 2), .offerDownload),
      ("competing finished changes", base, snapshot(10, finished: true), snapshot(20, revision: 2), .conflict),
      ("server revision changed despite same position", base, snapshot(20), snapshot(10, revision: 2), .conflict),
      ("remote older than baseline", snapshot(10, revision: 2), snapshot(20, revision: 2), base, .conflict),
      ("local based on different revision", base, snapshot(20, revision: 2), base, .conflict),
      ("different user", base, base, snapshot(10, scope: otherUser), .conflict),
      ("different server", base, base, snapshot(10, scope: otherServer), .conflict),
      ("different item", base, base, snapshot(10, scope: otherItem), .conflict),
      ("baseline identity mismatch", snapshot(10, scope: otherUser), base, base, .conflict),
      ("duration changed", base, base, snapshot(10, duration: 200), .conflict),
      ("baseline duration mismatch", snapshot(10, duration: 200), base, base, .conflict),
      ("negative time", base, snapshot(-1), base, .invalid),
      ("past end", base, snapshot(101), base, .invalid),
      ("not a number", base, snapshot(.nan), base, .invalid),
      ("infinite time", base, base, snapshot(.infinity), .invalid),
      ("zero duration", base, snapshot(0, duration: 0), base, .invalid),
      ("infinite duration", base, base, snapshot(10, duration: .infinity), .invalid),
      ("invalid baseline", snapshot(-1), base, base, .invalid),
      ("missing server revision", base, snapshot(10, revision: 0), base, .invalid),
      ("empty identity", nil, snapshot(10, scope: emptyScope), snapshot(10, scope: emptyScope), .invalid),
      ("blank identity", nil, snapshot(10, scope: whitespaceScope), snapshot(10, scope: whitespaceScope), .invalid)
    ]
    for (name, baseline, local, remote, expected) in cases {
      XCTAssertEqual(ProgressReconciler.decide(baseline: baseline, local: local, remote: remote), expected, name)
    }
  }
}
