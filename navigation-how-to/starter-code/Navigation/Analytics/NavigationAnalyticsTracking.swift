import Foundation

// Plug your analytics backend here.
protocol NavigationAnalyticsTracking: AnyObject {
    func track(_ event: NavigationEvent)
}
