import SwiftUI

struct PopoverView: View {
    @ObservedObject var vm: RAMViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Memory")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("\(vm.info.used.formattedGiB()) of \(vm.info.total.formattedGiB()) used")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Spacer()
                CircleGauge(percent: vm.info.usedPercent)
                    .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            // Breakdown
            VStack(spacing: 0) {
                RAMRow(label: "App Memory",   value: vm.info.active,     color: .blue)
                RAMRow(label: "Wired",        value: vm.info.wired,      color: .orange)
                RAMRow(label: "Compressed",   value: vm.info.compressed, color: .purple)
                RAMRow(label: "Inactive",     value: vm.info.inactive,   color: Color(.tertiaryLabelColor))
                RAMRow(label: "Free",         value: vm.info.free,       color: Color(.tertiaryLabelColor))
            }
            .padding(.vertical, 6)

            Divider()

            // Pressure bar
            VStack(alignment: .leading, spacing: 6) {
                Text("PRESSURE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.8)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.quaternaryLabelColor))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(pressureColor)
                            .frame(width: geo.size.width * CGFloat(vm.info.usedPercent / 100), height: 6)
                            .animation(.easeOut(duration: 0.4), value: vm.info.usedPercent)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            // Footer
            HStack {
                Text("Updates every 2s")
                    .font(.system(size: 10))
                    .foregroundColor(Color(.tertiaryLabelColor))
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(width: 260)
        .background(Color(.windowBackgroundColor))
    }

    var pressureColor: Color {
        switch vm.info.usedPercent {
        case ..<60:  return .green
        case ..<80:  return .yellow
        default:     return .red
        }
    }
}

// MARK: - Row

struct RAMRow: View {
    let label: String
    let value: UInt64
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.primary)
            Spacer()
            Text(value.formattedGiB())
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

// MARK: - Circle Gauge

struct CircleGauge: View {
    let percent: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.quaternaryLabelColor), lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(percent / 100))
                .stroke(gaugeColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: percent)
            Text(String(format: "%.0f%%", percent))
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.primary)
        }
    }

    var gaugeColor: Color {
        switch percent {
        case ..<60:  return .green
        case ..<80:  return .yellow
        default:     return .red
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        PopoverView(vm: RAMViewModel())
    }
}
