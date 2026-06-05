//
//  GameScene+Icons.swift
//  game-simulator
//

import SpriteKit

extension ScreenNode {
    func makeResourceIcon(_ kind: ResourceKind, size: CGFloat) -> SKNode {
        if let icon = assetIcon("icon.resource.\(kind.rawValue)", size: size) { return icon }
        switch kind {
        case .tickets:
            return makeTicketIcon(size: size, tint: SKColor.hotPink)
        case .credits:
            return makeCircleLetterIcon("C", size: size, fill: SKColor.cyan)
        case .cash:
            return makeCircleLetterIcon("$", size: size, fill: SKColor.gold)
        case .science:
            return makeFlaskIcon(size: size)
        }
    }

    func makeAircraftCardIcon(_ action: AircraftMenuAction, size: CGFloat) -> SKNode {
        switch action {
        case .myPlanes:
            let node = SKNode()
            let topPlane = makePlaneIcon(size: size * 0.58)
            topPlane.position = CGPoint(x: -size * 0.20, y: size * 0.20)
            topPlane.zRotation = -1.08
            topPlane.zPosition = 2
            node.addChild(topPlane)

            let bottomPlane = makePlaneIcon(size: size * 0.78)
            bottomPlane.position = CGPoint(x: size * 0.12, y: -size * 0.18)
            bottomPlane.zRotation = 1.92
            bottomPlane.zPosition = 1
            node.addChild(bottomPlane)
            return node
        case .buyPlanes:
            let node = SKNode()
            let plane = makePlaneIcon(size: size * 0.64)
            plane.zRotation = -2.62
            plane.position = CGPoint(x: -size * 0.28, y: -size * 0.06)
            plane.zPosition = 1
            node.addChild(plane)

            let tagPath = CGMutablePath()
            tagPath.move(to: CGPoint(x: -size * 0.02, y: size * 0.28))
            tagPath.addLine(to: CGPoint(x: size * 0.42, y: size * 0.10))
            tagPath.addLine(to: CGPoint(x: size * 0.24, y: -size * 0.48))
            tagPath.addLine(to: CGPoint(x: -size * 0.20, y: -size * 0.28))
            tagPath.closeSubpath()
            let tag = SKShapeNode(path: tagPath)
            tag.fillColor = SKColor.navy
            tag.strokeColor = SKColor.white.withAlphaComponent(0.45)
            tag.lineWidth = 2
            tag.zPosition = 3
            node.addChild(tag)

            let coin = SKShapeNode(ellipseOf: CGSize(width: size * 0.40, height: size * 0.40))
            coin.fillColor = SKColor.gold
            coin.strokeColor = SKColor.orange
            coin.lineWidth = 3
            coin.position = CGPoint(x: size * 0.26, y: size * 0.32)
            coin.zPosition = 2
            node.addChild(coin)

            let dollar = makeLabel("$", size: size * 0.34, color: SKColor.gold, alignment: .center)
            dollar.position = CGPoint(x: size * 0.07, y: -size * 0.10)
            dollar.zPosition = 4
            node.addChild(dollar)

            let key = makeKeyIcon(size: size * 0.48)
            key.position = CGPoint(x: size * 0.36, y: size * 0.12)
            key.zRotation = -0.74
            key.zPosition = 5
            node.addChild(key)
            return node
        case .maintenanceLog:
            let node = SKNode()
            let book = SKShapeNode(rectOf: CGSize(width: size * 0.98, height: size * 0.72), cornerRadius: size * 0.08)
            book.fillColor = SKColor(red: 0.02, green: 0.48, blue: 0.90, alpha: 1)
            book.strokeColor = SKColor.white.withAlphaComponent(0.76)
            book.lineWidth = 3
            book.position = CGPoint(x: 0, y: -size * 0.03)
            book.zRotation = -0.10
            node.addChild(book)

            for index in 0..<6 {
                let ring = SKShapeNode(ellipseOf: CGSize(width: size * 0.12, height: size * 0.12))
                ring.fillColor = .clear
                ring.strokeColor = SKColor.white.withAlphaComponent(0.76)
                ring.lineWidth = 2
                ring.position = CGPoint(x: -size * 0.35 + CGFloat(index) * size * 0.13, y: size * 0.32)
                ring.zPosition = 2
                node.addChild(ring)
            }

            let wrench = makeWrenchIcon(size: size * 0.78)
            wrench.zRotation = -0.06
            wrench.zPosition = 3
            node.addChild(wrench)
            return node
        case .liveries:
            let node = SKNode()
            let plane = makePlaneIcon(size: size * 0.80)
            plane.zRotation = CGFloat.pi
            plane.position = CGPoint(x: size * 0.10, y: size * 0.06)
            plane.zPosition = 3
            node.addChild(plane)

            let colors: [SKColor] = [.green, .cyan, .blue, .purple, .red, .yellow]
            for (index, color) in colors.enumerated() {
                let stripe = SKShapeNode(rectOf: CGSize(width: size * 0.18, height: size * 0.50), cornerRadius: size * 0.04)
                stripe.fillColor = color
                stripe.strokeColor = .clear
                stripe.position = CGPoint(x: -size * 0.24 + CGFloat(index) * size * 0.10, y: size * 0.02)
                stripe.zRotation = -0.12
                stripe.alpha = 0.88
                stripe.zPosition = 4
                node.addChild(stripe)
            }

            let brush = makeBrushIcon(size: size * 0.50)
            brush.position = CGPoint(x: size * 0.32, y: -size * 0.38)
            brush.zRotation = -1.15
            brush.zPosition = 5
            node.addChild(brush)
            return node
        case .back, .close, .help, .listBack, .listClose, .listHelp, .planeDetails, .detailBack, .detailClose, .detailHelp:
            return SKNode()
        }
    }

