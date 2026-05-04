import AppKit
import OSLog

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeViewController)
final class LifeViewController: ScreenSaverViewController {
    private var saverView: LifeSaverView?

    override func loadView() {
        log.notice("LifeViewController loadView")
        let saverView = LifeSaverView(frame: .zero, isPreview: false)!
        saverView.autoresizingMask = [.width, .height]
        self.saverView = saverView
        self.view = saverView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        log.notice("LifeViewController viewDidLoad bounds=\(String(describing: self.view.bounds))")
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        log.notice("LifeViewController viewWillAppear bounds=\(String(describing: self.view.bounds))")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        log.notice("LifeViewController viewDidAppear bounds=\(String(describing: self.view.bounds))")
        // Belt-and-braces: kick off animation in case the host doesn't call startAnimation.
        saverView?.startAnimation()
    }

    override func startAnimation() {
        log.notice("LifeViewController startAnimation bounds=\(String(describing: self.view.bounds))")
        super.startAnimation()
        saverView?.startAnimation()
    }

    override func stopAnimation() {
        log.notice("LifeViewController stopAnimation")
        super.stopAnimation()
        saverView?.stopAnimation()
    }
}
