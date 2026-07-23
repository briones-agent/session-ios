// Copyright © 2025 Rangeproof Pty Ltd. All rights reserved.

import Foundation

public extension Task where Success == Never, Failure == Never {
    /// Suspends the current task until the given deadline (compatibility version).
    ///
    /// Note: originally `obsoleted: 16.0`, but this app now has a 16.1 deployment floor (Expo/React
    /// Native) so the overload is kept available — it still accepts the `DispatchTimeInterval` values
    /// used throughout the app and forwards to the built-in nanosecond sleep.
    @available(iOS, introduced: 13.0)
    static func sleep(for interval: DispatchTimeInterval) async throws {
        /// Calculate total nanoseconds safely (avoid `UInt64` overflow if something like `Date.distantFuture` is provided)
        let nanoseconds: UInt64 = DispatchTimeInterval.nanoseconds(from: interval)
        try await Task.sleep(nanoseconds: min(nanoseconds, UInt64.max - 1))
    }
    
    static func sleep(
        for interval: DispatchTimeInterval,
        checkingEvery checkInterval: DispatchTimeInterval = .milliseconds(100),
        until condition: () async -> Bool
    ) async throws {
        let totalNanoseconds: UInt64 = DispatchTimeInterval.nanoseconds(from: interval)
        let checkNanoseconds: UInt64 = DispatchTimeInterval.nanoseconds(from: checkInterval)

        guard checkNanoseconds > 0 else { return }
        
        var elapsed: UInt64 = 0

        
        while elapsed < totalNanoseconds {
            guard await !condition() else { return }
            
            try await Task.sleep(
                nanoseconds: min(checkNanoseconds, UInt64.max - 1)
            )

            elapsed = (elapsed > UInt64.max - checkNanoseconds ?
                UInt64.max :
                elapsed + checkNanoseconds
            )
        }
    }
}
