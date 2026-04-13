import AppKit
import LifeSaverCore
import OSLog
import ScreenSaver
import SpriteKit

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeSaverView)
final class LifeSaverView: ScreenSaverView {
    private var spriteView: SKView?
    private var scene: LifeScene?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        let spriteView = SKView(frame: bounds)
        spriteView.autoresizingMask = [.width, .height]
        spriteView.ignoresSiblingOrder = true
        spriteView.preferredFramesPerSecond = 30
        addSubview(spriteView)
        self.spriteView = spriteView
        log.notice("LifeSaverView init frame=\(String(describing: self.frame), privacy: .public)")
    }

    override func startAnimation() {
        super.startAnimation()
        log.notice("LifeSaverView startAnimation bounds=\(String(describing: self.bounds), privacy: .public)")

        guard let spriteView else { return }
        if spriteView.scene != nil { return }

        let manager = LifeManager()
        if manager.randomColorPreset, let preset = colorPresets.randomElement() {
            manager.configure(with: preset)
        }

        let sceneSize = spriteView.bounds.size == .zero ? bounds.size : spriteView.bounds.size
        let scene = LifeScene(size: sceneSize)
        scene.scaleMode = .resizeFill
        scene.appearanceMode = manager.appearanceMode
        scene.squareSize = manager.squareSize
        scene.animationSpeed = manager.animationSpeed
        scene.aliveColors = [manager.color1, manager.color2, manager.color3]
        scene.isUserInteractionEnabled = false
        spriteView.presentScene(scene)
        self.scene = scene
    }

    override func stopAnimation() {
        super.stopAnimation()
        log.notice("LifeSaverView stopAnimation")
        spriteView?.presentScene(nil)
        scene = nil
    }
}
