import Foundation
import Darwin

struct RAMInfo {
    let total: UInt64
    let used: UInt64
    let wired: UInt64
    let active: UInt64
    let inactive: UInt64
    let free: UInt64
    let compressed: UInt64

    var usedPercent: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100
    }

    static func current() -> RAMInfo {
        let pageSize = UInt64(vm_page_size)
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        let wired      = result == KERN_SUCCESS ? UInt64(vmStats.wire_count)       * pageSize : 0
        let active     = result == KERN_SUCCESS ? UInt64(vmStats.active_count)     * pageSize : 0
        let inactive   = result == KERN_SUCCESS ? UInt64(vmStats.inactive_count)   * pageSize : 0
        let free       = result == KERN_SUCCESS ? UInt64(vmStats.free_count)       * pageSize : 0
        let compressed = result == KERN_SUCCESS ? UInt64(vmStats.compressor_page_count) * pageSize : 0

        let used = wired + active + compressed
        let total = totalRAM()

        return RAMInfo(
            total: total,
            used: used,
            wired: wired,
            active: active,
            inactive: inactive,
            free: free,
            compressed: compressed
        )
    }

    static func totalRAM() -> UInt64 {
        var size = UInt64(0)
        var sizeLen = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &size, &sizeLen, nil, 0)
        return size
    }
}

extension UInt64 {
    func formattedGiB() -> String {
        let gib = Double(self) / (1024 * 1024 * 1024)
        return String(format: "%.1f GB", gib)
    }

    func formattedMiB() -> String {
        let mib = Double(self) / (1024 * 1024)
        return String(format: "%.0f MB", mib)
    }
}
