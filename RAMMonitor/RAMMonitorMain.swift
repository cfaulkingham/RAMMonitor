import AppKit

@main
@MainActor
enum RAMMonitorMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()

        app.delegate = delegate
        app.setActivationPolicy(.accessory)   // Menu-bar-only: no Dock icon
        app.run()
    }
}
