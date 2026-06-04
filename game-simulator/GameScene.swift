//
//  GameScene.swift
//  game-simulator
//

import SpriteKit

/// Thin host: owns the game state, presents one `ScreenNode` at a time,
/// runs the cross-blur transition and forwards input to the active screen.
class GameScene: SKScene {
    var gameState = GameState.initial

    private(set) var screenMode: ScreenMode = .main
    private var currentScreen: ScreenNode?

    private let transitionDuration: TimeInterval = 0.45
    private let transitionBlurRadius: CGFloat = 28
    private var isTransitioning = false

    override func didMove(to view: SKView) {
        isUserInteractionEnabled = true
        // Dev shortcut: `open game-simulator.app --args -screen aircraftList`
        // boots straight into a given screen (handy for visual diffing).
        if let name = UserDefaults.standard.string(forKey: "screen"),
           let mode = GameScene.debugScreenMode(named: name) {
            screenMode = mode
        }
        presentScreen(screenMode)
        writeDebugSnapshotIfRequested()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard view != nil else { return }
        presentScreen(screenMode)
    }

    // MARK: - Screen management

    private func makeScreen(for mode: ScreenMode) -> ScreenNode {
        switch mode {
        case .main: return MainScreen(in: self)
        case .aircraft: return AircraftMenuScreen(in: self)
        case .aircraftList: return AircraftListScreen(in: self)
        case .aircraftDetail: return AircraftDetailScreen(in: self)
        }
    }

    private func presentScreen(_ mode: ScreenMode) {
        screenMode = mode
        currentScreen?.removeFromParent()
        backgroundColor = SKColor.gameBlue

        let screen = makeScreen(for: mode)
        addChild(screen)
        screen.build()
        currentScreen = screen
    }

    func transition(to mode: ScreenMode) {
        // Snapshot the current screen before we tear it down, so we can blur it out.
        let outgoing = view?.texture(from: self)
        presentScreen(mode)
        runBlurTransition(outgoing: outgoing)
    }

    // MARK: - Cross-blur transition

    /// The outgoing screen blurs out and fades while the incoming screen
    /// resolves from blurry to sharp on top of the live content.
    private func runBlurTransition(outgoing: SKTexture?) {
        guard let view else { return }

        let incoming = view.texture(from: self)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        isTransitioning = true

        var remaining = 0
        func step() {
            remaining -= 1
            if remaining <= 0 { isTransitioning = false }
        }

        // Incoming screen: blurry -> sharp. Opaque, so it covers the (identical)
        // live content underneath until the blur clears, then it is removed.
        if let incoming {
            remaining += 1
            let layer = makeBlurLayer(texture: incoming, center: center, zPosition: 9_000)
            addChild(layer.node)
            layer.node.run(blurAction(on: layer.filter, from: transitionBlurRadius, to: 0)) {
                layer.node.removeFromParent()
                step()
            }
        }

        // Outgoing screen: sharp -> blurry while fading away on top.
        if let outgoing {
            remaining += 1
            let layer = makeBlurLayer(texture: outgoing, center: center, zPosition: 10_000)
            addChild(layer.node)
            let blurOut = blurAction(on: layer.filter, from: 0, to: transitionBlurRadius)
            let fadeOut = SKAction.fadeOut(withDuration: transitionDuration)
            layer.node.run(.group([blurOut, fadeOut])) {
                layer.node.removeFromParent()
                step()
            }
        }

        if remaining == 0 { isTransitioning = false }
    }

    private func makeBlurLayer(texture: SKTexture, center: CGPoint, zPosition: CGFloat) -> (node: SKEffectNode, filter: ClampedBlurFilter) {
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = center

        let filter = ClampedBlurFilter()
        filter.inputRadius = 0

        let effect = SKEffectNode()
        effect.addChild(sprite)
        effect.filter = filter
        effect.shouldRasterize = false
        effect.zPosition = zPosition
        return (effect, filter)
    }

    private func blurAction(on filter: ClampedBlurFilter, from start: CGFloat, to end: CGFloat) -> SKAction {
        let duration = transitionDuration
        let action = SKAction.customAction(withDuration: duration) { node, elapsed in
            let progress = duration > 0 ? min(1, Double(elapsed) / duration) : 1
            filter.inputRadius = start + (end - start) * CGFloat(progress)
            // Reassign so the effect node re-renders with the updated radius.
            (node as? SKEffectNode)?.filter = filter
        }
        action.timingMode = .easeInEaseOut
        return action
    }

    // MARK: - Event forwarding — screens own their input logic

    override func mouseDown(with event: NSEvent) {
        guard !isTransitioning else { return }
        currentScreen?.mouseDown(at: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        currentScreen?.mouseDragged(at: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        guard !isTransitioning else { return }
        currentScreen?.mouseUp(at: event.location(in: self))
    }

    override func mouseMoved(with event: NSEvent) {
        currentScreen?.mouseMoved(at: event.location(in: self))
    }

    override func keyDown(with event: NSEvent) {
        guard !isTransitioning else { return }
        if event.keyCode == 0x35 {
            currentScreen?.handleEscape()
        }
    }

    // MARK: - Dev tooling

    /// Dev shortcut: `open game-simulator.app --args -screen list -snapshot /tmp/list.png`
    /// renders the scene to a PNG (at Retina scale) and quits — no screen-recording
    /// permission needed, pixel-exact for visual diffing against reference shots.
    private func writeDebugSnapshotIfRequested() {
        guard let path = UserDefaults.standard.string(forKey: "snapshot") else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            defer { NSApp.terminate(nil) }
            guard let self, let view = self.view, let texture = view.texture(from: self) else { return }
            let rep = NSBitmapImageRep(cgImage: texture.cgImage())
            if let data = rep.representation(using: .png, properties: [:]) {
                try? data.write(to: URL(fileURLWithPath: path))
            }
        }
    }

    private static func debugScreenMode(named name: String) -> ScreenMode? {
        switch name {
        case "main": return .main
        case "aircraft": return .aircraft
        case "aircraftList", "list": return .aircraftList
        case "aircraftDetail", "detail": return .aircraftDetail
        default: return nil
        }
    }
}
