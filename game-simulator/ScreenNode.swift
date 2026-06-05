//
//  ScreenNode.swift
//  game-simulator
//

import SpriteKit

/// Base class for full-screen UI states. A screen is an SKNode that owns its
/// content and input handling; `GameScene` only hosts and swaps screens.
class ScreenNode: SKNode {
    unowned let gameScene: GameScene

    /// Shared caches outlive screen instances (screens die on every transition).
    static var imageCache: [String: SKTexture] = [:]
    static var gradientCache: [String: SKTexture] = [:]

    /// Currently hovered HUD "+" button (the shared top bar lives on every screen).
    weak var hoveredHUDButton: SKNode?

    init(in gameScene: GameScene) {
        self.gameScene = gameScene
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: Scene proxies — moved bodies keep reading `size`/`gameState` as before.

    var size: CGSize {
        gameScene.size
    }

    var canvas: CGRect {
        CGRect(origin: .zero, size: size)
    }

    var gameState: GameState {
        get { gameScene.gameState }
        set { gameScene.gameState = newValue }
    }

    func transition(to mode: ScreenMode) {
        gameScene.transition(to: mode)
    }

    // MARK: Lifecycle & input hooks

    /// Builds the whole screen. Called once, right after the node is added.
    func build() {}

    func mouseDown(at point: CGPoint) {}
    func mouseDragged(at point: CGPoint) {}
    func mouseUp(at point: CGPoint) {}
    func mouseMoved(at point: CGPoint) {
        updateHUDHover(at: point)
    }
    /// Escape key; each screen decides where it leads.
    func handleEscape() {}
}

extension ScreenNode {
    var layoutTopHeight: CGFloat {
        // min(112, max(96, size.height * 0.14))
        110
    }

    var layoutBottomHeight: CGFloat {
        // min(122, max(104, size.height * 0.15))
        118
    }

    var layoutSideInset: CGFloat {
        // min(88, max(62, size.width * 0.055))
        62
    }

    var railButtonSize: CGSize {
        // let side = min(56, max(48, layoutSideInset * 0.62))
        let side = 48
        return CGSize(width: side, height: side)
    }

    var mapRect: CGRect {
        let horizontalInset = layoutSideInset + 18
        let y = layoutBottomHeight + 20
        let width = max(420, size.width - horizontalInset * 2)
        // Leave a band under the top bar for the timed-offer badges (as in the reference).
        let height = max(260, size.height - layoutTopHeight - layoutBottomHeight - 92)
        return CGRect(x: horizontalInset, y: y, width: width, height: height)
    }
}

// MARK: - Top state bar (shared HUD: resources, timers, avatar)

extension ScreenNode {
    func addTopStateLayer(showTimers: Bool = true, showAvatar: Bool = true) {
        let topHeight = layoutTopHeight
        let avatarSize: CGFloat = 72
        let leftAnchor: CGFloat

        if showAvatar {
            let avatar = makeAvatar(size: avatarSize)
            avatar.position = CGPoint(x: 20 + avatarSize / 2, y: size.height - 7 - avatarSize / 2)
            avatar.zPosition = 20
            addChild(avatar)
            leftAnchor = avatar.position.x + avatarSize / 2
        } else {
            leftAnchor = 20 + avatarSize
        }

        let startX = leftAnchor + 85
        // Timers sit on their own row below the bar now, so only the settings
        // gear needs right-side clearance.
        let reservedRightWidth: CGFloat = showTimers ? 120 : 60
        let availableWidth = max(460, size.width - startX - reservedRightWidth)
        let gap: CGFloat = 20
        let metricHeight: CGFloat = 26
        let preferredWidths: [CGFloat] = [172, 125, 180, 177]
        let preferredTotal = preferredWidths.reduce(0, +) + gap * CGFloat(preferredWidths.count - 1)
        let widthScale = min(1, availableWidth / preferredTotal)
        var cursorX = startX

        for (index, counter) in gameState.topResources.enumerated() {
            let width = max(118, preferredWidths[index] * widthScale)
            let node = makeStatusCounter(counter, size: CGSize(width: width, height: metricHeight))
            node.position = CGPoint(x: cursorX + width / 2, y: size.height - 7 - metricHeight / 2)
            node.zPosition = 30
            addChild(node)
            cursorX += width + gap
        }

        guard showTimers else { return }

        let timerSize = CGSize(width: 88, height: 64)
        let timerGap: CGFloat = 12
        let totalTimersWidth = CGFloat(gameState.timedOffers.count) * timerSize.width + CGFloat(gameState.timedOffers.count - 1) * timerGap
        var timerX = size.width - max(24, layoutSideInset * 0.7) - totalTimersWidth
        let timerY = size.height - topHeight - 24

        for offer in gameState.timedOffers {
            let node = makeTimedOffer(offer, size: timerSize)
            node.position = CGPoint(x: timerX + timerSize.width / 2, y: timerY)
            node.zPosition = 25
            addChild(node)
            timerX += timerSize.width + timerGap
        }
    }

