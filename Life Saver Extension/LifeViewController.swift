import AppKit
import OSLog

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeViewController)
final class LifeViewController: ScreenSaverViewController {
    private var saverView: LifeSaverView?

    override func loadView() {
        let saverView = LifeSaverView(frame: NSRect(x: 0, y: 0, width: 800, height: 600), isPreview: false)!
        saverView.autoresizingMask = [.width, .height]
        self.saverView = saverView
        self.view = saverView
        log.notice("LifeViewController loadView")
    }

    override func startAnimation() {
        super.startAnimation()
        log.notice("LifeViewController startAnimation")
        saverView?.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
        log.notice("LifeViewController stopAnimation")
        saverView?.stopAnimation()
    }
}
