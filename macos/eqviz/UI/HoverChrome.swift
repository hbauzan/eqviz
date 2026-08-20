import SwiftUI

/// Hover-only overlay: style picker. Close/min/zoom are native traffic lights.
struct HoverChrome: View {
    @Binding var style: VisualizerStyle
    var hovering: Bool

    /// Keeps the overlay off the standard close/miniaturize/zoom buttons.
    private static let trafficLightClearance: CGFloat = 78

    var body: some View {
        HStack(spacing: 10) {
            ForEach(VisualizerStyle.allCases) { item in
                Button(item.title) {
                    style = item
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(style == item ? 1 : 0.7))
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.55))
        .padding(.leading, Self.trafficLightClearance)
        .opacity(hovering ? 1 : 0)
        .animation(.easeInOut(duration: 0.18), value: hovering)
        .allowsHitTesting(hovering)
    }
}
