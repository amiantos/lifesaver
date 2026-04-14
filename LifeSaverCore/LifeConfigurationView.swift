import Combine
import SpriteKit
import SwiftUI

@MainActor
public final class ConfigurationModel: ObservableObject {
    public let manager: LifeManager

    @Published public var appearanceMode: Appearance { didSet { manager.setAppearanceMode(appearanceMode) } }
    @Published public var squareSize: SquareSize { didSet { manager.setSquareSize(squareSize) } }
    @Published public var animationSpeed: AnimationSpeed { didSet { manager.setAnimationSpeed(animationSpeed) } }
    @Published public var startingPattern: StartingPattern { didSet { manager.setStartingPattern(startingPattern) } }
    @Published public var gridMode: GridMode { didSet { manager.setGridMode(gridMode) } }
    @Published public var respawnMode: RespawnMode { didSet { manager.setRespawnMode(respawnMode) } }
    @Published public var cameraMode: CameraMode { didSet { manager.setCameraMode(cameraMode) } }
    @Published public var deathFade: Bool { didSet { manager.setDeathFade(deathFade) } }
    @Published public var shiftingColors: Bool { didSet { manager.setShiftingColors(shiftingColors) } }
    @Published public var randomColorPreset: Bool { didSet { manager.setRandomColorPreset(randomColorPreset) } }

    @Published public var color1: Color { didSet { manager.setColor(SKColor(color1), for: .color1); selectedPresetTitle = "" } }
    @Published public var color2: Color { didSet { manager.setColor(SKColor(color2), for: .color2); selectedPresetTitle = "" } }
    @Published public var color3: Color { didSet { manager.setColor(SKColor(color3), for: .color3); selectedPresetTitle = "" } }

    @Published public var selectedPresetTitle: String

    public init() {
        let manager = LifeManager()
        self.manager = manager
        self.appearanceMode = manager.appearanceMode
        self.squareSize = manager.squareSize
        self.animationSpeed = manager.animationSpeed
        self.startingPattern = manager.startingPattern
        self.gridMode = manager.gridMode
        self.respawnMode = manager.respawnMode
        self.cameraMode = manager.cameraMode
        self.deathFade = manager.deathFade
        self.shiftingColors = manager.shiftingColors
        self.randomColorPreset = manager.randomColorPreset
        self.color1 = Color(manager.color1)
        self.color2 = Color(manager.color2)
        self.color3 = Color(manager.color3)
        self.selectedPresetTitle = manager.selectedPresetTitle
    }

    public func applyColorPreset(_ title: String) {
        guard let preset = colorPresets.first(where: { $0.title == title }) else { return }
        manager.configure(with: preset)
        if let c1 = preset.color1 { color1 = Color(c1) }
        if let c2 = preset.color2 { color2 = Color(c2) }
        if let c3 = preset.color3 { color3 = Color(c3) }
        selectedPresetTitle = title
    }

    public func resetToDefaults() {
        let defaults = LifeDatabase.standard
        defaults.set(appearanceMode: .dark)
        defaults.set(squareSize: .medium)
        defaults.set(animationSpeed: .normal)
        defaults.set(startingPattern: .defaultRandom)
        defaults.set(gridMode: .toroidal)
        defaults.set(respawnMode: .freshStart)
        defaults.set(cameraMode: .static)
        defaults.set(deathFade: true)
        defaults.set(shiftingColors: false)
        defaults.set(randomColorPreset: false)
        defaults.set(SKColor.defaultColor1, for: .color1)
        defaults.set(SKColor.defaultColor2, for: .color2)
        defaults.set(SKColor.defaultColor3, for: .color3)
        defaults.set(selectedPresetTitle: "Santa Fe")

        appearanceMode = .dark
        squareSize = .medium
        animationSpeed = .normal
        startingPattern = .defaultRandom
        gridMode = .toroidal
        respawnMode = .freshStart
        cameraMode = .static
        deathFade = true
        shiftingColors = false
        randomColorPreset = false
        color1 = Color(SKColor.defaultColor1)
        color2 = Color(SKColor.defaultColor2)
        color3 = Color(SKColor.defaultColor3)
        selectedPresetTitle = "Santa Fe"
    }
}

