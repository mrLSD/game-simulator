//
//  GameScene+Rendering.swift
//  game-simulator
//

import SpriteKit

extension ScreenNode {
    /// Hybrid asset slot: loads a PNG from Assets.xcassets by name, or returns nil
    /// when the slot is empty so the caller can fall back to procedural drawing.
    func loadedTexture(_ name: String) -> SKTexture? {
        if let cached = ScreenNode.imageCache[name] { return cached }
        guard let image = NSImage(named: name), image.size.width > 1, image.size.height > 1 else { return nil }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        ScreenNode.imageCache[name] = texture
        return texture
    }

    /// Asset-slot icon: art from the catalog scaled to fit `size` (aspect kept),
    /// or nil when the slot is empty so the caller draws its procedural fallback.
    func assetIcon(_ name: String, size: CGFloat) -> SKNode? {
        guard let texture = loadedTexture(name) else { return nil }
        let node = SKNode()
        let sprite = SKSpriteNode(texture: texture)
        let textureSize = texture.size()
        let scale = size / max(textureSize.width, textureSize.height)
        sprite.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
        node.addChild(sprite)
        return node
    }

    /// Photo cropped to cover `rect` (aspect-fill), clipped to its bounds.
    func makeCoverPhoto(_ texture: SKTexture, rect: CGRect) -> SKNode {
        let crop = SKCropNode()
        let mask = SKShapeNode(rect: rect)
        mask.fillColor = .white
        mask.strokeColor = .clear
        crop.maskNode = mask

        let textureSize = texture.size()
        let scale = max(rect.width / textureSize.width, rect.height / textureSize.height)
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
        sprite.position = CGPoint(x: rect.midX, y: rect.midY)
        crop.addChild(sprite)
        return crop
    }

    /// Photo world map: NASA day texture with the night-lights texture composited
    /// on the left behind a soft terminator, like the in-game world clock map.
    /// Returns nil when the map.earth.day asset slot is empty.
    func earthMapTexture() -> SKTexture? {
        let cacheKey = "map.earth.composite"
        if let cached = ScreenNode.imageCache[cacheKey] { return cached }

        guard let day = NSImage(named: "map.earth.day"), day.size.width > 1,
              let dayCG = day.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let space = CGColorSpace(name: CGColorSpace.sRGB),
              let ctx = CGContext(data: nil, width: 2400, height: 1200,
                                  bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        let full = CGRect(x: 0, y: 0, width: 2400, height: 1200)
        ctx.interpolationQuality = .high
        ctx.draw(dayCG, in: full)

        if let night = NSImage(named: "map.earth.night"), night.size.width > 1,
           let nightCG = night.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ctx.beginTransparencyLayer(auxiliaryInfo: nil)
            ctx.draw(nightCG, in: full)
            let fadeColors = [
                CGColor(colorSpace: space, components: [0, 0, 0, 1])!,
                CGColor(colorSpace: space, components: [0, 0, 0, 0])!
            ] as CFArray
            if let fade = CGGradient(colorsSpace: space, colors: fadeColors, locations: [0, 1]) {
                ctx.setBlendMode(.destinationIn)
                ctx.drawLinearGradient(
                    fade,
                    start: CGPoint(x: full.width * 0.30, y: 0),
                    end: CGPoint(x: full.width * 0.54, y: 0),
                    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
                )
                ctx.setBlendMode(.normal)
            }
            ctx.endTransparencyLayer()
        }

        guard let composite = ctx.makeImage() else { return nil }
        let texture = SKTexture(cgImage: composite)
        texture.filteringMode = .linear
        ScreenNode.imageCache[cacheKey] = texture
        return texture
    }

