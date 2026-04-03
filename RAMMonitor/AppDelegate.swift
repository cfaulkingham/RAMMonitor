import Cocoa
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var vm = RAMViewModel()
    private var updateTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Popover
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: PopoverView(vm: vm))
        popover.behavior = .transient
        popover.animates = true

        // Initial label
        updateMenuBarLabel()

        // Refresh menu bar label every 2s
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateMenuBarLabel()
            }
        }

        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    func updateMenuBarLabel() {
        let pct = vm.info.usedPercent
        let used = vm.info.used.formattedGiB()

        if let button = statusItem.button {
            // Color-coded icon dot + text
            let dot = pct < 60 ? "●" : pct < 80 ? "●" : "●"
            let color: NSColor = pct < 60 ? .systemGreen : pct < 80 ? .systemYellow : .systemRed

            let attr = NSMutableAttributedString()

            let dotAttr = NSAttributedString(
                string: dot + " ",
                attributes: [
                    .foregroundColor: color,
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
                ]
            )
            attr.append(dotAttr)

            let label = String(format: "%.0f%%  %@", pct, used)
            let textAttr = NSAttributedString(
                string: label,
                attributes: [
                    .foregroundColor: NSColor.labelColor,
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
                ]
            )
            attr.append(textAttr)

            button.attributedTitle = attr
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        updateTimer?.invalidate()
        vm.stopUpdating()
    }
}
