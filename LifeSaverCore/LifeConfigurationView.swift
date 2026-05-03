import Combine
import SpriteKit
import SwiftUI

@MainActor
public final class ConfigurationModel: ObservableObject {
    public let manager: LifeManager
    public let sceneRebuildPublisher = PassthroughSubject<Void, Never>()

    private var isApplyingPreset = false

    @Published public var appearanceMode: Appearance { didSet { propagate { manager.setAppearanceMode(appearanceMode) } } }
    @Published public var squareSize: SquareSize { didSet { propagate { manager.setSquareSize(squareSize) } } }
    @Published public var animationSpeed: AnimationSpeed { didSet { propagate { manager.setAnimationSpeed(animationSpeed) } } }
    @Published public var startingPattern: StartingPattern { didSet { propagate { manager.setStartingPattern(startingPattern) } } }
    @Published public var gridMode: GridMode { didSet { propagate { manager.setGridMode(gridMode) } } }
    @Published public var respawnMode: RespawnMode { didSet { propagate { manager.setRespawnMode(respawnMode) } } }
    @Published public var cameraMode: CameraMode { didSet { propagate { manager.setCameraMode(cameraMode) } } }
    @Published public var deathFade: Bool { didSet { propagate { manager.setDeathFade(deathFade) } } }
    @Published public var shiftingColors: Bool { didSet { propagate { manager.setShiftingColors(shiftingColors) } } }
    @Published public var randomColorPreset: Bool { didSet { propagate { manager.setRandomColorPreset(randomColorPreset) } } }

    @Published public var color1: Color { didSet { propagate { manager.setColor(SKColor(color1), for: .color1); selectedColorPresetTitle = "" } } }
    @Published public var color2: Color { didSet { propagate { manager.setColor(SKColor(color2), for: .color2); selectedColorPresetTitle = "" } } }
    @Published public var color3: Color { didSet { propagate { manager.setColor(SKColor(color3), for: .color3); selectedColorPresetTitle = "" } } }

    @Published public var selectedColorPresetTitle: String

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
        self.selectedColorPresetTitle = manager.selectedPresetTitle
    }

    private func propagate(_ work: () -> Void) {
        guard !isApplyingPreset else { return }
        work()
        sceneRebuildPublisher.send()
    }

    public func applyColorPreset(_ title: String) {
        guard let preset = colorPresets.first(where: { $0.title == title }) else { return }
        isApplyingPreset = true
        manager.configure(with: preset)
        if let c1 = preset.color1 { color1 = Color(c1) }
        if let c2 = preset.color2 { color2 = Color(c2) }
        if let c3 = preset.color3 { color3 = Color(c3) }
        if let mode = preset.appearanceMode { appearanceMode = mode }
        selectedColorPresetTitle = title
        isApplyingPreset = false
        sceneRebuildPublisher.send()
    }

    public func applySettingsPreset(_ title: String) {
        guard let preset = settingsPresets.first(where: { $0.title == title }) else { return }
        isApplyingPreset = true
        manager.configure(with: preset)
        syncFromManager()
        isApplyingPreset = false
        sceneRebuildPublisher.send()
    }

    public func cycleSettingsPreset(by step: Int) {
        let titles = settingsPresets.map(\.title)
        let current = matchingSettingsPresetTitle ?? titles.first ?? ""
        let index = titles.firstIndex(of: current) ?? 0
        let nextIndex = ((index + step) % titles.count + titles.count) % titles.count
        applySettingsPreset(titles[nextIndex])
    }

    public func cycleColorPreset(by step: Int) {
        let titles = colorPresets.filter { $0.title != "Custom" }.map(\.title)
        guard !titles.isEmpty else { return }
        let current = selectedColorPresetTitle.isEmpty ? titles.first! : selectedColorPresetTitle
        let index = titles.firstIndex(of: current) ?? 0
        let nextIndex = ((index + step) % titles.count + titles.count) % titles.count
        applyColorPreset(titles[nextIndex])
    }

    public func resetToDefaults() {
        applySettingsPreset("Santa Fe")
    }

    private func syncFromManager() {
        appearanceMode = manager.appearanceMode
        squareSize = manager.squareSize
        animationSpeed = manager.animationSpeed
        startingPattern = manager.startingPattern
        gridMode = manager.gridMode
        respawnMode = manager.respawnMode
        cameraMode = manager.cameraMode
        deathFade = manager.deathFade
        shiftingColors = manager.shiftingColors
        randomColorPreset = manager.randomColorPreset
        color1 = Color(manager.color1)
        color2 = Color(manager.color2)
        color3 = Color(manager.color3)
        selectedColorPresetTitle = manager.selectedPresetTitle
    }

    public var matchingSettingsPresetTitle: String? {
        for preset in settingsPresets where matches(preset) {
            return preset.title
        }
        return nil
    }

    private func matches(_ preset: LifePreset) -> Bool {
        if let v = preset.appearanceMode, v != appearanceMode { return false }
        if let v = preset.squareSize, v != squareSize { return false }
        if let v = preset.animationSpeed, v != animationSpeed { return false }
        if let v = preset.deathFade, v != deathFade { return false }
        if let v = preset.shiftingColors, v != shiftingColors { return false }
        if let v = preset.startingPattern, v != startingPattern { return false }
        if let v = preset.gridMode, v != gridMode { return false }
        if let v = preset.respawnMode, v != respawnMode { return false }
        if let v = preset.cameraMode, v != cameraMode { return false }
        if let v = preset.color1, !skColor(color1).isApproximately(v) { return false }
        if let v = preset.color2, !skColor(color2).isApproximately(v) { return false }
        if let v = preset.color3, !skColor(color3).isApproximately(v) { return false }
        return true
    }

    private func skColor(_ color: Color) -> SKColor { SKColor(color) }
}

