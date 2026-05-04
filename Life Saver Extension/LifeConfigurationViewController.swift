import AppKit
import OSLog

private let log = Logger(subsystem: "net.amiantos.Life-Saver", category: "extension")

@objc(LifeConfigurationViewController)
final class LifeConfigurationViewController: ScreenSaverConfigurationViewController {
    override func loadView() {
        log.notice("LifeConfigurationViewController loadView")
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 140))
        container.wantsLayer = true

        let title = NSTextField(labelWithString: "Configure Life Saver")
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let body = NSTextField(wrappingLabelWithString: "Open the Life Saver app to change colors, presets, and behavior.")
        body.font = .systemFont(ofSize: 12)
        body.textColor = .secondaryLabelColor
        body.translatesAutoresizingMaskIntoConstraints = false

        let openButton = NSButton(title: "Open Life Saver", target: self, action: #selector(openHostApp))
        openButton.bezelStyle = .rounded
        openButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(title)
        container.addSubview(body)
        container.addSubview(openButton)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            body.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            body.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            body.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            openButton.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 16),
            openButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            openButton.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -20),
        ])

        self.view = container
    }

    @objc private func openHostApp() {
        log.notice("LifeConfigurationViewController openHostApp tapped")
        let url = URL(fileURLWithPath: "/Applications/Life Saver.app")
        NSWorkspace.shared.open(url)
    }
}
