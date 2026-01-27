import Foundation

/// Pro gating extension for AIService.
///
/// This provides a default `isProOnly` flag so views like `ProServiceLimiter` can
/// compile and conditionally present upgrade prompts. Update the logic here to
/// reflect your app's actual pro-tier rules.
extension AIService {
    /// Indicates whether this service requires a Pro subscription.
    ///
    /// Customize this logic to match your product tiers. For example, you might
    /// switch on an enum like `tier`, check `id` against a set, or read from
    /// configuration.
    var isProOnly: Bool {
        // TODO: Replace with real logic, e.g. based on service id or tier.
        return false
    }
}
