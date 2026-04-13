import AppKit
import OSLog

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeViewController)
final class LifeViewController: ScreenSaverViewController {
    private var saverView: LifeSaverView?

    override func loadView() {
        let saverView = LifeSaverView(frame: .zero, isPreview: false)!
        saverView.autoresizingMask = [.width, .height]
        self.saverView = saverView
        self.view = saverView
    }

    override func startAnimation() {
        super.startAnimation()
        saverView?.startAnimation()
    }

    override func stopAnimation() {
        super.stopAnimation()
        saverView?.stopAnimation()
    }
}
