import AppKit
import LifeSaverCore
import SpriteKit
import SwiftUI

struct LifeScenePreview: NSViewRepresentable {
    let manager: LifeManager

    func makeNSView(context: Context) -> SKView {
        let view = SKView(frame: NSRect(x: 0, y: 0, width: 480, height: 360))
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 30
        context.coordinator.attach(to: view, manager: manager)
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator {
        private weak var spriteView: SKView?
        private var scene: LifeScene?
        private var manager: LifeManager?
        private var sizeObserver: NSObjectProtocol?

        func attach(to view: SKView, manager: LifeManager) {
            spriteView = view
            self.manager = manager
            rebuild()
            sizeObserver = NotificationCenter.default.addObserver(
                forName: NSView.frameDidChangeNotification,
                object: view,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.resizeScene()
                }
            }
            view.postsFrameChangedNotifications = true
        }

        deinit {
            if let sizeObserver { NotificationCenter.default.removeObserver(sizeObserver) }
        }

        private func rebuild() {
            guard let spriteView, let manager else { return }
            let size = spriteView.bounds.size
            guard size.width > 50, size.height > 50 else { return }

            let scene = LifeScene(size: size)
            scene.scaleMode = .resizeFill
            scene.appearanceMode = manager.appearanceMode
            scene.squareSize = manager.squareSize
            scene.animationSpeed = manager.animationSpeed
            scene.aliveColors = [manager.color1, manager.color2, manager.color3]
            scene.isUserInteractionEnabled = false
            scene.manager = manager
            spriteView.presentScene(scene)
            self.scene = scene
        }

        private func resizeScene() {
            guard let scene, let spriteView else { return }
            if spriteView.bounds.size != scene.size {
                rebuild()
            }
        }
    }
}
