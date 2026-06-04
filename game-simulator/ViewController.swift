//
//  ViewController.swift
//  game-simulator
//
//  Created by Evgeny Ukhanov on 04/06/2026.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController {
    private let fixedContentSize = CGSize(width: 1052, height: 787)

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.setFrameSize(fixedContentSize)
        skView.setFrameSize(fixedContentSize)

        let scene = GameScene(size: fixedContentSize)
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        configureWindow()
    }

    private func configureWindow() {
        guard let window = view.window else { return }

        window.acceptsMouseMovedEvents = true
        window.styleMask.remove(.resizable)
        window.contentMinSize = fixedContentSize
        window.contentMaxSize = fixedContentSize
        window.setContentSize(fixedContentSize)
        window.center()
    }
}
