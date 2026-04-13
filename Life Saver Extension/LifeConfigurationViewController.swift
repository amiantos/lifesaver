import AppKit

@objc(LifeConfigurationViewController)
final class LifeConfigurationViewController: ScreenSaverConfigurationViewController {
    override func loadView() {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 120))
        let label = NSTextField(labelWithString: "Life Saver — spike build")
        label.frame = NSRect(x: 20, y: 40, width: 360, height: 40)
        view.addSubview(label)
        self.view = view
    }
}
