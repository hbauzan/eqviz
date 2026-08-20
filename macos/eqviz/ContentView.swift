import SwiftUI

struct ContentView: View {
    @State private var engine = AudioEngine()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black
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

#if DEBUG
    private var debugStatus: String {
        if let lastError = engine.lastError {
            return lastError
        }
        if engine.permissionDenied {
            return "permission denied"
        }
        if engine.isRunning {
            return engine.hasSignal ? "running · signal" : "running"
        }
        return "stopped"
    }
#endif
}
