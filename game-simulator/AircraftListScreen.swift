//
//  AircraftListScreen.swift
//  game-simulator
//

import SpriteKit

/// The scrollable fleet table with its filter toolbar.
final class AircraftListScreen: AircraftScreen {
    let planeRows = GameState.demoPlaneRows

    var planeListViewportRect: CGRect = .zero
    var planeListContentNode: SKNode?
    var planeListScrollOffset: CGFloat = 0
    var planeListScrollMax: CGFloat = 0
    var planeListDragStartY: CGFloat?
    var planeListDragStartOffset: CGFloat = 0
    var planeListDidDrag = false

    override func build() {
        let darkBase = SKShapeNode(rect: canvas)
        darkBase.fillColor = SKColor.aircraftNavy
        darkBase.strokeColor = .clear
        darkBase.zPosition = -100
        addChild(darkBase)

        let heroRect = CGRect(x: 0, y: size.height - 440, width: size.width, height: 330)
        addAircraftHeroBackground(in: heroRect)

        let content = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: heroRect.minY + 6))
        content.fillColor = SKColor.aircraftPanel
        content.strokeColor = .clear
        content.zPosition = -22
        addChild(content)

        addAircraftSectionHeader(title: "Список самолетов", leftTitle: "Мои самолеты", helpAction: .listHelp, closeAction: .listClose, showClock: true)

        let tableHeaderRect = CGRect(x: 32, y: size.height - 252, width: size.width - 64, height: 56)
        addPlaneTableHeader(in: tableHeaderRect)

        let toolbarHeight: CGFloat = 64
        let viewport = CGRect(
            x: tableHeaderRect.minX,
            y: toolbarHeight + 12,
            width: tableHeaderRect.width,
            height: tableHeaderRect.minY - toolbarHeight - 12
        )
        addPlaneListRows(in: viewport)
        addPlaneListToolbar()
        addTopStateLayer(showTimers: false, showAvatar: false)
        refreshAircraftButtonSelection()
    }

    override func mouseDown(at point: CGPoint) {
        super.mouseDown(at: point)

        if planeListViewportRect.contains(point) {
            planeListDragStartY = point.y
            planeListDragStartOffset = planeListScrollOffset
            planeListDidDrag = false
        } else {
            planeListDragStartY = nil
            planeListDidDrag = false
        }
    }

    override func mouseDragged(at point: CGPoint) {
        if let startY = planeListDragStartY {
            let delta = point.y - startY
            if abs(delta) > 4 {
                planeListDidDrag = true
                if let node = pressedAircraftNode {
                    setPressedNode(node, pressed: false)
                }
            }
            // Direct manipulation: content follows the cursor. Dragging the
            // mouse down pulls the rows down (reveals rows above).
            updatePlaneListScroll(to: planeListDragStartOffset + delta)
            return
        }

        super.mouseDragged(at: point)
    }

    override func mouseUp(at point: CGPoint) {
        let releasedHit = aircraftHit(at: point)
        if let node = pressedAircraftNode {
            setPressedNode(node, pressed: false)
        }

        if !planeListDidDrag,
           let pressedAircraftAction,
           let releasedHit,
           pressedAircraftAction == releasedHit.action,
           releasedHit.node === pressedAircraftNode {
            activate(pressedAircraftAction)
        }

        pressedAircraftAction = nil
        pressedAircraftNode = nil
        planeListDragStartY = nil
        planeListDidDrag = false
    }

    override func handleEscape() {
        transition(to: .aircraft)
    }

    func updatePlaneListScroll(to proposedOffset: CGFloat) {
        let clampedOffset = min(max(proposedOffset, 0), planeListScrollMax)
        planeListScrollOffset = clampedOffset
        planeListContentNode?.position.y = clampedOffset
    }
}