    /// Smooth vertical gradient baked into a reusable (cached) texture; top color first.
    func verticalGradientTexture(_ size: CGSize, _ colors: [SKColor], locations: [CGFloat]? = nil) -> SKTexture {
        let w = max(2, size.width.rounded()), h = max(2, size.height.rounded())
        let key = "\(Int(w))x\(Int(h))|" + colors.map(\.cacheKey).joined(separator: ";")
            + "|" + (locations?.map { String(format: "%.2f", $0) }.joined(separator: ",") ?? "")
        if let cached = ScreenNode.gradientCache[key] { return cached }

        let image = NSImage(size: CGSize(width: w, height: h))
        image.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            let space = CGColorSpace(name: CGColorSpace.sRGB)!
            let cgColors = colors.map { $0.cgComponents(in: space) } as CFArray
            if let gradient = CGGradient(colorsSpace: space, colors: cgColors, locations: locations) {
                ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: h), end: .zero,
                                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
            }
        }
        image.unlockFocus()
        let texture = SKTexture(image: image)
        ScreenNode.gradientCache[key] = texture
        return texture
    }

    /// Glossy 3D round button face (no glyph). Reused for +, ?, X and other circular buttons.
    func makeRoundGlossButton(diameter: CGFloat, color: SKColor) -> SKNode {
        let node = SKNode()

        let shadow = SKShapeNode(ellipseOf: CGSize(width: diameter + 2, height: diameter + 2))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.32)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -diameter * 0.06)
        shadow.zPosition = 0
        node.addChild(shadow)

        let ring = SKShapeNode(ellipseOf: CGSize(width: diameter, height: diameter))
        ring.fillColor = color.adjustingBrightness(0.16)
        ring.strokeColor = SKColor.white.withAlphaComponent(0.7)
        ring.lineWidth = max(1, diameter * 0.03)
        ring.zPosition = 1
        node.addChild(ring)

        let innerD = diameter - max(3, diameter * 0.16)
        let sphere = SKShapeNode(ellipseOf: CGSize(width: innerD, height: innerD))
        sphere.fillColor = .white
        sphere.fillTexture = verticalGradientTexture(
            CGSize(width: innerD, height: innerD),
            [color.adjustingBrightness(0.30), color, color.adjustingBrightness(-0.22)]
        )
        sphere.strokeColor = .clear
        sphere.zPosition = 2
        node.addChild(sphere)

        let highlight = SKShapeNode(ellipseOf: CGSize(width: innerD * 0.74, height: innerD * 0.46))
        highlight.fillColor = SKColor.white.withAlphaComponent(0.40)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: innerD * 0.21)
        highlight.zPosition = 3
        node.addChild(highlight)

        return node
    }

    /// Glossy teal banner with beveled gold edges — the section-header ribbon.
    func addRibbonBanner(centerY: CGFloat, height: CGFloat, slant: CGFloat, zBase: CGFloat) {
        let top = centerY + height / 2
        let bottom = centerY - height / 2
        let leftX: CGFloat = -30
        let rightX = size.width + 30

        let path = CGMutablePath()
        path.move(to: CGPoint(x: leftX, y: top))
        path.addLine(to: CGPoint(x: rightX, y: top - slant))
        path.addLine(to: CGPoint(x: rightX, y: bottom))
        path.addLine(to: CGPoint(x: leftX, y: bottom + slant))
        path.closeSubpath()

        let ribbon = SKShapeNode(path: path)
        ribbon.fillColor = .white
        ribbon.fillTexture = verticalGradientTexture(
            CGSize(width: size.width + 60, height: height),
            [SKColor.aircraftHeader.adjustingBrightness(0.18),
             SKColor.aircraftHeader,
             SKColor.aircraftHeader.adjustingBrightness(-0.17)]
        )
        ribbon.strokeColor = .clear
        ribbon.zPosition = zBase
        addChild(ribbon)

        let sheenPath = CGMutablePath()
        sheenPath.move(to: CGPoint(x: leftX, y: top))
        sheenPath.addLine(to: CGPoint(x: rightX, y: top - slant))
        sheenPath.addLine(to: CGPoint(x: rightX, y: top - slant - height * 0.40))
        sheenPath.addLine(to: CGPoint(x: leftX, y: top - height * 0.40))
        sheenPath.closeSubpath()
        let sheen = SKShapeNode(path: sheenPath)
        sheen.fillColor = SKColor.white.withAlphaComponent(0.12)
        sheen.strokeColor = .clear
        sheen.zPosition = zBase + 0.5
        addChild(sheen)

        for isTop in [true, false] {
            let startY = isTop ? top : bottom + slant
            let endY = isTop ? top - slant : bottom

            let edge = CGMutablePath()
            edge.move(to: CGPoint(x: leftX, y: startY))
            edge.addLine(to: CGPoint(x: rightX, y: endY))
            let gold = SKShapeNode(path: edge)
            gold.strokeColor = SKColor.gold
            gold.lineWidth = 5
            gold.zPosition = zBase + 2
            addChild(gold)

            let inset: CGFloat = isTop ? -2.5 : 2.5
            let hlPath = CGMutablePath()
            hlPath.move(to: CGPoint(x: leftX, y: startY + inset))
            hlPath.addLine(to: CGPoint(x: rightX, y: endY + inset))
            let highlight = SKShapeNode(path: hlPath)
            highlight.strokeColor = SKColor.gold.adjustingBrightness(0.30)
            highlight.lineWidth = 1.5
            highlight.zPosition = zBase + 2.1
            addChild(highlight)
        }
    }

    func addButtonChrome(to node: SKNode, size: CGSize, radius: CGFloat) {
        let shadow = SKShapeNode(rectOf: size, cornerRadius: radius)
        shadow.position = CGPoint(x: 4, y: -5)
        shadow.fillColor = SKColor.buttonShadow
        shadow.strokeColor = .clear
        shadow.name = "shadow"
        shadow.zPosition = 0
        node.addChild(shadow)

        let outer = SKShapeNode(rectOf: size, cornerRadius: radius)
        outer.name = "background"
        outer.fillColor = .white
        outer.fillTexture = verticalGradientTexture(size, [
            SKColor.buttonBlue.adjustingBrightness(0.20),
            SKColor.buttonBlue,
            SKColor.buttonBlue.adjustingBrightness(-0.14)
        ])
        outer.strokeColor = SKColor.white.withAlphaComponent(0.55)
        outer.lineWidth = 2
        outer.zPosition = 1
        node.addChild(outer)

        let faceSize = CGSize(width: max(1, size.width - 8), height: max(1, size.height - 8))
        let face = SKShapeNode(rectOf: faceSize, cornerRadius: max(1, radius - 3))
        face.fillColor = .white
        face.fillTexture = verticalGradientTexture(faceSize, [
            SKColor(red: 0.94, green: 0.98, blue: 1.00, alpha: 1),
            SKColor.buttonSurface,
            SKColor(red: 0.56, green: 0.76, blue: 0.87, alpha: 1)
        ])
        face.strokeColor = SKColor.navy.withAlphaComponent(0.10)
        face.lineWidth = 1
        face.position = CGPoint(x: 0, y: 2)
        face.zPosition = 2
        node.addChild(face)

        let gloss = SKShapeNode(rectOf: CGSize(width: max(1, size.width - 14), height: max(1, size.height * 0.32)), cornerRadius: max(1, radius - 5))
        gloss.fillColor = SKColor.white.withAlphaComponent(0.38)
        gloss.strokeColor = .clear
        gloss.position = CGPoint(x: 0, y: size.height * 0.21)
        gloss.zPosition = 2.5
        node.addChild(gloss)

        let lip = SKShapeNode(rectOf: CGSize(width: max(1, size.width - 12), height: max(1, size.height * 0.18)), cornerRadius: max(1, radius - 5))
        lip.fillColor = SKColor.buttonBlue.withAlphaComponent(0.22)
        lip.strokeColor = .clear
        lip.position = CGPoint(x: 0, y: -size.height * 0.32)
        lip.zPosition = 2.6
        node.addChild(lip)
    }

    func makeAvatar(size: CGFloat) -> SKNode {
        if let avatar = assetIcon("avatar.player", size: size) {
            avatar.name = "state.player.avatar"
            return avatar
        }
        let node = SKNode()
        node.name = "state.player.avatar"

        let frame = SKShapeNode(ellipseOf: CGSize(width: size, height: size))
        frame.fillColor = SKColor.orange.withAlphaComponent(0.92)
        frame.strokeColor = SKColor.white.withAlphaComponent(0.92)
        frame.lineWidth = 5
        node.addChild(frame)

        let face = SKShapeNode(ellipseOf: CGSize(width: size * 0.54, height: size * 0.60))
        face.fillColor = SKColor.skin
        face.strokeColor = SKColor.brown.withAlphaComponent(0.4)
        face.lineWidth = 2
        face.position = CGPoint(x: 0, y: size * 0.02)
        face.zPosition = 1
        node.addChild(face)

        let hair = SKShapeNode(ellipseOf: CGSize(width: size * 0.48, height: size * 0.24))
        hair.fillColor = SKColor.darkBrown
        hair.strokeColor = .clear
        hair.position = CGPoint(x: -size * 0.03, y: size * 0.25)
        hair.zPosition = 2
        node.addChild(hair)

        let smilePath = CGMutablePath()
        smilePath.move(to: CGPoint(x: -size * 0.13, y: -size * 0.07))
        smilePath.addQuadCurve(to: CGPoint(x: size * 0.14, y: -size * 0.06), control: CGPoint(x: 0, y: -size * 0.16))
        let smile = SKShapeNode(path: smilePath)
        smile.strokeColor = SKColor.darkBrown
        smile.lineWidth = 2
        smile.zPosition = 3
        node.addChild(smile)

        let levelBadge = SKShapeNode(rectOf: CGSize(width: size * 0.52, height: size * 0.30), cornerRadius: 8)
        levelBadge.fillColor = SKColor.black.withAlphaComponent(0.68)
        levelBadge.strokeColor = SKColor.gold
        levelBadge.lineWidth = 2
        levelBadge.position = CGPoint(x: size * 0.58, y: size * 0.42)
        levelBadge.zPosition = 5
        node.addChild(levelBadge)

        let level = makeLabel("\(gameState.player.level)", size: size * 0.22, color: .white, alignment: .center)
        level.position = levelBadge.position
        level.zPosition = 6
        node.addChild(level)

        return node
    }

    func makeNotificationBadge(size: CGFloat) -> SKNode {
        let node = SKNode()
        let circle = SKShapeNode(ellipseOf: CGSize(width: size, height: size))
        circle.fillColor = SKColor.alertOrange
        circle.strokeColor = SKColor.white.withAlphaComponent(0.9)
        circle.lineWidth = 2
        node.addChild(circle)

        let label = makeLabel("!", size: size * 0.72, color: .white, alignment: .center)
        label.position = .zero
        label.zPosition = 1
        node.addChild(label)
        return node
    }

    func makeLabel(_ text: String, size: CGFloat, color: SKColor, alignment: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        SKLabelNode(themed: text, size: size, color: color, alignment: alignment)
    }

    func makeFittedLabel(
        _ text: String,
        maxWidth: CGFloat,
        maxFontSize: CGFloat,
        minFontSize: CGFloat,
        color: SKColor,
        alignment: SKLabelHorizontalAlignmentMode
    ) -> SKLabelNode {
        let label = makeLabel(text, size: maxFontSize, color: color, alignment: alignment)
        label.fit(maxWidth: maxWidth, minFontSize: minFontSize)
        return label
    }

    func makeStackedLabel(_ lines: [String], maxWidth: CGFloat, maxFontSize: CGFloat, minFontSize: CGFloat, color: SKColor) -> SKNode {
        let node = SKNode()

        // Fit every line, then render the whole stack at the smallest fitted
        // size — per-line fitting leaves each line on its own font size and
        // the stack looks uneven.
        let labels = lines.map { makeLabel($0, size: maxFontSize, color: color, alignment: .center) }
        var commonSize = floor(maxFontSize)
        for label in labels {
            while label.frame.width > maxWidth && label.fontSize > minFontSize {
                label.fontSize -= 1
            }
            commonSize = min(commonSize, label.fontSize)
        }

        // Integer line positions keep the glyphs off subpixel boundaries.
        let lineGap = (commonSize * 1.06).rounded()
        let startY = (lineGap * CGFloat(labels.count - 1) / 2).rounded()
        for (index, label) in labels.enumerated() {
            label.fontSize = commonSize
            label.position = CGPoint(x: 0, y: startY - CGFloat(index) * lineGap)
            node.addChild(label)
        }

        return node
    }
}
