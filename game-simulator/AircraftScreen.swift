//
//  AircraftScreen.swift
//  game-simulator
//

import SpriteKit

/// Shared chrome and input for the three aircraft screens (menu, list, detail):
/// gold ribbon header, hero background, circle/back buttons, press & hover state.
class AircraftScreen: ScreenNode {
    var aircraftButtons: [AircraftMenuAction: SKNode] = [:]
    var pressedAircraftAction: AircraftMenuAction?
    weak var pressedAircraftNode: SKNode?
    var hoveredAircraftAction: AircraftMenuAction?
    weak var hoveredAircraftNode: SKNode?

    /// Subclasses react to taps on their own buttons here.
    func activate(_ action: AircraftMenuAction) {
        switch action {
        case .back, .close, .listClose, .detailClose:
            gameState.selectedAction = nil
            transition(to: .main)
        case .myPlanes:
            transition(to: .aircraftList)
        case .listBack:
            transition(to: .aircraft)
        case .planeDetails:
            transition(to: .aircraftDetail)
        case .detailBack:
            transition(to: .aircraftList)
        case .help, .listHelp, .detailHelp, .buyPlanes, .maintenanceLog, .liveries:
            print("Aircraft action selected: \(action.rawValue)")
            pulseAircraftButton(action)
        }
    }

    override func mouseDown(at point: CGPoint) {
        let hit = aircraftHit(at: point)
        pressedAircraftAction = hit?.action
        pressedAircraftNode = hit?.node
        if let node = pressedAircraftNode {
            setPressedNode(node, pressed: true)
        }
    }

    override func mouseDragged(at point: CGPoint) {
        let hit = aircraftHit(at: point)
        if hit?.node === pressedAircraftNode {
            if let node = pressedAircraftNode {
                setPressedNode(node, pressed: true)
            }
        } else {
            if let node = pressedAircraftNode {
                setPressedNode(node, pressed: false)
            }
        }
    }

    override func mouseUp(at point: CGPoint) {
        let releasedHit = aircraftHit(at: point)
        if let node = pressedAircraftNode {
            setPressedNode(node, pressed: false)
        }

        if let pressedAircraftAction,
           let releasedHit,
           pressedAircraftAction == releasedHit.action,
           releasedHit.node === pressedAircraftNode
        {
            activate(pressedAircraftAction)
        }

        pressedAircraftAction = nil
        pressedAircraftNode = nil
    }

    override func mouseMoved(at point: CGPoint) {
        updateAircraftHover(with: aircraftHit(at: point))
    }
}

extension AircraftScreen {
    func refreshAircraftButtonSelection() {
        for (action, node) in aircraftButtons {
            let isHovered = action == hoveredAircraftAction
            let stroke = node.childNode(withName: "selection") as? SKShapeNode
            stroke?.strokeColor = isHovered ? SKColor.white.withAlphaComponent(0.82) : .clear
            stroke?.glowWidth = isHovered ? 2 : 0
        }
        setHoverNode(hoveredAircraftNode, hovered: true)
    }

    func aircraftAction(at position: CGPoint) -> AircraftMenuAction? {
        aircraftHit(at: position)?.action
    }

    func aircraftHit(at position: CGPoint) -> (action: AircraftMenuAction, node: SKNode)? {
        for node in nodes(at: position) {
            var current: SKNode? = node
            while let inspected = current {
                if let rawValue = inspected.userData?["aircraftAction"] as? String,
                   let action = AircraftMenuAction(rawValue: rawValue)
                {
                    return (action, inspected)
                }
                current = inspected.parent
            }
        }
        return nil
    }

    func setPressed(_ action: AircraftMenuAction?, pressed: Bool) {
        guard let action, let node = aircraftButtons[action] else { return }
        setPressedNode(node, pressed: pressed)
    }

    func setHoverNode(_ node: SKNode?, hovered: Bool) {
        let stroke = node?.childNode(withName: "selection") as? SKShapeNode
        stroke?.strokeColor = hovered ? SKColor.white.withAlphaComponent(0.82) : .clear
        stroke?.glowWidth = hovered ? 2 : 0
    }

    func updateAircraftHover(with hit: (action: AircraftMenuAction, node: SKNode)?) {
        if hoveredAircraftNode === hit?.node {
            return
        }

        setHoverNode(hoveredAircraftNode, hovered: false)
        hoveredAircraftAction = hit?.action
        hoveredAircraftNode = hit?.node
        setHoverNode(hoveredAircraftNode, hovered: true)
    }

    func pulseAircraftButton(_ action: AircraftMenuAction) {
        guard let node = aircraftButtons[action] else { return }
        let frame = node.calculateAccumulatedFrame()
        let pulse = SKShapeNode(rectOf: CGSize(width: frame.width * 0.92, height: frame.height * 0.92), cornerRadius: 8)
        pulse.fillColor = .clear
        pulse.strokeColor = SKColor.gold
        pulse.lineWidth = 3
        pulse.alpha = 0.75
        pulse.zPosition = 30
        node.addChild(pulse)
        pulse.run(.sequence([
            .group([
                .scale(to: 1.08, duration: 0.18),
                .fadeOut(withDuration: 0.18)
            ]),
            .removeFromParent()
        ]))
    }