extension AircraftListScreen {
    func addPlaneTableHeader(in rect: CGRect) {
        let header = SKNode()
        header.position = CGPoint(x: rect.midX, y: rect.midY)
        header.zPosition = 18
        addChild(header)

        let bg = SKShapeNode(rectOf: rect.size, cornerRadius: 0)
        bg.fillColor = .white
        bg.fillTexture = verticalGradientTexture(rect.size, [
            SKColor(red: 0.10, green: 0.48, blue: 0.68, alpha: 1),
            SKColor(red: 0.04, green: 0.30, blue: 0.50, alpha: 1)
        ])
        bg.strokeColor = .clear
        header.addChild(bg)

        let gloss = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height * 0.46), cornerRadius: 0)
        gloss.fillColor = SKColor.white.withAlphaComponent(0.13)
        gloss.strokeColor = .clear
        gloss.position = CGPoint(x: 0, y: rect.height * 0.18)
        gloss.zPosition = 1
        header.addChild(gloss)

        let columns: [(String, CGFloat, CGFloat)] = [
            ("Модель самолета", 0.13, 0.24),
            ("Хаб", 0.30, 0.09),
            ("Использование", 0.43, 0.19),
            ("Вместимость", 0.61, 0.22),
            ("Износ", 0.78, 0.13),
            ("Дальность", 0.91, 0.14)
        ]

        for (text, normalizedX, normalizedWidth) in columns {
            let label = makeFittedLabel(text, maxWidth: rect.width * normalizedWidth, maxFontSize: 19, minFontSize: 13, color: .white, alignment: .center)
            label.position = CGPoint(x: -rect.width / 2 + rect.width * normalizedX, y: 0)
            label.zPosition = 2
            header.addChild(label)
        }

        for divider in [0.23, 0.31, 0.47, 0.72, 0.84] {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: rect.height - 12), cornerRadius: 0)
            line.fillColor = SKColor.white.withAlphaComponent(0.50)
            line.strokeColor = .clear
            line.position = CGPoint(x: -rect.width / 2 + rect.width * CGFloat(divider), y: 0)
            line.zPosition = 3
            header.addChild(line)
        }
    }

    func addPlaneListRows(in viewport: CGRect) {
        planeListViewportRect = viewport

        let rowHeight: CGFloat = 62
        let rowGap: CGFloat = 10
        let stride = rowHeight + rowGap
        let contentHeight = CGFloat(planeRows.count) * stride
        planeListScrollMax = max(0, contentHeight - viewport.height)
        planeListScrollOffset = min(max(planeListScrollOffset, 0), planeListScrollMax)

        let crop = SKCropNode()
        crop.position = CGPoint(x: viewport.minX, y: viewport.minY)
        crop.zPosition = 20
        addChild(crop)

        let mask = SKShapeNode(rect: CGRect(x: 0, y: 0, width: viewport.width, height: viewport.height))
        mask.fillColor = .white
        mask.strokeColor = .clear
        crop.maskNode = mask

        let content = SKNode()
        content.position = CGPoint(x: 0, y: planeListScrollOffset)
        planeListContentNode = content
        crop.addChild(content)

        for (index, row) in planeRows.enumerated() {
            let rowNode = makePlaneRow(row, index: index, size: CGSize(width: viewport.width, height: rowHeight))
            rowNode.position = CGPoint(x: viewport.width / 2, y: viewport.height - rowHeight / 2 - CGFloat(index) * stride)
            content.addChild(rowNode)
        }
    }

    func makePlaneRow(_ row: PlaneRow, index: Int, size rowSize: CGSize) -> SKNode {
        let node = SKNode()

        let base = SKShapeNode(rectOf: rowSize, cornerRadius: 0)
        base.fillColor = .white
        base.fillTexture = index.isMultiple(of: 2)
            ? verticalGradientTexture(rowSize, [SKColor(red: 0.06, green: 0.41, blue: 0.61, alpha: 1),
                                                SKColor(red: 0.02, green: 0.28, blue: 0.47, alpha: 1)])
            : verticalGradientTexture(rowSize, [SKColor(red: 0.08, green: 0.46, blue: 0.66, alpha: 1),
                                                SKColor(red: 0.03, green: 0.32, blue: 0.52, alpha: 1)])
        base.strokeColor = SKColor.white.withAlphaComponent(0.16)
        base.lineWidth = 1
        node.addChild(base)

        let sheen = SKShapeNode(rectOf: CGSize(width: rowSize.width, height: rowSize.height * 0.46), cornerRadius: 0)
        sheen.fillColor = SKColor.white.withAlphaComponent(0.11)
        sheen.strokeColor = .clear
        sheen.position = CGPoint(x: 0, y: rowSize.height * 0.18)
        sheen.zPosition = 1
        node.addChild(sheen)

        let x0 = -rowSize.width / 2
        let w = rowSize.width
        let categoryCircle = SKShapeNode(ellipseOf: CGSize(width: 28, height: 28))
        categoryCircle.fillColor = .white
        categoryCircle.strokeColor = .clear
        categoryCircle.position = CGPoint(x: x0 + 31, y: 0)
        categoryCircle.zPosition = 3
        node.addChild(categoryCircle)

        let categoryLabel = makeLabel("\(row.category)", size: 17, color: SKColor.buttonBlue, alignment: .center)
        categoryLabel.position = categoryCircle.position
        categoryLabel.zPosition = 4
        node.addChild(categoryLabel)

        let model = makeFittedLabel(row.model, maxWidth: 150, maxFontSize: 21, minFontSize: 14, color: .white, alignment: .left)
        model.position = CGPoint(x: x0 + w * 0.055, y: 15)
        model.zPosition = 3
        node.addChild(model)

        let name = makeFittedLabel(row.name, maxWidth: 160, maxFontSize: 18, minFontSize: 12, color: .white, alignment: .left)
        name.position = CGPoint(x: x0 + w * 0.055, y: -16)
        name.zPosition = 3
        node.addChild(name)

        let flag = makeUkraineFlag(size: CGSize(width: 38, height: 22))
        flag.position = CGPoint(x: x0 + w * 0.257, y: 10)
        flag.zPosition = 3
        node.addChild(flag)

        let hub = makeFittedLabel(row.hub, maxWidth: 52, maxFontSize: 18, minFontSize: 12, color: .white, alignment: .center)
        hub.position = CGPoint(x: x0 + w * 0.257, y: -17)
        hub.zPosition = 3
        node.addChild(hub)

        let usage = ProgressBarNode(percent: row.usage, size: CGSize(width: 160, height: 32)) { "\($0)% исп." }
        usage.position = CGPoint(x: x0 + w * 0.378, y: 0)
        usage.zPosition = 3
        node.addChild(usage)

        let capacity = makeFittedLabel(row.capacity.isEmpty ? row.cargo ?? "" : row.capacity, maxWidth: 120, maxFontSize: 17, minFontSize: 11, color: .white, alignment: .left)
        capacity.position = CGPoint(x: x0 + w * 0.537, y: 0)
        capacity.zPosition = 3
        node.addChild(capacity)

        if let cargo = row.cargo, !row.capacity.isEmpty {
            let cargoLabel = makeFittedLabel(cargo, maxWidth: 44, maxFontSize: 16, minFontSize: 11, color: .white, alignment: .left)
            cargoLabel.position = CGPoint(x: x0 + w * 0.66, y: 0)
            cargoLabel.zPosition = 3
            node.addChild(cargoLabel)
        }

        let wearIcon = makePlaneIcon(size: 26)
        wearIcon.position = CGPoint(x: x0 + w * 0.731, y: 0)
        wearIcon.zRotation = -CGFloat.pi / 2
        wearIcon.zPosition = 3
        wearIcon.alpha = row.wear == 0 ? 0.95 : 0.88
        wearIcon.setScale(0.72)
        node.addChild(wearIcon)

        let wearText = makeFittedLabel(String(format: "%.2f%%", row.wear), maxWidth: 72, maxFontSize: 17, minFontSize: 11, color: row.wear == 0 ? SKColor.green : SKColor.red, alignment: .left)
        wearText.position = CGPoint(x: x0 + w * 0.752, y: 0)
        wearText.zPosition = 3
        node.addChild(wearText)

        let range = makeFittedLabel(row.range, maxWidth: 85, maxFontSize: 17, minFontSize: 11, color: .white, alignment: .left)
        range.position = CGPoint(x: x0 + w * 0.855, y: 0)
        range.zPosition = 3
        node.addChild(range)

        let arrow = makePlaneRowArrowButton()
        arrow.position = CGPoint(x: x0 + rowSize.width - 32, y: 0)
        arrow.zPosition = 4
        node.addChild(arrow)

        return node
    }

    func makePlaneRowArrowButton() -> SKNode {
        let node = SKNode()
        node.name = "aircraft.planeDetails"
        let metadata = NSMutableDictionary()
        metadata["aircraftAction"] = AircraftMenuAction.planeDetails.rawValue
        node.userData = metadata

        let diameter: CGFloat = 54
        let circle = SKShapeNode(ellipseOf: CGSize(width: diameter, height: diameter))
        circle.fillColor = SKColor.buttonSurface
        circle.strokeColor = SKColor.white.withAlphaComponent(0.38)
        circle.lineWidth = 2
        node.addChild(circle)

        let face = SKShapeNode(ellipseOf: CGSize(width: diameter - 9, height: diameter - 9))
        face.fillColor = SKColor(red: 0.62, green: 0.78, blue: 0.88, alpha: 1)
        face.strokeColor = .clear
        face.zPosition = 1
        node.addChild(face)

        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: -8, y: 15))
        arrowPath.addLine(to: CGPoint(x: 12, y: 0))
        arrowPath.addLine(to: CGPoint(x: -8, y: -15))
        let arrow = SKShapeNode(path: arrowPath)
        arrow.strokeColor = SKColor.navy
        arrow.lineWidth = 7
        arrow.lineCap = .round
        arrow.lineJoin = .round
        arrow.zPosition = 2
        node.addChild(arrow)

        let selection = SKShapeNode(ellipseOf: CGSize(width: diameter + 4, height: diameter + 4))
        selection.name = "selection"
        selection.fillColor = .clear
        selection.strokeColor = .clear
        selection.lineWidth = 3
        selection.zPosition = 4
        node.addChild(selection)
        return node
    }

    func addPlaneListToolbar() {
        let y: CGFloat = 38
        addAircraftBackButton(.listBack, position: CGPoint(x: 76, y: y), size: CGSize(width: 108, height: 44))

        let search = makeToolbarPill(text: "Поиск", width: 160)
        search.position = CGPoint(x: 220, y: y)
        search.zPosition = 24
        addChild(search)

        let hubs = makeToolbarPill(text: "Все хабы", width: 175, accessory: "filter")
        hubs.position = CGPoint(x: 399, y: y)
        hubs.zPosition = 24
        addChild(hubs)

        let owned = makeToolbarPill(text: "Купленные самолеты", width: 200, accessory: "filter")
        owned.position = CGPoint(x: 598, y: y)
        owned.zPosition = 24
        addChild(owned)

        let sort = makeToolbarPill(text: "Название A>Z", width: 180, accessory: "sort")
        sort.position = CGPoint(x: 800, y: y)
        sort.zPosition = 24
        addChild(sort)

        let grid = makeToolbarPill(text: "", width: 76, accessory: "grid")
        grid.position = CGPoint(x: size.width - 62, y: y)
        grid.zPosition = 24
        addChild(grid)
    }

    func makeToolbarPill(text: String, width: CGFloat, accessory: String? = nil) -> SKNode {
        let node = SKNode()
        let size = CGSize(width: width, height: 44)
        let bg = SKShapeNode(rectOf: size, cornerRadius: 20)
        bg.fillColor = SKColor.buttonBlue
        bg.strokeColor = SKColor.white.withAlphaComponent(0.55)
        bg.lineWidth = 3
        node.addChild(bg)

        let faceSize = CGSize(width: size.width - 8, height: size.height - 8)
        let face = SKShapeNode(rectOf: faceSize, cornerRadius: 17)
        face.fillColor = .white
        face.fillTexture = verticalGradientTexture(faceSize, [
            SKColor(red: 0.09, green: 0.42, blue: 0.61, alpha: 0.97),
            SKColor(red: 0.03, green: 0.27, blue: 0.45, alpha: 0.97)
        ])
        face.strokeColor = .clear
        face.zPosition = 1
        node.addChild(face)

        if !text.isEmpty {
            let label = makeFittedLabel(text, maxWidth: width - 58, maxFontSize: 19, minFontSize: 12, color: .white, alignment: .center)
            label.position = CGPoint(x: accessory == nil ? 0 : -12, y: 0)
            label.zPosition = 2
            node.addChild(label)
        }

        if let accessory {
            switch accessory {
            case "filter":
                let icon = makeFilterGlyph(size: 28)
                icon.position = CGPoint(x: width / 2 - 28, y: 0)
                icon.zPosition = 3
                node.addChild(icon)
            case "sort":
                let label = makeLabel("↕", size: 24, color: .white, alignment: .center)
                label.position = CGPoint(x: width / 2 - 28, y: 0)
                label.zPosition = 3
                node.addChild(label)
            case "grid":
                let grid = makeGridGlyph(size: 30)
                grid.zPosition = 3
                node.addChild(grid)
            default:
                break
            }
        }

        return node
    }

    func makeFilterGlyph(size: CGFloat) -> SKNode {
        let node = SKNode()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -size * 0.42, y: size * 0.32))
        path.addLine(to: CGPoint(x: size * 0.42, y: size * 0.32))
        path.addLine(to: CGPoint(x: size * 0.12, y: -size * 0.04))
        path.addLine(to: CGPoint(x: size * 0.04, y: -size * 0.42))
        path.addLine(to: CGPoint(x: -size * 0.04, y: -size * 0.42))
        path.addLine(to: CGPoint(x: -size * 0.12, y: -size * 0.04))
        path.closeSubpath()
        let funnel = SKShapeNode(path: path)
        funnel.fillColor = .white
        funnel.strokeColor = .clear
        node.addChild(funnel)
        return node
    }

    func makeGridGlyph(size: CGFloat) -> SKNode {
        let node = SKNode()
        let cell = size * 0.34
        for row in 0..<2 {
            for column in 0..<2 {
                let square = SKShapeNode(rectOf: CGSize(width: cell, height: cell), cornerRadius: 1)
                square.fillColor = .clear
                square.strokeColor = .white
                square.lineWidth = 2
                square.position = CGPoint(x: (CGFloat(column) - 0.5) * cell * 1.35, y: (CGFloat(row) - 0.5) * cell * 1.35)
                node.addChild(square)
            }
        }
        return node
    }
}
