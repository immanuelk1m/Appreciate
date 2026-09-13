import Cocoa
import SwiftUI
import UserNotifications

func reminderNotificationContent(reminder: String) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Appreciate"
    content.body = reminder
    content.sound = .default
    return content
}

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var statusItem: NSStatusItem!
    private var timerManager: TimerManager!
    private let settings = SettingsStore.shared
    private let notificationCenter = UNUserNotificationCenter.current()
    private var settingsWindow: NSWindow?
    private var enabledMenuItem: NSMenuItem!
    private var launchAtLoginMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Activate as accessory (no dock icon)
        NSApp.setActivationPolicy(.accessory)

        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                NSLog("[Appreciate] Notification authorization failed: %@", error.localizedDescription)
            }
        }
        setupMenuBar()
        setupTimer()

        if settings.isEnabled {
            timerManager.start()
        }
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Appreciate")
            button.image?.size = NSSize(width: 18, height: 18)
        }

        let menu = NSMenu()

        let showNowItem = NSMenuItem(title: "✨ Show Now", action: #selector(showNow), keyEquivalent: "s")
        showNowItem.target = self
        menu.addItem(showNowItem)

        menu.addItem(.separator())

        enabledMenuItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "e")
        enabledMenuItem.target = self
        enabledMenuItem.state = settings.isEnabled ? .on : .off
        menu.addItem(enabledMenuItem)

        launchAtLoginMenuItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginMenuItem.target = self
        launchAtLoginMenuItem.state = settings.launchAtLogin ? .on : .off
        menu.addItem(launchAtLoginMenuItem)

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Appreciate", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Timer

    private func setupTimer() {
        timerManager = TimerManager(settings: settings) { [weak self] in
            self?.showReminder()
        }
    }

    private func showReminder() {
        guard settings.isEnabled else { return }
        deliverReminder()
    }

    private func deliverReminder(showSettingsOnFailure: Bool = false) {
        let reminder = settings.nextLine
        guard !reminder.isEmpty else { return }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: reminderNotificationContent(reminder: reminder),
            trigger: nil
        )
        notificationCenter.add(request) { [weak self] error in
            if let error {
                NSLog("[Appreciate] Notification delivery failed: %@", error.localizedDescription)
                if showSettingsOnFailure {
                    DispatchQueue.main.async {
                        self?.showNotificationSettingsAlert()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func showNow() {
        notificationCenter.getNotificationSettings { [weak self] notificationSettings in
            DispatchQueue.main.async {
                guard let self else { return }
                switch notificationSettings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.deliverReminder(showSettingsOnFailure: true)
                case .notDetermined:
                    self.notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            granted ? self.deliverReminder(showSettingsOnFailure: true) : self.showNotificationSettingsAlert()
                        }
                    }
                case .denied:
                    self.showNotificationSettingsAlert()
                @unknown default:
                    self.showNotificationSettingsAlert()
                }
            }
        }
    }

    private func showNotificationSettingsAlert() {
        let alert = NSAlert()
        alert.messageText = "Notifications Are Off"
        alert.informativeText = "Enable notifications for Appreciate in System Settings to show reminders."
        alert.addButton(withTitle: "Open Notification Settings")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func toggleEnabled() {
        settings.isEnabled.toggle()
        enabledMenuItem.state = settings.isEnabled ? .on : .off

        if settings.isEnabled {
            timerManager.start()
        } else {
            timerManager.stop()
        }
    }

    @objc private func toggleLaunchAtLogin() {
        settings.launchAtLogin.toggle()
        launchAtLoginMenuItem.state = settings.launchAtLogin ? .on : .off
    }

    @objc private func openSettings() {
        if let existingWindow = settingsWindow {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(settings: settings) { [weak self] in
            self?.showNow()
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Appreciate Settings"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        settingsWindow = window
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

extension AppDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if (notification.object as? NSWindow) === settingsWindow {
            settingsWindow = nil
            // Restart timer in case intervals changed
            if settings.isEnabled {
                timerManager.restart()
            }
        }
    }
}