    func addAircraftSectionHeader(
        title: String,
        leftTitle: String,
        helpAction: AircraftMenuAction,
        closeAction: AircraftMenuAction,
        showClock: Bool
    ) {
        let ribbonHeight: CGFloat = 74
        let centerY = size.height - layoutTopHeight + 2
        addRibbonBanner(centerY: centerY, height: ribbonHeight, slant: 16, zBase: 6)

        let sectionIcon = makeAircraftCardIcon(.myPlanes, size: 104)
        sectionIcon.position = CGPoint(x: 82, y: centerY + 6)
        sectionIcon.zPosition = 10
        addChild(sectionIcon)

        let left = makeFittedLabel(leftTitle, maxWidth: 180, maxFontSize: 31, minFontSize: 18, color: SKColor.gold, alignment: .left)
        left.position = CGPoint(x: 146, y: centerY + 2)
        left.zPosition = 11
        addChild(left)

        let centerMaxWidth = showClock ? min(240, size.width * 0.24) : min(360, size.width * 0.38)
        let titleLabel = makeFittedLabel(title, maxWidth: centerMaxWidth, maxFontSize: 31, minFontSize: 21, color: .white, alignment: .center)
        titleLabel.position = CGPoint(x: size.width * (showClock ? 0.475 : 0.52), y: centerY + 2)
        titleLabel.zPosition = 11
        addChild(titleLabel)

        if showClock {
            addAircraftClockBadge(center: CGPoint(x: size.width - 280, y: centerY + 2), width: 230)
        }

        let help = makeAircraftCircleButton(helpAction, symbol: "?", diameter: 50)
        help.position = CGPoint(x: size.width - 106, y: centerY + 2)
        help.zPosition = 12
        addChild(help)

        let close = makeAircraftCircleButton(closeAction, symbol: "X", diameter: 50)
        close.position = CGPoint(x: size.width - 52, y: centerY + 2)
        close.zPosition = 12
        addChild(close)
    }