    func makeTimedOfferIcon(_ kind: TimedOfferKind, size: CGFloat) -> SKNode {
        if let icon = assetIcon("icon.offer.\(kind.rawValue)", size: size) { return icon }
        switch kind {
        case .shop:
            return makeShoppingBagIcon(size: size, fill: SKColor.purple)
        case .cashBonus:
            return makeCircleLetterIcon("$", size: size, fill: SKColor.gold)
        case .cargoBonus:
            return makeTicketIcon(size: size, tint: SKColor.cyan)
        }
    }

    func makeIcon(for action: MenuAction, size: CGFloat) -> SKNode {
        if let icon = assetIcon("icon.menu.\(action.rawValue)", size: size) { return icon }
        switch action {
        case .routeMap:
            return makeMapPinIcon(size: size)
        case .schedule, .timeControl:
            return makeClockGlyph(size: size, faceColor: .white, handColor: SKColor.navy)
        case .spotlight:
            return makeSpotlightIcon(size: size)
        case .messages:
            return makeMessageIcon(size: size)
        case .newspaper:
            return makeNewspaperIcon(size: size)
        case .tasks:
            return makeTaskIcon(size: size)
        case .globeNetwork:
            return makeGlobeIcon(size: size)
        case .dutyFree:
            return makeShoppingBagIcon(size: size, fill: SKColor.gold)
        case .exchange:
            return makeExchangeIcon(size: size)
        case .tickets:
            return makeTicketIcon(size: size, tint: SKColor.alertOrange)
        case .fleet:
            return makePlaneIcon(size: size)
        case .airport:
            return makeAirportIcon(size: size)
        case .settings:
            return makeGearIcon(size: size)
        }
    }

    func makeCircleLetterIcon(_ text: String, size: CGFloat, fill: SKColor) -> SKNode {
        let node = SKNode()
        let circle = SKShapeNode(ellipseOf: CGSize(width: size, height: size))
        circle.fillColor = fill
        circle.strokeColor = SKColor.white.withAlphaComponent(0.92)
        circle.lineWidth = size * 0.06
        circle.glowWidth = size * 0.04
        node.addChild(circle)

        let label = makeLabel(text, size: size * 0.66, color: .white, alignment: .center)
        label.position = .zero
        label.zPosition = 2
        node.addChild(label)
        return node
    }

