import Foundation

enum VisualizerStyle: String, CaseIterable, Identifiable {
    case retroRed
    case whiteMatrix
    case rainbowSpectrum
    case fireGradient
    case cyberNeon
    case sony90s

    var id: String { rawValue }

    /// Labels locked for the style picker.
    var title: String {
        switch self {
        case .retroRed: return "Retro Red"
        case .whiteMatrix: return "White Matrix"
        case .rainbowSpectrum: return "Rainbow Spectrum"
        case .fireGradient: return "Fire Gradient"
        case .cyberNeon: return "Cyber Neon"
        case .sony90s: return "90s Sony"
        }
    }

    /// Half-square tip with hold; bar body always uses the shared legacy peak decay.
    var usesHeldPeakTip: Bool {
        self == .sony90s
    }
}
