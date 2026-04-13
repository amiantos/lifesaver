import Foundation
import OSLog

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeScreensaverExtension)
final class LifeScreensaverExtension: ScreenSaverExtension {
    override init() {
        log.notice("LifeScreensaverExtension init")
        super.init()
    }

    override func beginRequest(with context: NSExtensionContext) {
        log.notice("LifeScreensaverExtension beginRequest")
        super.beginRequest(with: context)
    }
}
