//
//  MainScreen.swift
//  game-simulator
//

import SpriteKit

/// The world-map home screen: resource HUD, route map, rails and the dock.
final class MainScreen: ScreenNode {
    var actionButtons: [MenuAction: SKNode] = [:]
    var pressedAction: MenuAction?
    var hoveredAction: MenuAction?

    override func build() {
        addBackground()
        addMapPanel()
        addTopStateLayer()
        addMenuButtons()
        refreshButtonSelection()
    }

    override func mouseDown(at point: CGPoint) {
        pressedAction = action(at: point)
        setPressed(pressedAction, pressed: true)
    }

    override func mouseDragged(at point: CGPoint) {
        let actionUnderCursor = action(at: point)
        if actionUnderCursor != pressedAction {
            setPressed(pressedAction, pressed: false)
        } else {
            setPressed(pressedAction, pressed: true)
        }
    }

    override func mouseUp(at point: CGPoint) {
        let releasedAction = action(at: point)
        setPressed(pressedAction, pressed: false)

        if let pressedAction, pressedAction == releasedAction {
            activate(pressedAction)
        }

        pressedAction = nil
    }

    override func mouseMoved(at point: CGPoint) {
        super.mouseMoved(at: point)

        let nextHover = action(at: point)
        guard nextHover != hoveredAction else { return }
        hoveredAction = nextHover
        refreshButtonSelection()
    }

    override func handleEscape() {
        gameState.selectedAction = nil
        refreshButtonSelection()
    }
}

