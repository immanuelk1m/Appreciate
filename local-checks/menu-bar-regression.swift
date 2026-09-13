import Cocoa
import SwiftUI

// Test doubles keep this compiled AppDelegate check independent from preferences,
// and ServiceManagement login-item registration. The production timer is used.
final class SettingsStore {
    static let shared = SettingsStore()
    var isEnabled = true
    var launchAtLogin = false
    var randomLine = "오늘 내가 정해둔 내 삶을 살아가고 있는가? 메뉴 막대에서 긴 한글 문구의 말줄임과 전체 툴팁을 확인합니다."
    var displayDurationSeconds = 0.1
    var minIntervalMinutes = 1.0 / 60.0
    var maxIntervalMinutes = 1.0 / 60.0
}

struct SettingsView: View {
    init(settings: SettingsStore, onShowNow: @escaping () -> Void) {}
    var body: some View { EmptyView() }
}

func statusItem(from delegate: AppDelegate) -> NSStatusItem {
    guard let item = Mirror(reflecting: delegate).children.first(where: { $0.label == "statusItem" })?.value as? NSStatusItem else {
        fatalError("AppDelegate did not create a status item")
    }
    return item
}

let settings = SettingsStore.shared

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
delegate.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))

let item = statusItem(from: delegate)
let initialWindows = app.windows.count
RunLoop.main.run(until: Date().addingTimeInterval(1.05))
assert(item.button?.title == settings.randomLine)
assert(app.windows.count == initialWindows)
RunLoop.main.run(until: Date().addingTimeInterval(0.12))
assert(item.button?.title == "")

delegate.perform(Selector(("showNow")))
assert(item.button?.title == settings.randomLine)
assert(item.button?.image == nil)
assert(item.button?.toolTip == settings.randomLine)
assert(item.length <= 360)
assert(app.windows.count == initialWindows)

RunLoop.main.run(until: Date().addingTimeInterval(0.06))
delegate.perform(Selector(("showNow")))
RunLoop.main.run(until: Date().addingTimeInterval(0.06))
assert(item.button?.title == settings.randomLine)

RunLoop.main.run(until: Date().addingTimeInterval(0.08))
assert(item.button?.title == "")
assert(item.button?.image != nil)

delegate.perform(Selector(("showNow")))
delegate.perform(Selector(("toggleEnabled")))
assert(item.button?.title == "")
assert(item.button?.image != nil)
print("PASS: menu-bar reminder resets, restores, disables, and creates no windows")
