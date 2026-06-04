//
//  ProgressBarNode.swift
//  game-simulator
//

import SpriteKit

/// Capsule progress bar with a centered caption — a "live" UI component:
/// children are created once and mutated on state change.
///
///     let bar = ProgressBarNode(percent: 42, size: CGSize(width: 160, height: 32)) { "\($0)% исп." }
///     bar.percent = 73                    // instant
///     bar.setPercent(73, animated: true)  // eased
final class ProgressBarNode: SKNode {
    /// Clamped to 0...100; updates the fill and caption on every change.
    var percent: Int {
        didSet {
            percent = Self.clamped(percent)
            updateLayout()
        }
    }

    /// Caption for a given percent; swap to relabel the bar (units, locale…).
    var textProvider: (Int) -> String {
        didSet { updateLayout() }
    }

    var fillColor: SKColor {
        didSet { fillNode.fillColor = fillColor }
    }

    var barBackgroundColor: SKColor {
        didSet { backgroundNode.fillColor = barBackgroundColor }
    }

    var textColor: SKColor {
        didSet { labelNode.fontColor = textColor }
    }

    private(set) var barSize: CGSize

    private let xPadding: CGFloat
    private let yPadding: CGFloat
    private let maxFontSize: CGFloat = 16
    private let minFontSize: CGFloat = 11

    private let backgroundNode = SKShapeNode()
    private let cropNode = SKCropNode()
    private let maskNode = SKShapeNode()
    private let fillNode = SKShapeNode()
    private let labelNode: SKLabelNode

    init(
        percent: Int,
        size: CGSize,
        xPadding: CGFloat = 7,
        yPadding: CGFloat = 5,
        textProvider: @escaping (Int) -> String = { "\($0)%" }
    ) {
        self.percent = Self.clamped(percent)
        self.barSize = size
        self.xPadding = xPadding
        self.yPadding = yPadding
        self.textProvider = textProvider
        self.fillColor = SKColor(red: 0.47, green: 0.78, blue: 0.07, alpha: 1)
        self.barBackgroundColor = .white
        self.textColor = SKColor.navy
        self.labelNode = SKLabelNode(themed: "", size: 16, color: SKColor.navy, alignment: .center)

        super.init()

        setup()
        updateLayout()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// Re-sizes the bar in place (e.g. when the container relayouts).
    func setSize(_ size: CGSize) {
        barSize = size
        updateLayout()
    }

    /// Eases the fill towards a new value; `animated: false` jumps instantly.
    func setPercent(_ value: Int, animated: Bool, duration: TimeInterval = 0.25) {
        removeAction(forKey: Self.animationKey)
        let target = Self.clamped(value)
        guard animated, target != percent, duration > 0 else {
            percent = target
            return
        }

        let start = percent
        let action = SKAction.customAction(withDuration: duration) { [weak self] _, elapsed in
            let progress = min(1, elapsed / CGFloat(duration))
            self?.percent = start + Int((CGFloat(target - start) * progress).rounded())
        }
        action.timingMode = .easeOut
        run(action, withKey: Self.animationKey)
    }

    // MARK: - Internals

    private static let animationKey = "progressbar.animate"

    private static func clamped(_ value: Int) -> Int {
        max(0, min(value, 100))
    }

    private func setup() {
        backgroundNode.fillColor = barBackgroundColor
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = 0
        addChild(backgroundNode)

        maskNode.fillColor = .white
        maskNode.strokeColor = .clear
        cropNode.maskNode = maskNode
        cropNode.zPosition = 1
        addChild(cropNode)

        // No stroke on the fill: the mask would clip it and leave artifacts.
        fillNode.fillColor = fillColor
        fillNode.strokeColor = .clear
        fillNode.lineWidth = 0
        cropNode.addChild(fillNode)

        labelNode.zPosition = 2
        addChild(labelNode)
    }

    private func updateLayout() {
        let innerWidth = max(0, barSize.width - xPadding * 2)
        let innerHeight = max(0, barSize.height - yPadding * 2)
        let fillWidth = innerWidth * CGFloat(percent) / 100

        backgroundNode.path = CGPath(
            roundedRect: CGRect(x: -barSize.width / 2, y: -barSize.height / 2,
                                width: barSize.width, height: barSize.height),
            cornerWidth: barSize.height / 2,
            cornerHeight: barSize.height / 2,
            transform: nil
        )

        // Mask: inner rounded capsule; fill: plain rectangle clipped by it,
        // so partial fills get a straight right edge and a capsule left one.
        maskNode.path = CGPath(
            roundedRect: CGRect(x: -innerWidth / 2, y: -innerHeight / 2,
                                width: innerWidth, height: innerHeight),
            cornerWidth: innerHeight / 2,
            cornerHeight: innerHeight / 2,
            transform: nil
        )

        fillNode.path = CGPath(
            rect: CGRect(x: -fillWidth / 2, y: -innerHeight / 2, width: fillWidth, height: innerHeight),
            transform: nil
        )
        fillNode.position = CGPoint(x: -innerWidth / 2 + fillWidth / 2, y: 0)
        cropNode.isHidden = fillWidth <= 0 || innerHeight <= 0

        labelNode.text = textProvider(percent)
        labelNode.fontSize = floor(maxFontSize)
        labelNode.fit(maxWidth: barSize.width - 22, minFontSize: minFontSize)
    }
}
