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
        log.notice("LifeSaverView commonInit bounds=\(String(describing: self.bounds), privacy: .public)")
        wantsLayer = true
        let spriteView = SKView(frame: bounds)
        spriteView.autoresizingMask = [.width, .height]
        spriteView.ignoresSiblingOrder = true
        spriteView.preferredFramesPerSecond = 30
        addSubview(spriteView)
        self.spriteView = spriteView

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: LifeDatabase.standard
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func defaultsDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.applySettingsToRunningScene()
        }
    }

    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        log.notice("LifeSaverView setFrameSize \(String(describing: newSize), privacy: .public) isAnimating=\(self.isAnimating)")
        spriteView?.frame = bounds
        rebuildSceneIfNeeded()
    }

    override func startAnimation() {
        log.notice("LifeSaverView startAnimation bounds=\(String(describing: self.bounds), privacy: .public)")
        super.startAnimation()
        rebuildSceneIfNeeded()
    }

    override func stopAnimation() {
        log.notice("LifeSaverView stopAnimation")
        super.stopAnimation()
        spriteView?.presentScene(nil)
        scene = nil
    }

    private func rebuildSceneIfNeeded() {
        log.notice("LifeSaverView rebuildSceneIfNeeded isAnimating=\(self.isAnimating) bounds=\(String(describing: self.bounds), privacy: .public)")
        // Tahoe's ExtensionKit screensaver lifecycle never seems to flip isAnimating to true,
        // so we don't gate on it — just build whenever we have a usable size.
        guard let spriteView else { log.notice("  -> skip: no spriteView"); return }
        let size = bounds.size
        guard size.width > 0 && size.height > 0 else { log.notice("  -> skip: zero size"); return }
        if let existing = scene, existing.size == size { log.notice("  -> skip: scene already at right size"); return }

        let manager = LifeManager()
        if manager.randomColorPreset, let preset = colorPresets.randomElement() {
            manager.configure(with: preset)
        }

        let scene = LifeScene(size: size)
        scene.scaleMode = .resizeFill
        scene.isUserInteractionEnabled = false
        scene.manager = manager  // createField (called from didMove) reads all settings off this
        spriteView.presentScene(scene)
        self.scene = scene

        log.notice("LifeSaverView built scene at \(String(describing: size), privacy: .public)")
    }

    private func applySettingsToRunningScene() {
        guard let scene else { return }
        scene.manager = LifeManager()
        scene.updatedSettings()
        log.notice("LifeSaverView applied updated settings")
    }
}
