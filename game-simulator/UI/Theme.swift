//
//  Theme.swift
//  game-simulator
//

import SpriteKit

extension SKColor {
    var rgba: (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        (usingColorSpace(.sRGB) ?? self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    var cacheKey: String {
        let (r, g, b, a) = rgba
        return String(format: "%.3f,%.3f,%.3f,%.3f", r, g, b, a)
    }

    func cgComponents(in space: CGColorSpace) -> CGColor {
        let (r, g, b, a) = rgba
        return CGColor(colorSpace: space, components: [r, g, b, a]) ?? cgColor
    }

    func adjustingBrightness(_ delta: CGFloat) -> SKColor {
        let (r, g, b, a) = rgba
        return SKColor(red: min(1, max(0, r + delta)),
                       green: min(1, max(0, g + delta)),
                       blue: min(1, max(0, b + delta)),
                       alpha: a)
    }

    static let gameBlue = SKColor(red: 0.17, green: 0.65, blue: 0.82, alpha: 1.0)
    static let deepBlue = SKColor(red: 0.00, green: 0.28, blue: 0.48, alpha: 1.0)
    static let mapOcean = SKColor(red: 0.02, green: 0.25, blue: 0.45, alpha: 1.0)
    static let buttonBlue = SKColor(red: 0.08, green: 0.47, blue: 0.72, alpha: 1.0)
    static let buttonSurface = SKColor(red: 0.73, green: 0.86, blue: 0.93, alpha: 1.0)
    static let buttonShadow = SKColor(red: 0.03, green: 0.27, blue: 0.42, alpha: 0.56)
    static let aircraftNavy = SKColor(red: 0.02, green: 0.13, blue: 0.20, alpha: 1.0)
    static let aircraftPanel = SKColor(red: 0.88, green: 0.94, blue: 0.97, alpha: 1.0)
    static let aircraftHeader = SKColor(red: 0.05, green: 0.55, blue: 0.72, alpha: 1.0)
    static let aircraftCard = SKColor(red: 0.05, green: 0.42, blue: 0.63, alpha: 1.0)
    static let navy = SKColor(red: 0.02, green: 0.14, blue: 0.25, alpha: 1.0)
    static let cyan = SKColor(red: 0.00, green: 0.77, blue: 0.94, alpha: 1.0)
    static let gold = SKColor(red: 1.00, green: 0.72, blue: 0.08, alpha: 1.0)
    static let hotPink = SKColor(red: 1.00, green: 0.14, blue: 0.42, alpha: 1.0)
    static let purple = SKColor(red: 0.70, green: 0.20, blue: 0.87, alpha: 1.0)
    static let yellow = SKColor(red: 1.00, green: 0.86, blue: 0.10, alpha: 1.0)
    static let alertOrange = SKColor(red: 1.00, green: 0.31, blue: 0.10, alpha: 1.0)
    static let routeLight = SKColor(red: 1.00, green: 0.86, blue: 0.62, alpha: 1.0)
    static let landGreen = SKColor(red: 0.36, green: 0.62, blue: 0.28, alpha: 1.0)
    static let sand = SKColor(red: 0.77, green: 0.60, blue: 0.32, alpha: 1.0)
    static let skin = SKColor(red: 0.93, green: 0.63, blue: 0.42, alpha: 1.0)
    static let darkBrown = SKColor(red: 0.19, green: 0.09, blue: 0.04, alpha: 1.0)
}

enum Theme {
    static let uiFont = "HelveticaNeue-Bold"
}
