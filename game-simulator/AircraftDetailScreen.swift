//
//  AircraftDetailScreen.swift
//  game-simulator
//

import SpriteKit

/// The single-aircraft dossier: identity, schedule, maintenance and capacity panels.
final class AircraftDetailScreen: AircraftScreen {
    override func build() {
        let darkBase = SKShapeNode(rect: canvas)
        darkBase.fillColor = SKColor.aircraftNavy
        darkBase.strokeColor = .clear
        darkBase.zPosition = -100
        addChild(darkBase)

        let heroRect = CGRect(x: 0, y: size.height - 430, width: size.width, height: 320)
        addAircraftHeroBackground(in: heroRect)

        let content = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: heroRect.minY + 10))
        content.fillColor = SKColor.aircraftPanel
        content.strokeColor = .clear
        content.zPosition = -18
        addChild(content)

        addAircraftSectionHeader(title: "Сведения о самолете", leftTitle: "Мои самолеты", helpAction: .detailHelp, closeAction: .detailClose, showClock: false)
        addAircraftDetailPanels()
        addAircraftBackButton(.detailBack)
        addTopStateLayer(showTimers: false, showAvatar: false)
        refreshAircraftButtonSelection()
    }

    override func handleEscape() {
        transition(to: .aircraftList)
    }
}

extension AircraftDetailScreen {
    func addAircraftDetailPanels() {
        let leftRect = CGRect(x: 40, y: 312, width: 560, height: 170)
        let rightTopLeft = CGRect(x: 610, y: 312, width: 180, height: 170)
        let rightTopRight = CGRect(x: 800, y: 312, width: 160, height: 170)
        let lowerLeft = CGRect(x: 40, y: 116, width: 560, height: 186)
        let lowerRight = CGRect(x: 610, y: 116, width: 350, height: 186)

        addPlaneIdentityPanel(in: leftRect)
        addSchedulePanel(in: rightTopLeft)
        addFlightsPanel(in: rightTopRight)
        addMaintenancePanel(in: lowerLeft)
        addCapacityPanel(in: lowerRight)
    }

