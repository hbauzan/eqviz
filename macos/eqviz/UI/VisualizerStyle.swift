import Foundation

enum VisualizerStyle: String, CaseIterable, Identifiable {
    case retroRed
    case whiteMatrix
    case rainbowSpectrum
    case fireGradient
    case cyberNeon

    var id: String { rawValue }

    /// Labels locked for the step-10 picker.
    var title: String {
        switch self {
        case .retroRed: return "Retro Red"
        case .whiteMatrix: return "White Matrix"
        case .rainbowSpectrum: return "Rainbow Spectrum"
        case .fireGradient: return "Fire Gradient"
        case .cyberNeon: return "Cyber Neon"
        }
    }
}
