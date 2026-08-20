import AppKit
import SwiftUI

/// Opaque black chrome. Native traffic lights stay visible; window level stays `.normal`.
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        WindowBackingView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class WindowBackingView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configure(window)
    }

    private func configure(_ window: NSWindow?) {
        guard let window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .black
        window.isOpaque = true
        // macOS 14 substitute for SwiftUI `.windowBackgroundDragBehavior` (macOS 15+).
        window.isMovableByWindowBackground = true
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = false
    }
}