private extension SKColor {
    func isApproximately(_ other: SKColor) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        let lhs = usingColorSpace(.deviceRGB) ?? self
        let rhs = other.usingColorSpace(.deviceRGB) ?? other
        lhs.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        rhs.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let tolerance: CGFloat = 0.01
        return abs(r1 - r2) < tolerance && abs(g1 - g2) < tolerance && abs(b1 - b2) < tolerance
    }
}

// MARK: - Configuration View

public struct LifeConfigurationView: View {
    @ObservedObject private var model: ConfigurationModel

    public init(model: ConfigurationModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                quickStartSection
                appearanceSection
                simulationSection
                colorsSection
                behaviorSection
                resetSection
            }
            .padding(20)
        }
    }

    // MARK: Sections

    private var quickStartSection: some View {
        SectionContainer(title: "Quick Start", subtitle: "Hand-tuned combinations to get going fast.") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                ForEach(settingsPresets, id: \.title) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: model.matchingSettingsPresetTitle == preset.title,
                        onSelect: { model.applySettingsPreset(preset.title) }
                    )
                }
            }
        }
    }

    private var appearanceSection: some View {
        SectionContainer(title: "Appearance") {
            SegmentedSettingRow(
                title: SettingsCatalog.appearance.title,
                description: SettingsCatalog.appearance.description,
                options: SettingsCatalog.appearance.options,
                selection: $model.appearanceMode
            )
        }
    }

    private var simulationSection: some View {
        SectionContainer(title: "Simulation") {
            VStack(spacing: 18) {
                MenuSettingRow(
                    title: SettingsCatalog.squareSize.title,
                    description: SettingsCatalog.squareSize.description,
                    options: SettingsCatalog.squareSize.options,
                    selection: $model.squareSize
                )
                MenuSettingRow(
                    title: SettingsCatalog.animationSpeed.title,
                    description: SettingsCatalog.animationSpeed.description,
                    options: SettingsCatalog.animationSpeed.options,
                    selection: $model.animationSpeed
                )
                MenuSettingRow(
                    title: SettingsCatalog.startingPattern.title,
                    description: SettingsCatalog.startingPattern.description,
                    options: SettingsCatalog.startingPattern.options,
                    selection: $model.startingPattern
                )
            }
        }
    }

    private var colorsSection: some View {
        SectionContainer(title: "Colors") {
            VStack(alignment: .leading, spacing: 18) {
                colorPresetRow
                HStack(spacing: 10) {
                    LabeledColorWell(title: "Color 1", selection: $model.color1)
                    LabeledColorWell(title: "Color 2", selection: $model.color2)
                    LabeledColorWell(title: "Color 3", selection: $model.color3)
                }
                ToggleSettingRow(
                    title: SettingsCatalog.randomColorPreset.title,
                    description: SettingsCatalog.randomColorPreset.description,
                    isOn: $model.randomColorPreset
                )
                ToggleSettingRow(
                    title: SettingsCatalog.shiftingColors.title,
                    description: SettingsCatalog.shiftingColors.description,
                    isOn: $model.shiftingColors
                )
                ToggleSettingRow(
                    title: SettingsCatalog.deathFade.title,
                    description: SettingsCatalog.deathFade.description,
                    isOn: $model.deathFade
                )
            }
        }
    }

    private var colorPresetRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Color Preset").font(.headline)
                Spacer()
                Picker("", selection: Binding(
                    get: { model.selectedColorPresetTitle.isEmpty ? "Custom" : model.selectedColorPresetTitle },
                    set: { newValue in
                        if newValue == "Custom" {
                            model.selectedColorPresetTitle = ""
                        } else {
                            model.applyColorPreset(newValue)
                        }
                    }
                )) {
                    ForEach(colorPresets, id: \.title) { preset in
                        Text(preset.title).tag(preset.title)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 200)
            }
            Text("Curated three-color palettes. Editing any color slot drops you into Custom.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var behaviorSection: some View {
        SectionContainer(title: "Behavior") {
            VStack(spacing: 18) {
                SegmentedSettingRow(
                    title: SettingsCatalog.gridMode.title,
                    description: SettingsCatalog.gridMode.description,
                    options: SettingsCatalog.gridMode.options,
                    selection: $model.gridMode
                )
                SegmentedSettingRow(
                    title: SettingsCatalog.respawnMode.title,
                    description: SettingsCatalog.respawnMode.description,
                    options: SettingsCatalog.respawnMode.options,
                    selection: $model.respawnMode
                )
                SegmentedSettingRow(
                    title: SettingsCatalog.cameraMode.title,
                    description: SettingsCatalog.cameraMode.description,
                    options: SettingsCatalog.cameraMode.options,
                    selection: $model.cameraMode
                )
            }
        }
    }

    private var resetSection: some View {
        HStack {
            Spacer()
            Button("Reset to Santa Fe") { model.resetToDefaults() }
                .buttonStyle(.bordered)
        }
    }
}

