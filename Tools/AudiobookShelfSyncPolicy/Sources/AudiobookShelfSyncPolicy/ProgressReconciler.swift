/// Stable identity of an imported audiobook. Never substitute a filename or a token.
public struct ProgressScope: Equatable, Sendable {
  public let connectionID: String
  public let userID: String
  public let itemID: String

  public init(connectionID: String, userID: String, itemID: String) {
    self.connectionID = connectionID
    self.userID = userID
    self.itemID = itemID
  }
}

/// Seconds are absolute book offsets, not chapter-relative offsets.
public struct ProgressSnapshot: Equatable, Sendable {
  public let scope: ProgressScope
  public let currentTime: Double
  public let duration: Double
  public let isFinished: Bool
  /// Server-issued revision (ABS updatedAt milliseconds), never a device wall clock.
  public let serverUpdatedAt: Int64

  public init(scope: ProgressScope, currentTime: Double, duration: Double,
              isFinished: Bool, serverUpdatedAt: Int64) {
    self.scope = scope
    self.currentTime = currentTime
    self.duration = duration
    self.isFinished = isFinished
    self.serverUpdatedAt = serverUpdatedAt
  }
}

/// Offers only. No decision authorizes I/O or alters the local library.
public enum ProgressDecision: Equatable, Sendable {
  case inSync
  case offerUpload
  case offerDownload
  case conflict
  case invalid
}

public enum ProgressReconciler {
  public static func decide(baseline: ProgressSnapshot?, local: ProgressSnapshot,
                            remote: ProgressSnapshot) -> ProgressDecision {
    .offerUpload
  }
}