    func addAircraftClockBadge(center: CGPoint, width: CGFloat) {
        let node = SKNode()
        node.position = center
        node.zPosition = 12
        addChild(node)

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: 34), cornerRadius: 1)
        bg.fillColor = SKColor.black.withAlphaComponent(0.84)
        bg.strokeColor = SKColor.white.withAlphaComponent(0.12)
        bg.lineWidth = 1
        node.addChild(bg)

        let clock = makeClockGlyph(size: 35, faceColor: .white, handColor: SKColor.navy)
        clock.position = CGPoint(x: -width / 2 + 32, y: 0)
        clock.zPosition = 2
        node.addChild(clock)

        let label = makeFittedLabel(gameState.clock.displayText, maxWidth: width - 72, maxFontSize: 22, minFontSize: 15, color: .white, alignment: .center)
        label.position = CGPoint(x: 26, y: 0)
        label.zPosition = 2
        node.addChild(label)
    }

    func addAircraftHeroBackground(in rect: CGRect) {
        if let texture = loadedTexture("photo.hero.aircraft") {
            let photo = makeCoverPhoto(texture, rect: rect)
            photo.zPosition = -70
            addChild(photo)

            let shade = SKShapeNode(rect: rect)
            shade.fillColor = SKColor.aircraftNavy.withAlphaComponent(0.32)
            shade.strokeColor = .clear
            shade.zPosition = -45
            addChild(shade)
            return
        }

        let hero = SKShapeNode(rect: rect)
        hero.fillColor = SKColor(red: 0.02, green: 0.16, blue: 0.24, alpha: 1)
        hero.strokeColor = .clear
        hero.zPosition = -70
        addChild(hero)

        let glow = SKShapeNode(ellipseOf: CGSize(width: rect.width * 0.62, height: rect.height * 0.85))
        glow.fillColor = SKColor.buttonBlue.withAlphaComponent(0.14)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: rect.midX + rect.width * 0.28, y: rect.midY + 4)
        glow.zPosition = -68
        addChild(glow)

        for index in 0 ..< 18 {
            let light = SKShapeNode(ellipseOf: CGSize(width: 4, height: 4))
            light.fillColor = SKColor.white.withAlphaComponent(0.32)
            light.strokeColor = .clear
            light.position = CGPoint(
                x: CGFloat(index) * rect.width / 17,
                y: rect.minY + rect.height * (0.22 + CGFloat(index % 3) * 0.012)
            )
            light.zPosition = -64
            addChild(light)
        }

        let worker = SKNode()
        worker.position = CGPoint(x: rect.width * 0.33, y: rect.minY + rect.height * 0.25)
        worker.zPosition = -55
        addChild(worker)

        let body = SKShapeNode(rectOf: CGSize(width: 22, height: 76), cornerRadius: 7)
        body.fillColor = SKColor.white.withAlphaComponent(0.28)
        body.strokeColor = .clear
        body.position = CGPoint(x: 0, y: 42)
        worker.addChild(body)

        let head = SKShapeNode(ellipseOf: CGSize(width: 22, height: 22))
        head.fillColor = SKColor.white.withAlphaComponent(0.24)
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: 92)
        worker.addChild(head)

        let armPath = CGMutablePath()
        armPath.move(to: CGPoint(x: -5, y: 76))
        armPath.addLine(to: CGPoint(x: -88, y: 108))
        armPath.move(to: CGPoint(x: 5, y: 76))
        armPath.addLine(to: CGPoint(x: 88, y: 118))
        let arms = SKShapeNode(path: armPath)
        arms.strokeColor = SKColor.white.withAlphaComponent(0.26)
        arms.lineWidth = 5
        arms.lineCap = .round
        worker.addChild(arms)

        let plane = makeLargeAircraftSilhouette(size: rect.width * 0.58)
        plane.position = CGPoint(x: rect.width * 0.78, y: rect.minY + rect.height * 0.46)
        plane.zPosition = -52
        addChild(plane)

        let shade = SKShapeNode(rect: rect)
        shade.fillColor = SKColor.aircraftNavy.withAlphaComponent(0.46)
        shade.strokeColor = .clear
        shade.zPosition = -45
        addChild(shade)
    }

    func addAircraftBackButton(
        _ action: AircraftMenuAction = .back,
        position: CGPoint = CGPoint(x: 82, y: 52),
        size: CGSize = CGSize(width: 116, height: 48)
    ) {
        let node = SKNode()
        node.name = "aircraft.\(action.rawValue)"
        let metadata = NSMutableDictionary()
        metadata["aircraftAction"] = action.rawValue
        node.userData = metadata

        let shadow = SKShapeNode(rectOf: size, cornerRadius: 22)
        shadow.fillColor = SKColor.buttonShadow
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: -4)
        node.addChild(shadow)

        let bg = SKShapeNode(rectOf: size, cornerRadius: 22)
        bg.fillColor = SKColor.buttonBlue
        bg.strokeColor = SKColor.white.withAlphaComponent(0.54)
        bg.lineWidth = 3
        bg.zPosition = 1
        node.addChild(bg)

        let face = SKShapeNode(rectOf: CGSize(width: size.width - 10, height: size.height - 10), cornerRadius: 18)
        face.fillColor = SKColor(red: 0.06, green: 0.38, blue: 0.58, alpha: 1)
        face.strokeColor = .clear
        face.zPosition = 2
        node.addChild(face)

        let arrow = makeLabel("←", size: 42, color: .white, alignment: .center)
        arrow.position = CGPoint(x: -3, y: 1)
        arrow.zPosition = 3
        node.addChild(arrow)

        let selection = SKShapeNode(rectOf: size, cornerRadius: 22)
        selection.name = "selection"
        selection.fillColor = .clear
        selection.strokeColor = .clear
        selection.lineWidth = 3
        selection.zPosition = 5
        node.addChild(selection)

        node.position = position
        node.zPosition = 22
        aircraftButtons[action] = node
        addChild(node)
    }

    func makeAircraftCircleButton(_ action: AircraftMenuAction, symbol: String, diameter: CGFloat) -> SKNode {
        let node = SKNode()
        node.name = "aircraft.\(action.rawValue)"
        let metadata = NSMutableDictionary()
        metadata["aircraftAction"] = action.rawValue
        node.userData = metadata

        let face = makeRoundGlossButton(diameter: diameter, color: SKColor.buttonBlue)
        face.zPosition = 1
        node.addChild(face)

        let label = makeLabel(symbol, size: symbol == "X" ? 26 : 30, color: .white, alignment: .center)
        label.zPosition = 4
        node.addChild(label)

        let selection = SKShapeNode(ellipseOf: CGSize(width: diameter + 4, height: diameter + 4))
        selection.name = "selection"
        selection.fillColor = .clear
        selection.strokeColor = .clear
        selection.lineWidth = 3
        selection.zPosition = 5
        node.addChild(selection)

        aircraftButtons[action] = node
        return node
    }

    func makeUkraineFlag(size: CGSize) -> SKNode {
        let node = SKNode()
        let top = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height / 2), cornerRadius: 0)
        top.fillColor = SKColor(red: 0.00, green: 0.34, blue: 0.70, alpha: 1)
        top.strokeColor = .clear
        top.position = CGPoint(x: 0, y: size.height / 4)
        node.addChild(top)

        let bottom = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height / 2), cornerRadius: 0)
        bottom.fillColor = SKColor(red: 1.00, green: 0.84, blue: 0.10, alpha: 1)
        bottom.strokeColor = .clear
        bottom.position = CGPoint(x: 0, y: -size.height / 4)
        node.addChild(bottom)
        return node
    }
}
