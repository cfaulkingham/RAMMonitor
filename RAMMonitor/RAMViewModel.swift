import Foundation
import Combine

@MainActor
final class RAMViewModel: ObservableObject {
    @Published var info: RAMInfo = RAMInfo.current()

    private var timer: Timer?

    init() {
        startUpdating()
    }

    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.info = RAMInfo.current()
            }
        }
        timer?.tolerance = 0.5
    }

    func stopUpdating() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