    func makeStatusCounter(_ counter: ResourceCounter, size: CGSize) -> SKNode {
        let node = SKNode()
        node.name = "state.resource.\(counter.kind.rawValue)"

        let radius: CGFloat = 5

        let shadow = SKShapeNode(rectOf: size, cornerRadius: radius)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.30)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 1, y: -2)
        shadow.zPosition = 0
        node.addChild(shadow)

        let pill = SKShapeNode(rectOf: size, cornerRadius: radius)
        pill.fillColor = .white
        pill.fillTexture = verticalGradientTexture(size, [
            SKColor(white: 0.20, alpha: 0.92),
            SKColor(white: 0.03, alpha: 0.92)
        ])
        pill.strokeColor = SKColor.white.withAlphaComponent(0.22)
        pill.lineWidth = 1
        pill.zPosition = 1
        node.addChild(pill)

        let sheen = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: 1.5), cornerRadius: 0.75)
        sheen.fillColor = SKColor.white.withAlphaComponent(0.16)
        sheen.strokeColor = .clear
        sheen.position = CGPoint(x: 0, y: size.height / 2 - 3)
        sheen.zPosition = 2
        node.addChild(sheen)

        let iconSize = size.height * 1.2
        let icon = makeResourceIcon(counter.kind, size: iconSize)
        icon.position = CGPoint(x: -size.width / 2 + iconSize * 0.42, y: 0)
        icon.zPosition = 4
        node.addChild(icon)

        let plusSide = size.height * 0.82
        let labelLeft = -size.width / 2 + iconSize * 0.86
        let labelRight = size.width / 2 - plusSide * 1.14
        let labelWidth = max(44, labelRight - labelLeft)
        let value = makeFittedLabel(counter.formattedAmount, maxWidth: labelWidth, maxFontSize: min(23, size.height * 0.58), minFontSize: 13, color: .white, alignment: .center)
        value.position = CGPoint(x: (labelLeft + labelRight) / 2, y: 0)
        value.zPosition = 4
        node.addChild(value)

        let plus = makeResourcePlusButton(side: plusSide, kind: counter.kind)
        plus.position = CGPoint(x: size.width / 2 - plusSide * 0.46, y: 0)
        plus.zPosition = 5
        node.addChild(plus)

        return node
    }

    func makeTimedOffer(_ offer: TimedOffer, size: CGSize) -> SKNode {
        let node = SKNode()
        node.name = "state.timer.\(offer.kind.rawValue)"

        let icon = makeTimedOfferIcon(offer.kind, size: size.height * 0.68)
        icon.position = CGPoint(x: 0, y: size.height * 0.16)
        icon.zPosition = 1
        node.addChild(icon)

        let plate = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.30), cornerRadius: 2)
        plate.fillColor = SKColor.black.withAlphaComponent(0.84)
        plate.strokeColor = SKColor.white.withAlphaComponent(0.12)
        plate.position = CGPoint(x: 0, y: -size.height * 0.30)
        plate.zPosition = 2
        node.addChild(plate)

        let label = makeFittedLabel(offer.remainingText, maxWidth: size.width - 8, maxFontSize: 17, minFontSize: 12, color: .white, alignment: .center)
        label.position = plate.position
        label.zPosition = 3
        node.addChild(label)

        return node
    }

    /// The "+" buy button on a resource counter: rounded square with a dark rim
    /// and a steel-blue volumetric gradient. Hover highlights it like any other
    /// clickable button; the click action is not wired up yet.
    func makeResourcePlusButton(side: CGFloat, kind: ResourceKind) -> SKNode {
        let node = SKNode()
        node.name = "hud.plus.\(kind.rawValue)"

        let radius = side * 0.26
        let face = SKShapeNode(rectOf: CGSize(width: side, height: side), cornerRadius: radius)
        face.fillColor = .white
        face.fillTexture = verticalGradientTexture(CGSize(width: side, height: side), [
            SKColor(red: 0.63, green: 0.73, blue: 0.81, alpha: 1),
            SKColor(red: 0.32, green: 0.48, blue: 0.63, alpha: 1),
            SKColor(red: 0.14, green: 0.28, blue: 0.43, alpha: 1)
        ])
        face.strokeColor = SKColor(red: 0.06, green: 0.10, blue: 0.15, alpha: 1)
        face.lineWidth = max(1.5, side * 0.07)
        face.zPosition = 1
        node.addChild(face)

        let highlight = SKShapeNode(rectOf: CGSize(width: side - 9, height: 1.5), cornerRadius: 0.75)
        highlight.fillColor = SKColor.white.withAlphaComponent(0.35)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: side / 2 - 3.5)
        highlight.zPosition = 2
        node.addChild(highlight)

        let barLength = side * 0.54
        let barThickness = side * 0.16
        for isVertical in [false, true] {
            let bar = SKShapeNode(
                rectOf: CGSize(width: isVertical ? barThickness : barLength,
                               height: isVertical ? barLength : barThickness),
                cornerRadius: barThickness * 0.22
            )
            bar.fillColor = .white
            bar.strokeColor = .clear
            bar.zPosition = 3
            node.addChild(bar)
        }

        let selection = SKShapeNode(rectOf: CGSize(width: side + 4, height: side + 4), cornerRadius: radius + 2)
        selection.name = "selection"
        selection.fillColor = .clear
        selection.strokeColor = .clear
        selection.lineWidth = 2.5
        selection.zPosition = 5
        node.addChild(selection)

        return node
    }

    /// HUD "+" buttons live on every screen, so their hover is handled by the
    /// base `mouseMoved`; screen subclasses call `super` from their overrides.
    func updateHUDHover(at point: CGPoint) {
        let target = hudPlusButton(at: point)
        guard target !== hoveredHUDButton else { return }

        setHoverNode(hoveredHUDButton, hovered: false)
        hoveredHUDButton = target
        setHoverNode(target, hovered: true)
    }

    private func hudPlusButton(at point: CGPoint) -> SKNode? {
        for node in nodes(at: point) {
            var current: SKNode? = node
            while let candidate = current {
                if candidate.name?.hasPrefix("hud.plus.") == true {
                    return candidate
                }
                current = candidate.parent
            }
        }
        return nil
    }
}

// MARK: - Shared press feedback

extension ScreenNode {
    func setPressedNode(_ node: SKNode, pressed: Bool) {
        node.removeAction(forKey: "press")
        let scale = pressed ? 0.93 : 1.0
        let animation = SKAction.scale(to: scale, duration: 0.08)
        animation.timingMode = .easeOut
        node.run(animation, withKey: "press")
    }

    /// Lights up the node's "selection" ring — the shared hover affordance.
    func setHoverNode(_ node: SKNode?, hovered: Bool) {
        let stroke = node?.childNode(withName: "selection") as? SKShapeNode
        stroke?.strokeColor = hovered ? SKColor.white.withAlphaComponent(0.82) : .clear
        stroke?.glowWidth = hovered ? 2 : 0
    }
}