// MARK: - Section Container

private struct SectionContainer<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                if let subtitle {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
            }
            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.04))
                )
        }
    }
}

// MARK: - Setting Rows

private struct SegmentedSettingRow<V: Hashable>: View {
    let title: String
    let description: String
    let options: [SettingOption<V>]
    @Binding var selection: V

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title).font(.headline)
                Spacer()
                Picker("", selection: $selection) {
                    ForEach(options) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .fixedSize()
            }
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let blurb = options.first(where: { $0.value == selection })?.blurb {
                Text(blurb)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
        }
    }
}

private struct MenuSettingRow<V: Hashable>: View {
    let title: String
    let description: String
    let options: [SettingOption<V>]
    @Binding var selection: V

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Picker("", selection: $selection) {
                    ForEach(options) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                .labelsHidden()
                .frame(maxWidth: 200)
            }
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ToggleSettingRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: $isOn) {
                Text(title).font(.headline)
            }
            .toggleStyle(.switch)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct LabeledColorWell: View {
    let title: String
    @Binding var selection: Color

    var body: some View {
        VStack(spacing: 6) {
            ColorPicker("", selection: $selection, supportsOpacity: false)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preset Card

private struct PresetCard: View {
    let preset: LifePreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                swatch
                    .frame(height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text(preset.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                Text(presetSummary)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var swatch: some View {
        HStack(spacing: 0) {
            color(preset.color1)
            color(preset.color2)
            color(preset.color3)
        }
    }

    private func color(_ value: SKColor?) -> some View {
        Color(value ?? .gray).frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var presetSummary: String {
        var parts: [String] = []
        if let speed = preset.animationSpeed {
            parts.append(speedDisplayName(speed).lowercased())
        }
        if let size = preset.squareSize {
            parts.append("\(sizeDisplayName(size).lowercased()) cells")
        }
        if preset.shiftingColors == true {
            parts.append("shifting")
        }
        if preset.cameraMode == .kenBurns {
            parts.append("Ken Burns")
        }
        if preset.startingPattern == .lonelyGliders {
            parts.append("lonely gliders")
        }
        return parts.joined(separator: " · ")
    }

    private func speedDisplayName(_ speed: AnimationSpeed) -> String {
        SettingsCatalog.animationSpeed.options.first { $0.value == speed }?.label ?? ""
    }

    private func sizeDisplayName(_ size: SquareSize) -> String {
        SettingsCatalog.squareSize.options.first { $0.value == size }?.label ?? ""
    }
}