extension MainScreen {
    func addBackground() {
        let base = SKShapeNode(rect: canvas)
        base.fillColor = SKColor.gameBlue
        base.strokeColor = .clear
        base.zPosition = -100
        addChild(base)

        let lowerBand = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: max(96, size.height * 0.22)))
        lowerBand.fillColor = SKColor.deepBlue.withAlphaComponent(0.66)
        lowerBand.strokeColor = .clear
        lowerBand.zPosition = -95
        addChild(lowerBand)

        let topMist = SKShapeNode(rect: CGRect(x: 0, y: size.height * 0.72, width: size.width, height: size.height * 0.28))
        topMist.fillColor = SKColor.white.withAlphaComponent(0.38)
        topMist.strokeColor = .clear
        topMist.zPosition = -94
        addChild(topMist)

        for index in 0..<5 {
            let columnWidth = size.width * CGFloat([0.08, 0.12, 0.07, 0.18, 0.11][index])
            let x = size.width * CGFloat([0.16, 0.29, 0.45, 0.68, 0.84][index])
            let column = SKShapeNode(rect: CGRect(x: x, y: 0, width: columnWidth, height: size.height))
            column.fillColor = SKColor.white.withAlphaComponent(index.isMultiple(of: 2) ? 0.10 : 0.06)
            column.strokeColor = .clear
            column.zPosition = -93
            addChild(column)
        }
    }


    func addMapPanel() {
        let rect = mapRect
        let panel = SKNode()
        panel.position = CGPoint(x: rect.midX, y: rect.midY)
        panel.zPosition = 5
        addChild(panel)

        let shadow = SKShapeNode(rectOf: CGSize(width: rect.width + 20, height: rect.height + 20), cornerRadius: 10)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -4)
        shadow.zPosition = -3
        panel.addChild(shadow)

        let frameNode = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height), cornerRadius: 7)
        frameNode.fillColor = .black
        frameNode.strokeColor = SKColor.black
        frameNode.lineWidth = 8
        frameNode.zPosition = -2
        panel.addChild(frameNode)

        let mapSize = CGSize(width: rect.width - 32, height: rect.height - 32)
        let ocean = SKShapeNode(rectOf: mapSize, cornerRadius: 2)
        ocean.fillColor = SKColor.mapOcean
        ocean.strokeColor = SKColor.white.withAlphaComponent(0.16)
        ocean.lineWidth = 2
        panel.addChild(ocean)

        addWorldMap(to: panel, mapSize: mapSize)
        addRoutes(to: panel, mapSize: mapSize)
    }

    func addMenuButtons() {
        addLeftRail()
        addRightRail()
        addBottomDock()
        addFloatingButtons()
    }

    func addLeftRail() {
        let buttonSize = railButtonSize
        let spacing = buttonSize.height + 18
        let startY = size.height - layoutTopHeight - buttonSize.height * 0.5 - 18
        let x = layoutSideInset * 0.5

        for (index, action) in MenuAction.leftRail.enumerated() {
            let button = makeActionButton(action, size: buttonSize)
            button.position = CGPoint(x: x, y: startY - CGFloat(index) * spacing)
            button.zPosition = 40
            addChild(button)
        }
    }

    func addRightRail() {
        let buttonSize = railButtonSize
        let spacing = buttonSize.height + 18
        let startY = size.height - layoutTopHeight - buttonSize.height * 0.5 - 18
        let x = size.width - layoutSideInset * 0.5

        for (index, action) in MenuAction.rightRail.enumerated() {
            let button = makeActionButton(action, size: buttonSize)
            button.position = CGPoint(x: x, y: startY - CGFloat(index) * spacing)
            button.zPosition = 40
            addChild(button)
        }
    }

    func addBottomDock() {
        let bottomY = max(46, layoutBottomHeight * 0.50)
        let largeSize = CGSize(width: 96, height: 86)
        let smallSize = CGSize(width: 62, height: 62)

        let leftActions: [MenuAction] = [.dutyFree, .exchange, .tickets]
        var x = max(28, layoutSideInset * 0.24)
        for (index, action) in leftActions.enumerated() {
            let sizeForButton = index == 0 ? largeSize : smallSize
            let button = makeActionButton(action, size: sizeForButton)
            button.position = CGPoint(x: x + sizeForButton.width / 2, y: bottomY)
            button.zPosition = 45
            addChild(button)
            x += sizeForButton.width + 14
        }

        let rightActions: [MenuAction] = [.timeControl, .fleet, .airport]
        let rightWidths = [largeSize.width, largeSize.width, largeSize.width]
        let rightTotal = rightWidths.reduce(0, +) + CGFloat(rightActions.count - 1) * 20
        var rightX = size.width - max(24, layoutSideInset * 0.24) - rightTotal

        for (index, action) in rightActions.enumerated() {
            let sizeForButton = CGSize(width: rightWidths[index], height: largeSize.height)
            let button = makeActionButton(action, size: sizeForButton)
            button.position = CGPoint(x: rightX + sizeForButton.width / 2, y: bottomY)
            button.zPosition = 45
            addChild(button)
            rightX += sizeForButton.width + 20
        }

        addClockStrip()
    }

    func addFloatingButtons() {
        let settingsSize = CGSize(width: 34, height: 34)
        let settings = makeActionButton(.settings, size: settingsSize, compact: true)
        settings.position = CGPoint(x: size.width - 34, y: size.height - 34)
        settings.zPosition = 55
        addChild(settings)

        let globeSize = CGSize(width: 92, height: 92)
        let globe = makeActionButton(.globeNetwork, size: globeSize)
        globe.position = CGPoint(x: size.width - max(58, layoutSideInset * 0.38), y: layoutBottomHeight + 70)
        globe.zPosition = 50
        addChild(globe)
    }

    func addClockStrip() {
        let stripWidth = min(390, max(300, size.width * 0.25))
        let stripHeight: CGFloat = 32
        let strip = SKNode()
        strip.position = CGPoint(x: size.width * 0.5, y: max(20, layoutBottomHeight * 0.16))
        strip.zPosition = 44
        addChild(strip)

        let bg = SKShapeNode(rectOf: CGSize(width: stripWidth, height: stripHeight), cornerRadius: 2)
        bg.fillColor = SKColor.black.withAlphaComponent(0.86)
        bg.strokeColor = SKColor.white.withAlphaComponent(0.12)
        bg.lineWidth = 1
        strip.addChild(bg)

        let icon = makeClockGlyph(size: stripHeight * 0.88, faceColor: SKColor.white.withAlphaComponent(0.94), handColor: .black)
        icon.position = CGPoint(x: -stripWidth * 0.39, y: 0)
        strip.addChild(icon)

        let label = makeFittedLabel(gameState.clock.displayText, maxWidth: stripWidth * 0.72, maxFontSize: 19, minFontSize: 14, color: .white, alignment: .center)
        label.position = CGPoint(x: 18, y: 0)
        strip.addChild(label)
    }


    func makeActionButton(_ action: MenuAction, size: CGSize, compact: Bool = false) -> SKNode {
        let node = SKNode()
        node.name = "action.\(action.rawValue)"
        let metadata = NSMutableDictionary()
        metadata["action"] = action.rawValue
        node.userData = metadata

        let radius = compact ? min(size.width, size.height) * 0.5 : min(12, min(size.width, size.height) * 0.16)

        if !compact {
            addButtonChrome(to: node, size: size, radius: radius)
        }

        let highlight = SKShapeNode(rectOf: compact ? size : CGSize(width: size.width - 6, height: size.height - 6), cornerRadius: max(1, radius - 3))
        highlight.name = "selection"
        highlight.fillColor = .clear
        highlight.strokeColor = SKColor.clear
        highlight.lineWidth = compact ? 2 : 3
        highlight.zPosition = 8
        node.addChild(highlight)

        let icon = makeIcon(for: action, size: min(size.width, size.height) * (compact ? 0.78 : 0.68))
        icon.zPosition = 3
        node.addChild(icon)

        if action.showsNotification {
            let badge = makeNotificationBadge(size: min(size.width, size.height) * 0.30)
            badge.position = CGPoint(x: size.width * 0.36, y: size.height * 0.33)
            badge.zPosition = 8
            node.addChild(badge)
        }

        actionButtons[action] = node
        return node
    }

    func refreshButtonSelection() {
        for (action, node) in actionButtons {
            let isSelected = action == gameState.selectedAction
            let isHovered = action == hoveredAction
            let stroke = node.childNode(withName: "selection") as? SKShapeNode
            stroke?.strokeColor = isSelected ? SKColor.gold : (isHovered ? SKColor.white.withAlphaComponent(0.75) : .clear)
            stroke?.glowWidth = isSelected ? 5 : (isHovered ? 2 : 0)
        }
    }


    func action(at position: CGPoint) -> MenuAction? {
        for node in nodes(at: position) {
            var current: SKNode? = node
            while let inspected = current {
                if let rawValue = inspected.userData?["action"] as? String,
                   let action = MenuAction(rawValue: rawValue) {
                    return action
                }
                current = inspected.parent
            }
        }
        return nil
    }


    func setPressed(_ action: MenuAction?, pressed: Bool) {
        guard let action, let node = actionButtons[action] else { return }
        setPressedNode(node, pressed: pressed)
    }


    func activate(_ action: MenuAction) {
        if action == .fleet {
            gameState.select(action)
            transition(to: .aircraft)
            return
        }

        if let previous = gameState.selectedAction, previous != action {
            actionButtons[previous]?.removeAllActions()
            actionButtons[previous]?.setScale(1.0)
        }

        gameState.select(action)
        refreshButtonSelection()

        if let node = actionButtons[action] {
            let pulseSize = max(node.calculateAccumulatedFrame().width, node.calculateAccumulatedFrame().height) * 0.9
            let pulse = SKShapeNode(ellipseOf: CGSize(width: pulseSize, height: pulseSize))
            pulse.fillColor = .clear
            pulse.strokeColor = SKColor.gold
            pulse.lineWidth = 3
            pulse.alpha = 0.7
            pulse.zPosition = 20
            node.addChild(pulse)
            pulse.run(.sequence([
                .group([
                    .scale(to: 1.32, duration: 0.24),
                    .fadeOut(withDuration: 0.24)
                ]),
                .removeFromParent()
            ]))
        }

        print("Selected action: \(action.rawValue)")
    }

}

