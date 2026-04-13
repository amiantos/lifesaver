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
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        spriteView?.frame = bounds
        rebuildSceneIfNeeded()
    }

    override func startAnimation() {
        super.startAnimation()
        rebuildSceneIfNeeded()
    }

    override func stopAnimation() {
        super.stopAnimation()
        spriteView?.presentScene(nil)
        scene = nil
    }

    private func rebuildSceneIfNeeded() {
        guard isAnimating else { return }
        guard let spriteView else { return }
        let size = bounds.size
        guard size.width > 100 && size.height > 100 else { return }
        if let existing = scene, existing.size == size { return }

        let manager = LifeManager()
        if manager.randomColorPreset, let preset = colorPresets.randomElement() {
            manager.configure(with: preset)
        }

        let scene = LifeScene(size: size)
        scene.scaleMode = .resizeFill
        scene.appearanceMode = manager.appearanceMode
        scene.squareSize = manager.squareSize
        scene.animationSpeed = manager.animationSpeed
        scene.aliveColors = [manager.color1, manager.color2, manager.color3]
        scene.isUserInteractionEnabled = false
        spriteView.presentScene(scene)
        self.scene = scene

        log.notice("LifeSaverView built scene at \(String(describing: size), privacy: .public)")
    }
}
