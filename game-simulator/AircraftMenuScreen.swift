//
//  AircraftMenuScreen.swift
//  game-simulator
//

import SpriteKit

/// The "Самолет" hub: hero header and the four section cards.
final class AircraftMenuScreen: AircraftScreen {
    override func build() {
        let darkBase = SKShapeNode(rect: canvas)
        darkBase.fillColor = SKColor.aircraftNavy
        darkBase.strokeColor = .clear
        darkBase.zPosition = -100
        addChild(darkBase)

        let heroHeight: CGFloat = 352
        let heroMinY = size.height - heroHeight + 26
        let heroRect = CGRect(x: 0, y: heroMinY, width: size.width, height: heroHeight)
        addAircraftHeroBackground(in: heroRect)

        let contentRect = CGRect(x: 0, y: 0, width: size.width, height: heroMinY)
        let content = SKShapeNode(rect: contentRect)
        content.fillColor = SKColor.aircraftPanel
        content.strokeColor = .clear
        content.zPosition = -20
        addChild(content)

        addAircraftHeader()
        addAircraftCards(contentTop: heroMinY)
        addAircraftBackButton()
        addTopStateLayer(showTimers: false, showAvatar: false)
        refreshAircraftButtonSelection()
    }

    override func handleEscape() {
        gameState.selectedAction = nil
        hoveredAircraftAction = nil
        pressedAircraftAction = nil
        transition(to: .main)
    }
}

extension AircraftMenuScreen {
    func addAircraftHeader() {
        let ribbonHeight: CGFloat = 74
        // Anchored right under the resource bar, same as the list/detail headers.
        let centerY = size.height - 80
        addRibbonBanner(centerY: centerY, height: ribbonHeight, sag: 8, zBase: 5)

        let title = makeFittedLabel("Самолет", maxWidth: 260, maxFontSize: 35, minFontSize: 24, color: .white, alignment: .center)
        title.position = CGPoint(x: size.width * 0.53, y: centerY)
        title.zPosition = 8
        addChild(title)

        // Left header icon: art from the `icon.header.aircraft` slot,
        // procedural plate as a fallback while the slot is empty.
        let sectionIcon: SKNode
        if let icon = assetIcon("icon.header.aircraft", size: 76) {
            sectionIcon = icon
        } else {
            let plate = SKNode()
            addButtonChrome(to: plate, size: CGSize(width: 76, height: 66), radius: 9)
            let glyph = makePlaneIcon(size: 54)
            glyph.zRotation = -CGFloat.pi / 2
            glyph.position = CGPoint(x: 0, y: 2)
            glyph.zPosition = 4
            plate.addChild(glyph)
            sectionIcon = plate
        }
        sectionIcon.position = CGPoint(x: 82, y: centerY + 8)
        sectionIcon.zPosition = 9
        addChild(sectionIcon)

        let help = makeAircraftCircleButton(.help, symbol: "?", diameter: 50)
        help.position = CGPoint(x: size.width - 82, y: centerY + 2)
        help.zPosition = 10
        addChild(help)

        let close = makeAircraftCircleButton(.close, symbol: "X", diameter: 50)
        close.position = CGPoint(x: size.width - 28, y: centerY + 2)
        close.zPosition = 10
        addChild(close)
    }

    func addAircraftCards(contentTop: CGFloat) {
        let cards: [(AircraftMenuAction, [String])] = [
            (.myPlanes, ["Мои самолеты"]),
            (.buyPlanes, ["Приобретение", "самолётов"]),
            (.maintenanceLog, ["Журнал", "обслуживания"]),
            (.liveries, ["Управление", "ливреями"])
        ]
        let cardSize = CGSize(width: 180, height: 230)
        let gap: CGFloat = 6
        let totalWidth = CGFloat(cards.count) * cardSize.width + CGFloat(cards.count - 1) * gap
        var x: CGFloat = 235
        let centerY = contentTop - 180

        for (action, titleLines) in cards {
            let card = makeAircraftCard(action, titleLines: titleLines, size: cardSize)
            card.position = CGPoint(x: x, y: centerY)
            card.zPosition = 20
            addChild(card)
            x += cardSize.width + gap
        }
    }

