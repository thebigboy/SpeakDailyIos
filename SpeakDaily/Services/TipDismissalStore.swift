import Foundation

struct TipDismissalStore {
    private static let storageKey = "tip.dismissedUntil"

    static func shouldShowTip(now: Date = Date()) -> Bool {
        let timestamp = UserDefaults.standard.double(forKey: storageKey)
        guard timestamp > 0 else { return true }
        let dismissedUntil = Date(timeIntervalSince1970: timestamp)
        return dismissedUntil <= now
    }

    static func dismissForOneMonth(now: Date = Date()) {
        let calendar = Calendar.current
        let next = calendar.date(byAdding: .month, value: 1, to: now)
            ?? now.addingTimeInterval(30 * 24 * 60 * 60)
        UserDefaults.standard.set(next.timeIntervalSince1970, forKey: storageKey)
    }
}
