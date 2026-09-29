import LocalAuthentication
import Observation
import SwiftUI

/// Face ID / Touch ID / passcode lock for the whole app (Pro feature).
@MainActor
@Observable
final class AppLock {
    private(set) var isLocked: Bool
    private(set) var isAuthenticating = false

    init() {
        isLocked = UserDefaults.standard.bool(forKey: PreferenceKey.appLockEnabled)
    }

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: PreferenceKey.appLockEnabled)
    }

    /// Name of the biometric method available on this device.
    static var biometryName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return String(localized: "Passcode")
        }
    }

    static var biometrySymbol: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }

    func lockIfNeeded() {
        if isEnabled { isLocked = true }
    }

    func unlock() async {
        guard isLocked, !isAuthenticating else { return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        if await Self.authenticate(reason: String(localized: "Unlock your documents")) {
            isLocked = false
        }
    }

    /// Confirms the owner before turning the lock on or off.
    func setEnabled(_ enabled: Bool) async -> Bool {
        let reason = enabled
            ? String(localized: "Turn on app lock")
            : String(localized: "Turn off app lock")
        guard await Self.authenticate(reason: reason) else { return false }
        UserDefaults.standard.set(enabled, forKey: PreferenceKey.appLockEnabled)
        return true
    }

    private static func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return false }
        return (try? await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)) ?? false
    }
}