// MARK: - World map drawing

extension MainScreen {
    func addWorldMap(to panel: SKNode, mapSize: CGSize) {
        if let texture = earthMapTexture() {
            let photo = SKSpriteNode(texture: texture)
            photo.size = mapSize
            photo.zPosition = 1
            panel.addChild(photo)
            return
        }

        let landColor = SKColor.landGreen.withAlphaComponent(0.92)
        let desertColor = SKColor.sand.withAlphaComponent(0.9)
        let nightOverlay = SKShapeNode(rectOf: CGSize(width: mapSize.width * 0.52, height: mapSize.height))
        nightOverlay.fillColor = SKColor.black.withAlphaComponent(0.54)
        nightOverlay.strokeColor = .clear
        nightOverlay.position = CGPoint(x: -mapSize.width * 0.24, y: 0)
        nightOverlay.zPosition = 1
        panel.addChild(nightOverlay)

        addLandBlob(to: panel, points: [
            CGPoint(x: 0.07, y: 0.69), CGPoint(x: 0.21, y: 0.77), CGPoint(x: 0.32, y: 0.64),
            CGPoint(x: 0.28, y: 0.44), CGPoint(x: 0.18, y: 0.39), CGPoint(x: 0.09, y: 0.50)
        ], mapSize: mapSize, color: landColor)
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.25, y: 0.38), CGPoint(x: 0.35, y: 0.30), CGPoint(x: 0.32, y: 0.12),
            CGPoint(x: 0.25, y: 0.18), CGPoint(x: 0.20, y: 0.28)
        ], mapSize: mapSize, color: landColor)
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.46, y: 0.72), CGPoint(x: 0.58, y: 0.78), CGPoint(x: 0.66, y: 0.68),
            CGPoint(x: 0.61, y: 0.55), CGPoint(x: 0.49, y: 0.58)
        ], mapSize: mapSize, color: landColor)
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.56, y: 0.58), CGPoint(x: 0.64, y: 0.53), CGPoint(x: 0.62, y: 0.28),
            CGPoint(x: 0.55, y: 0.22), CGPoint(x: 0.51, y: 0.42)
        ], mapSize: mapSize, color: desertColor)
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.62, y: 0.72), CGPoint(x: 0.87, y: 0.74), CGPoint(x: 0.92, y: 0.56),
            CGPoint(x: 0.78, y: 0.46), CGPoint(x: 0.67, y: 0.54)
        ], mapSize: mapSize, color: landColor)
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.72, y: 0.48), CGPoint(x: 0.84, y: 0.42), CGPoint(x: 0.89, y: 0.30),
            CGPoint(x: 0.79, y: 0.22), CGPoint(x: 0.70, y: 0.33)
        ], mapSize: mapSize, color: SKColor.landGreen.withAlphaComponent(0.78))
        addLandBlob(to: panel, points: [
            CGPoint(x: 0.78, y: 0.22), CGPoint(x: 0.90, y: 0.20), CGPoint(x: 0.94, y: 0.12),
            CGPoint(x: 0.86, y: 0.08), CGPoint(x: 0.77, y: 0.12)
        ], mapSize: mapSize, color: SKColor.sand.withAlphaComponent(0.86))
    }

    func addLandBlob(to panel: SKNode, points: [CGPoint], mapSize: CGSize, color: SKColor) {
        guard let first = points.first else { return }
        let path = CGMutablePath()
        path.move(to: mapPoint(first, in: mapSize))
        for point in points.dropFirst() {
            path.addLine(to: mapPoint(point, in: mapSize))
        }
        path.closeSubpath()

        let land = SKShapeNode(path: path)
        land.fillColor = color
        land.strokeColor = SKColor.white.withAlphaComponent(0.10)
        land.lineWidth = 1
        land.zPosition = 2
        panel.addChild(land)
    }

    func addRoutes(to panel: SKNode, mapSize: CGSize) {
        // Equirectangular coords: x = (lon + 180) / 360, y = (lat + 90) / 180.
        let hub = CGPoint(x: 0.586, y: 0.780)               // Kyiv KBP
        let destinations = [
            CGPoint(x: 0.499, y: 0.786), CGPoint(x: 0.507, y: 0.772), // London, Paris
            CGPoint(x: 0.490, y: 0.725), CGPoint(x: 0.534, y: 0.732), // Madrid, Rome
            CGPoint(x: 0.580, y: 0.728), CGPoint(x: 0.295, y: 0.726), // Istanbul, New York
            CGPoint(x: 0.371, y: 0.370), CGPoint(x: 0.337, y: 0.307), // São Paulo, Buenos Aires
            CGPoint(x: 0.654, y: 0.640), CGPoint(x: 0.714, y: 0.659), // Dubai, Delhi
            CGPoint(x: 0.824, y: 0.723), CGPoint(x: 0.888, y: 0.698)  // Beijing, Tokyo
        ]

        for (index, destination) in destinations.enumerated() {
            let route = makeRoute(from: hub, to: destination, mapSize: mapSize, bend: index.isMultiple(of: 2) ? 0.10 : -0.08)
            route.zPosition = 6
            route.alpha = 0.55
            panel.addChild(route)
        }

        for destination in destinations + [hub] {
            let city = SKShapeNode(ellipseOf: CGSize(width: 8, height: 8))
            city.fillColor = SKColor.routeLight
            city.strokeColor = SKColor.white
            city.lineWidth = 1
            city.position = mapPoint(destination, in: mapSize)
            city.zPosition = 7
            city.glowWidth = 2
            panel.addChild(city)
        }
    }

    func makeRoute(from start: CGPoint, to end: CGPoint, mapSize: CGSize, bend: CGFloat) -> SKShapeNode {
        let startPoint = mapPoint(start, in: mapSize)
        let endPoint = mapPoint(end, in: mapSize)
        let midpoint = CGPoint(x: (startPoint.x + endPoint.x) * 0.5, y: (startPoint.y + endPoint.y) * 0.5)
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let control = CGPoint(x: midpoint.x - dy * bend, y: midpoint.y + dx * bend + mapSize.height * 0.08)

        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: control)

        let route = SKShapeNode(path: path)
        route.strokeColor = SKColor.white.withAlphaComponent(0.74)
        route.lineWidth = 2.2
        route.glowWidth = 2
        route.lineCap = .round
        return route
    }

    func mapPoint(_ normalizedPoint: CGPoint, in mapSize: CGSize) -> CGPoint {
        CGPoint(
            x: -mapSize.width / 2 + normalizedPoint.x * mapSize.width,
            y: -mapSize.height / 2 + normalizedPoint.y * mapSize.height
        )
    }
}