    private func cardEmoji(for action: AircraftMenuAction) -> String {
        switch action {
        case .myPlanes: return "🌠"
        case .buyPlanes: return "🪁"
        case .maintenanceLog: return "🗓️"
        case .liveries: return "👨🏻‍✈️"
        default: return "✈️"
        }
    }

    func makeAircraftCard(_ action: AircraftMenuAction, titleLines: [String], size: CGSize) -> SKNode {
        let node = SKNode()
        node.name = "aircraft.\(action.rawValue)"
        let metadata = NSMutableDictionary()
        metadata["aircraftAction"] = action.rawValue
        node.userData = metadata

        let imageHeight = size.height - 42

        let cardShadow = SKShapeNode(rectOf: CGSize(width: size.width, height: imageHeight), cornerRadius: 4)
        cardShadow.fillColor = SKColor.black.withAlphaComponent(0.28)
        cardShadow.strokeColor = .clear
        cardShadow.position = CGPoint(x: 3, y: 14)
        cardShadow.zPosition = 0
        node.addChild(cardShadow)

        let panel = SKShapeNode(rectOf: CGSize(width: size.width, height: imageHeight), cornerRadius: 3)
        panel.fillColor = .white
        panel.fillTexture = verticalGradientTexture(CGSize(width: size.width, height: imageHeight), [
            SKColor(red: 0.10, green: 0.50, blue: 0.72, alpha: 1),
            SKColor.aircraftCard,
            SKColor(red: 0.02, green: 0.30, blue: 0.50, alpha: 1)
        ])
        panel.strokeColor = SKColor.white.withAlphaComponent(0.25)
        panel.lineWidth = 1.5
        panel.position = CGPoint(x: 0, y: 18)
        panel.zPosition = 1
        node.addChild(panel)

        let glow = SKShapeNode(ellipseOf: CGSize(width: size.width * 0.80, height: imageHeight * 0.62))
        glow.fillColor = SKColor.white.withAlphaComponent(0.10)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: 0, y: 52)
        glow.zPosition = 2
        node.addChild(glow)

        let sheen = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: imageHeight * 0.42), cornerRadius: 2)
        sheen.fillColor = SKColor.white.withAlphaComponent(0.10)
        sheen.strokeColor = .clear
        sheen.position = CGPoint(x: 0, y: 18 + imageHeight * 0.26)
        sheen.zPosition = 2.5
        node.addChild(sheen)

        let icon = SKLabelNode(text: cardEmoji(for: action))
        icon.fontSize = 120
        icon.horizontalAlignmentMode = .center
        icon.verticalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: 52)
        icon.zPosition = 4
        node.addChild(icon)

        let labelSize = CGSize(width: size.width - 34, height: 45)
        let labelBg = SKShapeNode(rectOf: labelSize, cornerRadius: 18)
        labelBg.fillColor = .white
        labelBg.fillTexture = verticalGradientTexture(labelSize, [
            SKColor(red: 0.97, green: 0.99, blue: 1.00, alpha: 1),
            SKColor.buttonSurface,
            SKColor(red: 0.58, green: 0.76, blue: 0.87, alpha: 1)
        ])
        labelBg.strokeColor = SKColor.white.withAlphaComponent(0.68)
        labelBg.lineWidth = 2
        labelBg.position = CGPoint(x: 0, y: -size.height / 2 + 32)
        labelBg.zPosition = 6
        node.addChild(labelBg)

        // 19pt fits the longest card title without shrinking, so every card
        // renders at the same size (single-line ones included).
        let textNode = makeStackedLabel(titleLines, maxWidth: labelSize.width - 24, maxFontSize: 19, minFontSize: 14, color: SKColor.navy)
        textNode.position = labelBg.position
        textNode.zPosition = 7
        node.addChild(textNode)

        let selected = SKShapeNode(rectOf: CGSize(width: size.width + 4, height: size.height - 10), cornerRadius: 4)
        selected.name = "selection"
        selected.fillColor = .clear
        selected.strokeColor = .clear
        selected.lineWidth = 3
        selected.position = CGPoint(x: 0, y: 2)
        selected.zPosition = 9
        node.addChild(selected)

        aircraftButtons[action] = node
        return node
    }
}