    func makeLargeAircraftSilhouette(size: CGFloat) -> SKNode {
        let node = SKNode()

        let fuselage = SKShapeNode(ellipseOf: CGSize(width: size * 0.72, height: size * 0.24))
        fuselage.fillColor = SKColor.white.withAlphaComponent(0.16)
        fuselage.strokeColor = SKColor.white.withAlphaComponent(0.05)
        fuselage.lineWidth = 2
        fuselage.position = CGPoint(x: size * 0.08, y: size * 0.02)
        fuselage.zRotation = -0.06
        node.addChild(fuselage)

        let nose = SKShapeNode(ellipseOf: CGSize(width: size * 0.24, height: size * 0.24))
        nose.fillColor = SKColor.white.withAlphaComponent(0.18)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: -size * 0.27, y: size * 0.03)
        node.addChild(nose)

        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: -size * 0.05, y: -size * 0.02))
        wingPath.addLine(to: CGPoint(x: -size * 0.45, y: -size * 0.19))
        wingPath.addLine(to: CGPoint(x: size * 0.06, y: -size * 0.12))
        wingPath.addLine(to: CGPoint(x: size * 0.22, y: -size * 0.02))
        wingPath.closeSubpath()
        let wing = SKShapeNode(path: wingPath)
        wing.fillColor = SKColor.white.withAlphaComponent(0.12)
        wing.strokeColor = .clear
        node.addChild(wing)

        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: size * 0.38, y: size * 0.04))
        tailPath.addLine(to: CGPoint(x: size * 0.58, y: size * 0.18))
        tailPath.addLine(to: CGPoint(x: size * 0.45, y: -size * 0.02))
        tailPath.closeSubpath()
        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = SKColor.white.withAlphaComponent(0.12)
        tail.strokeColor = .clear
        node.addChild(tail)

        for index in 0..<12 {
            let window = SKShapeNode(rectOf: CGSize(width: size * 0.018, height: size * 0.026), cornerRadius: 1)
            window.fillColor = SKColor.white.withAlphaComponent(0.28)
            window.strokeColor = .clear
            window.position = CGPoint(x: -size * 0.06 + CGFloat(index) * size * 0.035, y: size * 0.075)
            window.zRotation = -0.06
            node.addChild(window)
        }

        let engine = SKShapeNode(ellipseOf: CGSize(width: size * 0.13, height: size * 0.13))
        engine.fillColor = SKColor.black.withAlphaComponent(0.35)
        engine.strokeColor = SKColor.white.withAlphaComponent(0.15)
        engine.lineWidth = 3
        engine.position = CGPoint(x: -size * 0.05, y: -size * 0.14)
        node.addChild(engine)

        return node
    }

    func makeKeyIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let head = SKShapeNode(ellipseOf: CGSize(width: size * 0.34, height: size * 0.34))
        head.fillColor = .clear
        head.strokeColor = SKColor.gold
        head.lineWidth = size * 0.08
        node.addChild(head)

        let stem = SKShapeNode(rectOf: CGSize(width: size * 0.58, height: size * 0.09), cornerRadius: size * 0.03)
        stem.fillColor = SKColor.gold
        stem.strokeColor = .clear
        stem.position = CGPoint(x: size * 0.36, y: 0)
        node.addChild(stem)

        for index in 0..<2 {
            let tooth = SKShapeNode(rectOf: CGSize(width: size * 0.09, height: size * 0.18), cornerRadius: size * 0.02)
            tooth.fillColor = SKColor.gold
            tooth.strokeColor = .clear
            tooth.position = CGPoint(x: size * (0.55 + CGFloat(index) * 0.14), y: -size * 0.08)
            node.addChild(tooth)
        }

        return node
    }

    func makeWrenchIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let handle = SKShapeNode(rectOf: CGSize(width: size * 0.72, height: size * 0.12), cornerRadius: size * 0.05)
        handle.fillColor = .white
        handle.strokeColor = .clear
        handle.zRotation = -0.36
        node.addChild(handle)

        let head = SKShapeNode(ellipseOf: CGSize(width: size * 0.28, height: size * 0.28))
        head.fillColor = .clear
        head.strokeColor = .white
        head.lineWidth = size * 0.08
        head.position = CGPoint(x: size * 0.32, y: size * 0.12)
        head.zRotation = -0.36
        node.addChild(head)

        return node
    }

    func makeBrushIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let handle = SKShapeNode(rectOf: CGSize(width: size * 0.72, height: size * 0.12), cornerRadius: size * 0.04)
        handle.fillColor = SKColor.gold
        handle.strokeColor = SKColor.orange
        handle.lineWidth = 2
        node.addChild(handle)

        let ferrule = SKShapeNode(rectOf: CGSize(width: size * 0.22, height: size * 0.18), cornerRadius: size * 0.03)
        ferrule.fillColor = SKColor.white.withAlphaComponent(0.82)
        ferrule.strokeColor = SKColor.gray
        ferrule.lineWidth = 1
        ferrule.position = CGPoint(x: -size * 0.43, y: 0)
        node.addChild(ferrule)

        let bristles = SKShapeNode(rectOf: CGSize(width: size * 0.22, height: size * 0.24), cornerRadius: size * 0.04)
        bristles.fillColor = SKColor(red: 0.49, green: 0.26, blue: 0.08, alpha: 1)
        bristles.strokeColor = .clear
        bristles.position = CGPoint(x: -size * 0.60, y: -size * 0.02)
        node.addChild(bristles)

        return node
    }

    func makeTicketIcon(size: CGFloat, tint: SKColor) -> SKNode {
        let node = SKNode()
        let ticket = SKShapeNode(rectOf: CGSize(width: size * 0.9, height: size * 0.58), cornerRadius: size * 0.08)
        ticket.fillColor = tint
        ticket.strokeColor = SKColor.white.withAlphaComponent(0.88)
        ticket.lineWidth = size * 0.04
        ticket.zRotation = -0.04
        node.addChild(ticket)

        let notchLeft = SKShapeNode(ellipseOf: CGSize(width: size * 0.14, height: size * 0.14))
        notchLeft.fillColor = SKColor.buttonSurface
        notchLeft.strokeColor = .clear
        notchLeft.position = CGPoint(x: -size * 0.45, y: 0)
        notchLeft.zPosition = 1
        node.addChild(notchLeft)

        let notchRight = notchLeft.copy() as! SKShapeNode
        notchRight.position = CGPoint(x: size * 0.45, y: 0)
        node.addChild(notchRight)

        let label = makeLabel("T", size: size * 0.54, color: .white, alignment: .center)
        label.position = .zero
        label.zPosition = 2
        node.addChild(label)
        return node
    }

    func makeFlaskIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size * 0.12, y: size * 0.34))
        path.addLine(to: CGPoint(x: size * 0.12, y: size * 0.34))
        path.addLine(to: CGPoint(x: size * 0.12, y: size * 0.05))
        path.addLine(to: CGPoint(x: size * 0.36, y: -size * 0.36))
        path.addLine(to: CGPoint(x: -size * 0.36, y: -size * 0.36))
        path.addLine(to: CGPoint(x: -size * 0.12, y: size * 0.05))
        path.closeSubpath()

        let flask = SKShapeNode(path: path)
        flask.fillColor = SKColor.cyan.withAlphaComponent(0.82)
        flask.strokeColor = SKColor.white
        flask.lineWidth = size * 0.05
        node.addChild(flask)

        let liquid = SKShapeNode(rectOf: CGSize(width: size * 0.52, height: size * 0.16), cornerRadius: size * 0.04)
        liquid.fillColor = SKColor.white.withAlphaComponent(0.82)
        liquid.strokeColor = .clear
        liquid.position = CGPoint(x: 0, y: -size * 0.21)
        liquid.zPosition = 1
        node.addChild(liquid)
        return node
    }

    func makeMapPinIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let map = SKShapeNode(rectOf: CGSize(width: size * 0.84, height: size * 0.52), cornerRadius: size * 0.06)
        map.fillColor = SKColor.white
        map.strokeColor = SKColor.cyan
        map.lineWidth = size * 0.04
        map.position = CGPoint(x: 0, y: -size * 0.14)
        node.addChild(map)

        let fold = SKShapeNode(rectOf: CGSize(width: size * 0.04, height: size * 0.50), cornerRadius: 1)
        fold.fillColor = SKColor.cyan.withAlphaComponent(0.45)
        fold.strokeColor = .clear
        fold.position = CGPoint(x: -size * 0.12, y: -size * 0.14)
        node.addChild(fold)

        let pinPath = CGMutablePath()
        pinPath.addArc(center: CGPoint(x: 0, y: size * 0.18), radius: size * 0.19, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: false)
        let pinTop = SKShapeNode(path: pinPath)
        pinTop.fillColor = SKColor.red
        pinTop.strokeColor = .clear
        pinTop.zPosition = 2
        node.addChild(pinTop)

        let point = CGMutablePath()
        point.move(to: CGPoint(x: -size * 0.13, y: size * 0.03))
        point.addLine(to: CGPoint(x: size * 0.13, y: size * 0.03))
        point.addLine(to: CGPoint(x: 0, y: -size * 0.28))
        point.closeSubpath()
        let pointNode = SKShapeNode(path: point)
        pointNode.fillColor = SKColor.red
        pointNode.strokeColor = .clear
        pointNode.zPosition = 2
        node.addChild(pointNode)
        return node
    }

    func makeClockGlyph(size: CGFloat, faceColor: SKColor, handColor: SKColor) -> SKNode {
        let node = SKNode()
        let face = SKShapeNode(ellipseOf: CGSize(width: size, height: size))
        face.fillColor = faceColor
        face.strokeColor = SKColor.navy.withAlphaComponent(0.9)
        face.lineWidth = size * 0.05
        node.addChild(face)

        let minute = SKShapeNode(rectOf: CGSize(width: size * 0.045, height: size * 0.34), cornerRadius: size * 0.02)
        minute.fillColor = handColor
        minute.strokeColor = .clear
        minute.position = CGPoint(x: 0, y: size * 0.13)
        minute.zRotation = -0.52
        minute.zPosition = 1
        node.addChild(minute)

        let hour = SKShapeNode(rectOf: CGSize(width: size * 0.045, height: size * 0.26), cornerRadius: size * 0.02)
        hour.fillColor = handColor
        hour.strokeColor = .clear
        hour.position = CGPoint(x: size * 0.09, y: 0)
        hour.zRotation = -1.45
        hour.zPosition = 1
        node.addChild(hour)

        let center = SKShapeNode(ellipseOf: CGSize(width: size * 0.11, height: size * 0.11))
        center.fillColor = handColor
        center.strokeColor = .clear
        center.zPosition = 2
        node.addChild(center)
        return node
    }

    func makeSpotlightIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let conePath = CGMutablePath()
        conePath.move(to: CGPoint(x: -size * 0.28, y: -size * 0.35))
        conePath.addLine(to: CGPoint(x: size * 0.34, y: -size * 0.24))
        conePath.addLine(to: CGPoint(x: size * 0.08, y: size * 0.12))
        conePath.closeSubpath()
        let cone = SKShapeNode(path: conePath)
        cone.fillColor = SKColor.white.withAlphaComponent(0.9)
        cone.strokeColor = SKColor.navy.withAlphaComponent(0.35)
        cone.lineWidth = size * 0.03
        node.addChild(cone)

        let lamp = SKShapeNode(ellipseOf: CGSize(width: size * 0.42, height: size * 0.30))
        lamp.fillColor = SKColor.cyan
        lamp.strokeColor = SKColor.white
        lamp.lineWidth = size * 0.04
        lamp.position = CGPoint(x: -size * 0.18, y: size * 0.18)
        lamp.zRotation = 0.8
        node.addChild(lamp)
        return node
    }

    func makeMessageIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let bubble = SKShapeNode(rectOf: CGSize(width: size * 0.82, height: size * 0.56), cornerRadius: size * 0.12)
        bubble.fillColor = SKColor.yellow
        bubble.strokeColor = SKColor.white
        bubble.lineWidth = size * 0.04
        node.addChild(bubble)

        let tailPath = CGMutablePath()
        tailPath.move(to: CGPoint(x: -size * 0.18, y: -size * 0.24))
        tailPath.addLine(to: CGPoint(x: -size * 0.32, y: -size * 0.39))
        tailPath.addLine(to: CGPoint(x: -size * 0.04, y: -size * 0.28))
        tailPath.closeSubpath()
        let tail = SKShapeNode(path: tailPath)
        tail.fillColor = SKColor.yellow
        tail.strokeColor = .clear
        node.addChild(tail)

        for index in -1...1 {
            let dot = SKShapeNode(ellipseOf: CGSize(width: size * 0.08, height: size * 0.08))
            dot.fillColor = SKColor.navy
            dot.strokeColor = .clear
            dot.position = CGPoint(x: CGFloat(index) * size * 0.16, y: 0)
            dot.zPosition = 2
            node.addChild(dot)
        }
        return node
    }

    func makeNewspaperIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let paper = SKShapeNode(rectOf: CGSize(width: size * 0.82, height: size * 0.66), cornerRadius: size * 0.04)
        paper.fillColor = SKColor.white
        paper.strokeColor = SKColor.gray
        paper.lineWidth = size * 0.03
        paper.zRotation = -0.18
        node.addChild(paper)

        let title = SKShapeNode(rectOf: CGSize(width: size * 0.55, height: size * 0.08), cornerRadius: 1)
        title.fillColor = SKColor.navy
        title.strokeColor = .clear
        title.position = CGPoint(x: 0, y: size * 0.15)
        title.zRotation = paper.zRotation
        title.zPosition = 1
        node.addChild(title)

        for index in 0..<3 {
            let line = SKShapeNode(rectOf: CGSize(width: size * 0.56, height: size * 0.035), cornerRadius: 1)
            line.fillColor = SKColor.gray.withAlphaComponent(0.8)
            line.strokeColor = .clear
            line.position = CGPoint(x: 0, y: -size * (0.02 + CGFloat(index) * 0.11))
            line.zRotation = paper.zRotation
            line.zPosition = 1
            node.addChild(line)
        }
        return node
    }

    func makeTaskIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let board = SKShapeNode(rectOf: CGSize(width: size * 0.66, height: size * 0.82), cornerRadius: size * 0.08)
        board.fillColor = SKColor.purple
        board.strokeColor = SKColor.white.withAlphaComponent(0.88)
        board.lineWidth = size * 0.04
        node.addChild(board)

        let sheet = SKShapeNode(rectOf: CGSize(width: size * 0.50, height: size * 0.58), cornerRadius: size * 0.03)
        sheet.fillColor = SKColor.white
        sheet.strokeColor = .clear
        sheet.position = CGPoint(x: 0, y: -size * 0.04)
        sheet.zPosition = 1
        node.addChild(sheet)

        let star = makeStar(size: size * 0.34, color: SKColor.gold)
        star.position = CGPoint(x: 0, y: -size * 0.02)
        star.zPosition = 2
        node.addChild(star)
        return node
    }

    func makeGlobeIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let circle = SKShapeNode(ellipseOf: CGSize(width: size, height: size))
        circle.fillColor = SKColor.cyan
        circle.strokeColor = SKColor.white
        circle.lineWidth = size * 0.05
        circle.glowWidth = size * 0.05
        node.addChild(circle)

        for scale in [0.42, 0.72] {
            let meridian = SKShapeNode(ellipseOf: CGSize(width: size * CGFloat(scale), height: size * 0.94))
            meridian.fillColor = .clear
            meridian.strokeColor = SKColor.white.withAlphaComponent(0.84)
            meridian.lineWidth = size * 0.025
            meridian.zPosition = 1
            node.addChild(meridian)
        }

        for y in [-0.24, 0.0, 0.24] {
            let line = SKShapeNode(rectOf: CGSize(width: size * 0.82, height: size * 0.025), cornerRadius: size * 0.01)
            line.fillColor = SKColor.white.withAlphaComponent(0.84)
            line.strokeColor = .clear
            line.position = CGPoint(x: 0, y: size * CGFloat(y))
            line.zPosition = 1
            node.addChild(line)
        }
        return node
    }

    func makeShoppingBagIcon(size: CGFloat, fill: SKColor) -> SKNode {
        let node = SKNode()
        let bag = SKShapeNode(rectOf: CGSize(width: size * 0.68, height: size * 0.62), cornerRadius: size * 0.06)
        bag.fillColor = fill
        bag.strokeColor = SKColor.white.withAlphaComponent(0.9)
        bag.lineWidth = size * 0.04
        bag.position = CGPoint(x: 0, y: -size * 0.08)
        node.addChild(bag)

        let handlePath = CGMutablePath()
        handlePath.move(to: CGPoint(x: -size * 0.20, y: size * 0.20))
        handlePath.addQuadCurve(to: CGPoint(x: size * 0.20, y: size * 0.20), control: CGPoint(x: 0, y: size * 0.50))
        let handle = SKShapeNode(path: handlePath)
        handle.strokeColor = SKColor.white
        handle.lineWidth = size * 0.045
        handle.lineCap = .round
        node.addChild(handle)

        if fill == SKColor.gold {
            let duty = makeFittedLabel("DUTY", maxWidth: size * 0.46, maxFontSize: size * 0.17, minFontSize: size * 0.10, color: .white, alignment: .center)
            duty.position = CGPoint(x: 0, y: -size * 0.12)
            duty.zPosition = 2
            node.addChild(duty)

            let free = makeFittedLabel("FREE", maxWidth: size * 0.46, maxFontSize: size * 0.17, minFontSize: size * 0.10, color: .white, alignment: .center)
            free.position = CGPoint(x: 0, y: -size * 0.28)
            free.zPosition = 2
            node.addChild(free)
        } else {
            let label = makeLabel("$", size: size * 0.30, color: .white, alignment: .center)
            label.position = CGPoint(x: 0, y: -size * 0.08)
            label.zPosition = 2
            node.addChild(label)
        }
        return node
    }

    func makeExchangeIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let plate = SKShapeNode(ellipseOf: CGSize(width: size * 0.84, height: size * 0.58))
        plate.fillColor = SKColor.cyan.withAlphaComponent(0.55)
        plate.strokeColor = SKColor.white.withAlphaComponent(0.9)
        plate.lineWidth = size * 0.04
        plate.position = CGPoint(x: 0, y: -size * 0.08)
        node.addChild(plate)

        for index in 0..<5 {
            let coin = SKShapeNode(ellipseOf: CGSize(width: size * 0.20, height: size * 0.20))
            coin.fillColor = SKColor.gold
            coin.strokeColor = SKColor.white.withAlphaComponent(0.6)
            coin.lineWidth = size * 0.018
            coin.position = CGPoint(x: -size * 0.26 + CGFloat(index) * size * 0.13, y: size * (0.11 - CGFloat(index % 2) * 0.08))
            coin.zPosition = CGFloat(index)
            node.addChild(coin)
        }

        let plane = makePlaneIcon(size: size * 0.46)
        plane.position = CGPoint(x: -size * 0.04, y: -size * 0.18)
        plane.zPosition = 6
        node.addChild(plane)
        return node
    }

    func makePlaneIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size * 0.42))
        path.addLine(to: CGPoint(x: size * 0.17, y: -size * 0.10))
        path.addLine(to: CGPoint(x: size * 0.43, y: -size * 0.32))
        path.addLine(to: CGPoint(x: size * 0.11, y: -size * 0.28))
        path.addLine(to: CGPoint(x: 0, y: -size * 0.43))
        path.addLine(to: CGPoint(x: -size * 0.11, y: -size * 0.28))
        path.addLine(to: CGPoint(x: -size * 0.43, y: -size * 0.32))
        path.addLine(to: CGPoint(x: -size * 0.17, y: -size * 0.10))
        path.closeSubpath()

        let plane = SKShapeNode(path: path)
        plane.fillColor = SKColor.white
        plane.strokeColor = SKColor.navy.withAlphaComponent(0.85)
        plane.lineWidth = size * 0.035
        node.addChild(plane)

        let window = SKShapeNode(ellipseOf: CGSize(width: size * 0.12, height: size * 0.12))
        window.fillColor = SKColor.cyan
        window.strokeColor = .clear
        window.position = CGPoint(x: 0, y: size * 0.08)
        window.zPosition = 1
        node.addChild(window)
        return node
    }

    func makeAirportIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        for index in 0..<3 {
            let building = SKShapeNode(rectOf: CGSize(width: size * 0.21, height: size * CGFloat(0.42 + Double(index) * 0.11)), cornerRadius: size * 0.02)
            building.fillColor = index == 1 ? SKColor.cyan.withAlphaComponent(0.75) : SKColor.white
            building.strokeColor = SKColor.navy.withAlphaComponent(0.45)
            building.lineWidth = size * 0.02
            building.position = CGPoint(x: -size * 0.25 + CGFloat(index) * size * 0.25, y: -size * 0.10)
            node.addChild(building)
        }

        let flagPole = SKShapeNode(rectOf: CGSize(width: size * 0.035, height: size * 0.55), cornerRadius: 1)
        flagPole.fillColor = SKColor.navy
        flagPole.strokeColor = .clear
        flagPole.position = CGPoint(x: size * 0.30, y: size * 0.03)
        node.addChild(flagPole)

        let flagPath = CGMutablePath()
        flagPath.move(to: CGPoint(x: size * 0.32, y: size * 0.25))
        flagPath.addLine(to: CGPoint(x: size * 0.55, y: size * 0.17))
        flagPath.addLine(to: CGPoint(x: size * 0.32, y: size * 0.08))
        flagPath.closeSubpath()
        let flag = SKShapeNode(path: flagPath)
        flag.fillColor = SKColor.cyan
        flag.strokeColor = SKColor.white
        flag.lineWidth = size * 0.02
        node.addChild(flag)
        return node
    }

    func makeGearIcon(size: CGFloat) -> SKNode {
        let node = SKNode()
        for index in 0..<8 {
            let spoke = SKShapeNode(rectOf: CGSize(width: size * 0.11, height: size * 0.25), cornerRadius: size * 0.03)
            spoke.fillColor = SKColor.gray
            spoke.strokeColor = SKColor.white.withAlphaComponent(0.5)
            spoke.lineWidth = size * 0.01
            let angle = CGFloat(index) * CGFloat.pi / 4
            spoke.position = CGPoint(x: cos(angle) * size * 0.27, y: sin(angle) * size * 0.27)
            spoke.zRotation = angle
            node.addChild(spoke)
        }

        let outer = SKShapeNode(ellipseOf: CGSize(width: size * 0.62, height: size * 0.62))
        outer.fillColor = SKColor.gray
        outer.strokeColor = SKColor.white
        outer.lineWidth = size * 0.03
        outer.zPosition = 1
        node.addChild(outer)

        let inner = SKShapeNode(ellipseOf: CGSize(width: size * 0.24, height: size * 0.24))
        inner.fillColor = SKColor.buttonSurface
        inner.strokeColor = .clear
        inner.zPosition = 2
        node.addChild(inner)
        return node
    }

    func makeStar(size: CGFloat, color: SKColor) -> SKNode {
        let path = CGMutablePath()
        let points = 10
        for index in 0..<points {
            let radius = index.isMultiple(of: 2) ? size * 0.5 : size * 0.22
            let angle = CGFloat(index) * CGFloat.pi * 2 / CGFloat(points) - CGFloat.pi / 2
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        let star = SKShapeNode(path: path)
        star.fillColor = color
        star.strokeColor = SKColor.white.withAlphaComponent(0.85)
        star.lineWidth = size * 0.04
        return star
    }
}
