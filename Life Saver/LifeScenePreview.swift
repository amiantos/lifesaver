import AppKit
import Combine
import LifeSaverCore
import SpriteKit
import SwiftUI

struct LifeScenePreview: NSViewRepresentable {
    let model: ConfigurationModel

    func makeNSView(context: Context) -> SKView {
        let view = SKView(frame: NSRect(x: 0, y: 0, width: 480, height: 360))
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 30
        context.coordinator.attach(to: view, model: model)
        return view
    }

    func updateNSView(_ nsView: SKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @MainActor
    final class Coordinator {
        private weak var spriteView: SKView?
        private weak var scene: LifeScene?
        private var manager: LifeManager?
        private var sizeObserver: NSObjectProtocol?
        private var rebuildSubscription: AnyCancellable?
        private var pendingRebuild: DispatchWorkItem?

        func attach(to view: SKView, model: ConfigurationModel) {
            spriteView = view
            self.manager = model.manager
            rebuild(animated: false)

            sizeObserver = NotificationCenter.default.addObserver(
                forName: NSView.frameDidChangeNotification,
                object: view,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.handleResize()
                }
            }
            view.postsFrameChangedNotifications = true

            rebuildSubscription = model.sceneRebuildPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.scheduleRebuild()
                }
        }

        deinit {
            if let sizeObserver { NotificationCenter.default.removeObserver(sizeObserver) }
        }

        private func scheduleRebuild() {
            pendingRebuild?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.rebuild(animated: true)
            }
            pendingRebuild = work
            // Coalesce bursts of changes (e.g. preset apply touches many properties).
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: work)
        }

        private func handleResize() {
            guard let scene, let spriteView else {
                rebuild(animated: false)
                return
            }
            if spriteView.bounds.size != scene.size {
                rebuild(animated: false)
            }
        }

        private func rebuild(animated: Bool) {
            guard let spriteView, let manager else { return }
            let size = spriteView.bounds.size
            guard size.width > 50, size.height > 50 else { return }

            // Detach the old scene so any pending in-place restart can't fire on it.
            if let oldScene = scene {
                NSObject.cancelPreviousPerformRequests(withTarget: oldScene)
            }

            let newScene = LifeScene(size: size)
            newScene.scaleMode = .resizeFill
            newScene.appearanceMode = manager.appearanceMode
            newScene.squareSize = manager.squareSize
            newScene.animationSpeed = manager.animationSpeed
            newScene.aliveColors = [manager.color1, manager.color2, manager.color3]
            newScene.isUserInteractionEnabled = false
            newScene.manager = manager  // claims manager.delegate (weak), old scene drops off

            if animated, spriteView.scene != nil {
                let transition = SKTransition.fade(withDuration: 0.35)
                transition.pausesIncomingScene = false
                transition.pausesOutgoingScene = true
                spriteView.presentScene(newScene, transition: transition)
            } else {
                spriteView.presentScene(newScene)
            }
            self.scene = newScene
        }
    }
}

struct PreviewOverlay: View {
    @ObservedObject var model: ConfigurationModel
    @State private var isHovering = false

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                cyclePill(
                    icon: "wand.and.stars",
                    label: settingsPresetLabel,
                    onPrev: { model.cycleSettingsPreset(by: -1) },
                    onNext: { model.cycleSettingsPreset(by: 1) }
                )
                cyclePill(
                    icon: "paintpalette",
                    label: colorPresetLabel,
                    onPrev: { model.cycleColorPreset(by: -1) },
                    onNext: { model.cycleColorPreset(by: 1) }
                )
                Button {
                    model.cycleColorPreset(by: Int.random(in: 1...10))
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(OverlayButtonStyle())
                .help("Shuffle to a random color preset")
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
            )
            .padding(16)
            .opacity(isHovering ? 1 : 0.55)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .onHover { isHovering = $0 }
    }

    private var settingsPresetLabel: String {
        model.matchingSettingsPresetTitle ?? "Custom"
    }

    private var colorPresetLabel: String {
        model.selectedColorPresetTitle.isEmpty ? "Custom" : model.selectedColorPresetTitle
    }

    private func cyclePill(icon: String, label: String, onPrev: @escaping () -> Void, onNext: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Button(action: onPrev) {
                Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
            }
            .buttonStyle(OverlayButtonStyle())

            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 11))
                Text(label).font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 10)
            .frame(minWidth: 130)

            Button(action: onNext) {
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold))
            }
            .buttonStyle(OverlayButtonStyle())
        }
    }
}

private struct OverlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 24, height: 24)
            .background(
                Circle().fill(Color.primary.opacity(configuration.isPressed ? 0.18 : 0.08))
            )
            .foregroundStyle(.primary)
            .contentShape(Circle())
    }
}
