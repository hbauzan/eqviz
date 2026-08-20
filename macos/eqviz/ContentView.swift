import SwiftUI

struct ContentView: View {
    @State private var engine = AudioEngine()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 120.0)) { timeline in
            let _ = engine.tickPeaks(at: timeline.date)
            let peaks = engine.peaks.copy()
            ZStack(alignment: .bottomLeading) {
                VisualizerView(peaks: peaks)
                    .ignoresSafeArea()
#if DEBUG
                Text(debugStatus)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(Color(white: 0.4))
                    .padding(8)
#endif
            }
            .frame(minWidth: 400, minHeight: 120)
            .background(WindowConfigurator())
            .task {
                await engine.start()
            }
            .onDisappear {
                engine.stop()
            }
        }
    }

#if DEBUG
    private var debugStatus: String {
        if let lastError = engine.lastError {
            return lastError
        }
        if engine.permissionDenied {
            return "permission denied"
        }
        if engine.isRunning {
            let maxBand = String(format: "%.2f", engine.debugBandMax)
            return engine.hasSignal ? "running · signal · \(maxBand)" : "running · \(maxBand)"
        }
        return "stopped"
    }
#endif
}
