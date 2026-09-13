import Cocoa
import SwiftUI
import UserNotifications

// Test doubles keep this compiled notification-content check independent from
// preferences and notification-center initialization.
final class SettingsStore {
    static let shared = SettingsStore()
    var isEnabled = true
    var launchAtLogin = false
    var randomLine = "오늘 내가 정해둔 내 삶을 살아가고 있는가?"
    var displayDurationSeconds = 0.1
    var minIntervalMinutes = 1.0 / 60.0
    var maxIntervalMinutes = 1.0 / 60.0
}

struct SettingsView: View {
    init(settings: SettingsStore, onShowNow: @escaping () -> Void) {}
    var body: some View { EmptyView() }
}

let reminder = SettingsStore.shared.randomLine
let content = reminderNotificationContent(reminder: reminder)

assert(content.title == "Appreciate")
assert(content.body == reminder)
assert(content.sound != nil)
print("PASS: native notification content includes title, full reminder, and sound")
