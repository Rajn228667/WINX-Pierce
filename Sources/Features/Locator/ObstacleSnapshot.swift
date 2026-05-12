import Foundation

/// A single frame of obstacle-detection output, mirroring the structure used by
/// the Android Locator's `ObstacleSnapshot`. The view-model consumes a stream
/// of these and decides which voice cue (if any) to play.
struct ObstacleSnapshot: Equatable {

    enum Zone: String, Equatable {
        case none
        case left
        case center
        case right
    }

    /// Where in the frame the dominant obstacle lives.
    let zone: Zone
    /// Normalised area of the dominant obstacle, 0…1. Larger = closer.
    let proximity: Double
    /// X-coordinate of the obstacle's centroid in 0…1 (0 = far left, 1 = far right).
    let centroidX: Double
    /// True if the frame is too dark to analyse reliably.
    let tooDark: Bool

    static let clear = ObstacleSnapshot(zone: .none, proximity: 0, centroidX: 0.5, tooDark: false)
}