public struct LifeConfigurationView: View {
    @ObservedObject private var model: ConfigurationModel

    public init(model: ConfigurationModel) {
        self.model = model
    }

    public var body: some View {
        Form {
            Section("Appearance") {
                Picker("Mode", selection: $model.appearanceMode) {
                    Text("Dark").tag(Appearance.dark)
                    Text("Light").tag(Appearance.light)
                }
                .pickerStyle(.segmented)
            }

            Section("Simulation") {
                Picker("Square size", selection: $model.squareSize) {
                    Text("Ultra small").tag(SquareSize.ultraSmall)
                    Text("Super small").tag(SquareSize.superSmall)
                    Text("Very small").tag(SquareSize.verySmall)
                    Text("Small").tag(SquareSize.small)
                    Text("Medium").tag(SquareSize.medium)
                    Text("Large").tag(SquareSize.large)
                }
                Picker("Animation speed", selection: $model.animationSpeed) {
                    Text("Fastest").tag(AnimationSpeed.fastest)
                    Text("Fast").tag(AnimationSpeed.fast)
                    Text("Medium").tag(AnimationSpeed.medium)
                    Text("Normal").tag(AnimationSpeed.normal)
                    Text("Slow").tag(AnimationSpeed.slow)
                    Text("Off").tag(AnimationSpeed.off)
                }
            }

            Section("Colors") {
                Picker("Preset", selection: Binding(
                    get: { model.selectedPresetTitle },
                    set: { model.applyColorPreset($0) }
                )) {
                    if model.selectedPresetTitle.isEmpty {
                        Text("Custom").tag("")
                    }
                    ForEach(colorPresets, id: \.title) { preset in
                        Text(preset.title).tag(preset.title)
                    }
                }
                Toggle("Random preset on each start", isOn: $model.randomColorPreset)
                Toggle("Shifting colors", isOn: $model.shiftingColors)
                Toggle("Death fade", isOn: $model.deathFade)
                ColorPicker("Color 1", selection: $model.color1, supportsOpacity: false)
                ColorPicker("Color 2", selection: $model.color2, supportsOpacity: false)
                ColorPicker("Color 3", selection: $model.color3, supportsOpacity: false)
            }

            Section("Behavior") {
                Picker("Starting pattern", selection: $model.startingPattern) {
                    Text("Default random").tag(StartingPattern.defaultRandom)
                    Text("Sparse").tag(StartingPattern.sparse)
                    Text("Gliders").tag(StartingPattern.gliders)
                    Text("Sparse gliders").tag(StartingPattern.sparseGliders)
                    Text("Lonely gliders").tag(StartingPattern.lonelyGliders)
                    Text("Gosper gun").tag(StartingPattern.gosperGun)
                    Text("R-pentomino").tag(StartingPattern.rPentomino)
                    Text("Acorn").tag(StartingPattern.acorn)
                    Text("Pulsar").tag(StartingPattern.pulsar)
                    Text("Puffer train").tag(StartingPattern.pufferTrain)
                    Text("Pi fuse puffer").tag(StartingPattern.piFusePuffer)
                }
                Picker("Grid mode", selection: $model.gridMode) {
                    Text("Toroidal").tag(GridMode.toroidal)
                    Text("Infinite").tag(GridMode.infinite)
                }
                .pickerStyle(.segmented)
                Picker("Respawn", selection: $model.respawnMode) {
                    Text("Fresh start").tag(RespawnMode.freshStart)
                    Text("Add life").tag(RespawnMode.addLife)
                }
                .pickerStyle(.segmented)
                Picker("Camera", selection: $model.cameraMode) {
                    Text("Static").tag(CameraMode.static)
                    Text("Ken Burns").tag(CameraMode.kenBurns)
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button("Reset to defaults") { model.resetToDefaults() }
            }
        }
        .formStyle(.grouped)
    }
}
