import AppKit
import SwiftUI

/// Applies opaque black chrome to the hosting `NSWindow`.
/// Does not raise `window.level` — always-on-top is deferred to step 10.
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
    }
}
