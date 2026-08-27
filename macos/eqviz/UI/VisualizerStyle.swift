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

    /// Display-clock peak profile. Only `sony90s` uses hold + slower gravity.
    var peakGravity: Float {
        switch self {
        case .sony90s: return PeakDecay.sony90sGravity
        default: return PeakDecay.gravity
        }
    }

    var peakHoldDuration: CFTimeInterval {
        switch self {
        case .sony90s: return PeakDecay.sony90sHold
        default: return 0
        }
    }
}