    func addPanelBackground(in rect: CGRect, zPosition: CGFloat = 20) -> SKShapeNode {
        let panel = SKShapeNode(rect: rect, cornerRadius: 0)
        panel.fillColor = SKColor.aircraftCard
        panel.strokeColor = SKColor.white.withAlphaComponent(0.18)
        panel.lineWidth = 1
        panel.zPosition = zPosition
        addChild(panel)

        let gloss = SKShapeNode(rect: CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2), cornerRadius: 0)
        gloss.fillColor = SKColor.white.withAlphaComponent(0.11)
        gloss.strokeColor = .clear
        gloss.zPosition = zPosition + 1
        addChild(gloss)
        return panel
    }

    func addPlaneIdentityPanel(in rect: CGRect) {
        _ = addPanelBackground(in: rect)

        let flag = makeUkraineFlag(size: CGSize(width: 42, height: 24))
        flag.position = CGPoint(x: rect.minX + 42, y: rect.maxY - 32)
        flag.zPosition = 24
        addChild(flag)

        let hub = makeFittedLabel("KBP", maxWidth: 54, maxFontSize: 20, minFontSize: 13, color: .white, alignment: .left)
        hub.position = CGPoint(x: rect.minX + 70, y: rect.maxY - 33)
        hub.zPosition = 24
        addChild(hub)

        let model = makeFittedLabel("Embraer ERJ-195 / BOOSTER-ERJ-195", maxWidth: 200, maxFontSize: 22, minFontSize: 12, color: .white, alignment: .left)
        model.position = CGPoint(x: rect.minX + 180, y: rect.maxY - 33)
        model.zPosition = 24
        addChild(model)

        let categoryText = makeFittedLabel("Категория", maxWidth: 106, maxFontSize: 19, minFontSize: 12, color: .white, alignment: .left)
        categoryText.position = CGPoint(x: rect.maxX - 150, y: rect.maxY - 33)
        categoryText.zPosition = 24
        addChild(categoryText)

        let category = SKShapeNode(ellipseOf: CGSize(width: 32, height: 32))
        category.fillColor = .white
        category.strokeColor = .clear
        category.position = CGPoint(x: rect.maxX - 32, y: rect.maxY - 33)
        category.zPosition = 24
        addChild(category)

        let number = makeLabel("5", size: 19, color: SKColor.buttonBlue, alignment: .center)
        number.position = category.position
        number.zPosition = 25
        addChild(number)

        let plane = makePlaneIcon(size: 112)
        plane.position = CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + 78)
        plane.zRotation = -CGFloat.pi / 2
        plane.zPosition = 24
        addChild(plane)

        let statsRect = CGRect(x: rect.minX + 58, y: rect.minY + 8, width: rect.width - 116, height: 58)
        let stats = SKShapeNode(rect: statsRect, cornerRadius: 6)
        stats.fillColor = SKColor.navy.withAlphaComponent(0.72)
        stats.strokeColor = .clear
        stats.zPosition = 25
        addChild(stats)

        let labels = [
            ("Цена покупки", "49 000 000$"),
            ("Общий результат", "0$"),
            ("Общая стоимость обслуживания", "0$"),
            ("Прибыльность", "0%")
        ]
        for (index, pair) in labels.enumerated() {
            let y = statsRect.maxY - 10 - CGFloat(index) * 14
            let left = makeFittedLabel(pair.0, maxWidth: 200, maxFontSize: 13, minFontSize: 9, color: .white, alignment: .left)
            left.position = CGPoint(x: statsRect.minX + 42, y: y)
            left.zPosition = 26
            addChild(left)

            let rightColor = pair.1 == "0%" ? SKColor.red : SKColor.gold
            let right = makeFittedLabel(pair.1, maxWidth: 120, maxFontSize: 14, minFontSize: 9, color: rightColor, alignment: .right)
            right.position = CGPoint(x: statsRect.maxX - 38, y: y)
            right.zPosition = 26
            addChild(right)
        }

        for x in [statsRect.minX - 28, statsRect.maxX + 28] {
            let arrow = makeLabel(x < statsRect.midX ? "‹" : "›", size: 54, color: .white, alignment: .center)
            arrow.position = CGPoint(x: x, y: statsRect.midY + 2)
            arrow.zPosition = 26
            addChild(arrow)
        }
    }

    func addSchedulePanel(in rect: CGRect) {
        _ = addPanelBackground(in: rect)
        let title = makeFittedLabel("Расписание", maxWidth: rect.width - 36, maxFontSize: 20, minFontSize: 13, color: .white, alignment: .center)
        title.position = CGPoint(x: rect.midX, y: rect.maxY - 34)
        title.zPosition = 24
        addChild(title)

        let bar = ProgressBarNode(percent: 0, size: CGSize(width: rect.width - 42, height: 30)) { "\($0)% исп." }
        bar.position = CGPoint(x: rect.midX, y: rect.maxY - 72)
        bar.zPosition = 24
        addChild(bar)

        let button = makeSoftPanelButton(text: "Расписание", size: CGSize(width: rect.width - 28, height: 58))
        button.position = CGPoint(x: rect.midX, y: rect.minY + 38)
        button.zPosition = 25
        addChild(button)
    }

    func addFlightsPanel(in rect: CGRect) {
        _ = addPanelBackground(in: rect)
        let plane = makePlaneIcon(size: 90)
        plane.position = CGPoint(x: rect.midX - 12, y: rect.maxY - 58)
        plane.zRotation = -CGFloat.pi / 2
        plane.zPosition = 24
        addChild(plane)

        let board = SKShapeNode(rectOf: CGSize(width: 74, height: 44), cornerRadius: 2)
        board.fillColor = SKColor.navy
        board.strokeColor = SKColor.white.withAlphaComponent(0.18)
        board.position = CGPoint(x: rect.midX + 30, y: rect.maxY - 46)
        board.zPosition = 23
        addChild(board)

        let arrow = makeLabel("↑", size: 34, color: SKColor.gold, alignment: .center)
        arrow.position = CGPoint(x: rect.midX + 22, y: rect.maxY - 46)
        arrow.zPosition = 24
        addChild(arrow)

        let button = makeSoftPanelButton(text: "Рейсы\nсамолета", size: CGSize(width: rect.width - 20, height: 60))
        button.position = CGPoint(x: rect.midX, y: rect.minY + 38)
        button.zPosition = 25
        addChild(button)
    }

    func addMaintenancePanel(in rect: CGRect) {
        _ = addPanelBackground(in: rect)
        let info = [
            ("Износ", "0%", SKColor.green),
            ("Рейтинг возраста", "5/5", SKColor.red),
            ("(+11.67% износа за 100 летных часов)", "", SKColor.white)
        ]

        for (index, item) in info.enumerated() {
            let y = rect.maxY - 28 - CGFloat(index) * 31
            let left = makeFittedLabel(item.0, maxWidth: 320, maxFontSize: index == 2 ? 16 : 18, minFontSize: 10, color: .white, alignment: .left)
            left.position = CGPoint(x: rect.minX + 34, y: y)
            left.zPosition = 24
            addChild(left)

            if !item.1.isEmpty {
                let right = makeFittedLabel(item.1, maxWidth: 62, maxFontSize: 18, minFontSize: 11, color: item.2, alignment: .right)
                right.position = CGPoint(x: rect.minX + 320, y: y)
                right.zPosition = 24
                addChild(right)
            }
        }

        let incidents = makeSoftPanelButton(text: "Инциденты (0)", size: CGSize(width: 250, height: 48))
        incidents.position = CGPoint(x: rect.minX + 150, y: rect.minY + 34)
        incidents.zPosition = 25
        addChild(incidents)

        let checkA = makeWrenchIcon(size: 70)
        checkA.position = CGPoint(x: rect.midX + 78, y: rect.minY + 78)
        checkA.zPosition = 24
        addChild(checkA)

        let checkAButton = makeSoftPanelButton(text: "Проверка A:\n149 881$", size: CGSize(width: 130, height: 68))
        checkAButton.position = CGPoint(x: rect.midX + 78, y: rect.minY + 36)
        checkAButton.zPosition = 25
        addChild(checkAButton)

        let checkD = makeWrenchIcon(size: 70)
        checkD.position = CGPoint(x: rect.midX + 212, y: rect.minY + 78)
        checkD.zPosition = 24
        addChild(checkD)

        let checkDButton = makeSoftPanelButton(text: "Проверка D:\n5 749 881$", size: CGSize(width: 130, height: 68))
        checkDButton.position = CGPoint(x: rect.midX + 212, y: rect.minY + 36)
        checkDButton.zPosition = 25
        addChild(checkDButton)
    }

    func addCapacityPanel(in rect: CGRect) {
        _ = addPanelBackground(in: rect)
        let seats = makeFittedLabel("Места: 77", maxWidth: rect.width - 70, maxFontSize: 20, minFontSize: 13, color: .white, alignment: .center)
        seats.position = CGPoint(x: rect.midX, y: rect.maxY - 26)
        seats.zPosition = 24
        addChild(seats)

        let meterBg = SKShapeNode(rectOf: CGSize(width: rect.width - 110, height: 28), cornerRadius: 14)
        meterBg.fillColor = .clear
        meterBg.strokeColor = .white
        meterBg.lineWidth = 4
        meterBg.position = CGPoint(x: rect.midX, y: rect.maxY - 58)
        meterBg.zPosition = 24
        addChild(meterBg)

        let segments: [(CGFloat, SKColor)] = [
            (0.35, SKColor(red: 0.42, green: 0.80, blue: 0.90, alpha: 1)),
            (0.22, SKColor(red: 0.16, green: 0.62, blue: 0.75, alpha: 1)),
            (0.12, SKColor(red: 0.02, green: 0.36, blue: 0.60, alpha: 1)),
            (0.23, SKColor(red: 0.02, green: 0.20, blue: 0.42, alpha: 1))
        ]
        var cursor = -meterBg.frame.width / 2 + 9
        for segment in segments {
            let width = (rect.width - 132) * segment.0
            let chunk = SKShapeNode(rectOf: CGSize(width: width, height: 20), cornerRadius: 0)
            chunk.fillColor = segment.1
            chunk.strokeColor = .clear
            chunk.position = CGPoint(x: rect.midX + cursor + width / 2, y: rect.maxY - 58)
            chunk.zPosition = 25
            addChild(chunk)
            cursor += width
        }

        let payload = makeFittedLabel("Полезная нагрузка: 12.7/13.6", maxWidth: rect.width - 60, maxFontSize: 19, minFontSize: 12, color: .white, alignment: .center)
        payload.position = CGPoint(x: rect.midX, y: rect.maxY - 90)
        payload.zPosition = 24
        addChild(payload)

        let configPanel = SKShapeNode(rect: CGRect(x: rect.minX + 22, y: rect.minY + 40, width: rect.width - 44, height: 44), cornerRadius: 6)
        configPanel.fillColor = SKColor.navy.withAlphaComponent(0.68)
        configPanel.strokeColor = .clear
        configPanel.zPosition = 24
        addChild(configPanel)

        let configs = ["Экон.: 46", "Биз.: 22", "Перв.: 9", "Груз: 4 т"]
        for (index, text) in configs.enumerated() {
            let x = rect.minX + (index.isMultiple(of: 2) ? 100 : 235)
            let y = rect.minY + (index < 2 ? 70 : 48)
            let label = makeFittedLabel(text, maxWidth: 100, maxFontSize: 16, minFontSize: 10, color: .white, alignment: .left)
            label.position = CGPoint(x: x, y: y)
            label.zPosition = 25
            addChild(label)
        }

        let config = makeSoftPanelButton(text: "Конфигурация", size: CGSize(width: 200, height: 44))
        config.position = CGPoint(x: rect.midX - 62, y: rect.minY + 20)
        config.zPosition = 25
        addChild(config)

        let sell = makeSoftPanelButton(text: "Продать", size: CGSize(width: 120, height: 44))
        sell.position = CGPoint(x: rect.maxX - 66, y: rect.minY + 20)
        sell.zPosition = 25
        addChild(sell)
    }

    func makeSoftPanelButton(text: String, size: CGSize) -> SKNode {
        let node = SKNode()
        let bg = SKShapeNode(rectOf: size, cornerRadius: min(22, size.height / 2))
        bg.fillColor = SKColor.buttonSurface
        bg.strokeColor = SKColor.white.withAlphaComponent(0.45)
        bg.lineWidth = 2
        node.addChild(bg)

        let faceSize = CGSize(width: size.width - 8, height: size.height - 8)
        let face = SKShapeNode(rectOf: faceSize, cornerRadius: min(18, (size.height - 8) / 2))
        face.fillColor = .white
        face.fillTexture = verticalGradientTexture(faceSize, [
            SKColor(red: 0.93, green: 0.97, blue: 1.00, alpha: 1),
            SKColor(red: 0.66, green: 0.80, blue: 0.90, alpha: 1),
            SKColor(red: 0.52, green: 0.71, blue: 0.84, alpha: 1)
        ])
        face.strokeColor = .clear
        face.position = CGPoint(x: 0, y: 1)
        face.zPosition = 1
        node.addChild(face)

        let lines = text.components(separatedBy: "\n")
        let label = makeStackedLabel(lines, maxWidth: size.width - 18, maxFontSize: lines.count > 1 ? 16 : 18, minFontSize: 11, color: SKColor.navy)
        label.zPosition = 2
        node.addChild(label)
        return node
    }
}
