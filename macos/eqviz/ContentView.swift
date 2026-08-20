import SwiftUI

struct ContentView: View {
    @State private var engine = AudioEngine()
    @State private var style: VisualizerStyle = .retroRed
    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .top) {
            TimelineView(.animation(minimumInterval: DisplayClock.frameDuration)) { timeline in
                let _ = engine.tickPeaks(at: timeline.date)
                VisualizerView(peaks: engine.peaks.copy(), style: style)
                    .ignoresSafeArea()
            }
            HoverChrome(style: $style, hovering: hovering)
#if DEBUG
            VStack {
                Spacer()
                HStack {
                    Text(debugStatus)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Color(white: 0.4))
                        .padding(8)
                    Spacer()
                }
            }
            .allowsHitTesting(false)
#endif
        }
        .frame(minWidth: 400, minHeight: 120)
        .background(WindowConfigurator())
        .onHover { hovering = $0 }
        .task {
            await engine.start()
        }
        .onDisappear {
            engine.stop()
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
