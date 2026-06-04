//
//  SKLabelNode+Fitting.swift
//  game-simulator
//

import SpriteKit

extension SKLabelNode {
    /// Project-styled label: UI font, integer point size (crisper glyphs),
    /// vertically centered.
    convenience init(themed text: String, size: CGFloat, color: SKColor, alignment: SKLabelHorizontalAlignmentMode) {
        self.init(fontNamed: Theme.uiFont)
        self.text = text
        fontSize = floor(size)
        fontColor = color
        horizontalAlignmentMode = alignment
        verticalAlignmentMode = .center
    }

    /// Shrinks the font in integer steps until the text fits `maxWidth`,
    /// never going below `minFontSize`.
    func fit(maxWidth: CGFloat, minFontSize: CGFloat) {
        while frame.width > maxWidth && fontSize > minFontSize {
            fontSize -= 1
        }
    }
}
