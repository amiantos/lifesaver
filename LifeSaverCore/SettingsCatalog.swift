import Foundation

public struct SettingOption<Value: Hashable>: Identifiable {
    public let id: String
    public let label: String
    public let value: Value
    public let blurb: String?

    public init(_ label: String, _ value: Value, blurb: String? = nil) {
        self.id = "\(label)|\(value)"
        self.label = label
        self.value = value
        self.blurb = blurb
    }
}

public enum SettingsCatalog {
    public static let appearance = (
        title: "Background",
        description: "Dark uses a black background; Light uses white for a brighter look.",
        options: [
            SettingOption("Dark", Appearance.dark),
            SettingOption("Light", Appearance.light),
        ]
    )

    public static let squareSize = (
        title: "Square Size",
        description: "Larger squares feel more abstract; smaller squares make the simulation easier to follow.",
        options: [
            SettingOption("Large", SquareSize.large),
            SettingOption("Medium", SquareSize.medium),
            SettingOption("Small", SquareSize.small),
            SettingOption("Tiny", SquareSize.verySmall),
            SettingOption("Mini", SquareSize.superSmall),
            SettingOption("Micro", SquareSize.ultraSmall),
        ]
    )

    public static let animationSpeed = (
        title: "Animation Speed",
        description: "Slower speeds blend cells into shifting colors. Faster speeds make individual cells easier to track.",
        options: [
            SettingOption("Slowest", AnimationSpeed.slow),
            SettingOption("Slower", AnimationSpeed.normal),
            SettingOption("Slow", AnimationSpeed.fast),
            SettingOption("Medium", AnimationSpeed.medium),
            SettingOption("Fast", AnimationSpeed.fastest),
        ]
    )

    public static let startingPattern = (
        title: "Starting Pattern",
        description: "What seeds the grid when it's empty or the simulation reaches stasis.",
        options: [
            SettingOption("Default", StartingPattern.defaultRandom),
            SettingOption("Sparse", StartingPattern.sparse),
            SettingOption("Gliders", StartingPattern.gliders),
            SettingOption("Sparse Gliders", StartingPattern.sparseGliders),
            SettingOption("Lonely Gliders", StartingPattern.lonelyGliders),
            SettingOption("Gosper Gun", StartingPattern.gosperGun),
            SettingOption("R-pentomino", StartingPattern.rPentomino),
            SettingOption("Acorn", StartingPattern.acorn),
            SettingOption("Pulsar", StartingPattern.pulsar),
            SettingOption("Puffer Train", StartingPattern.pufferTrain),
            SettingOption("Pi Fuse Puffer", StartingPattern.piFusePuffer),
        ]
    )

    public static let gridMode = (
        title: "Grid Mode",
        description: "Toroidal wraps the edges so patterns leaving one side reappear on the other. Infinite simulates an unbounded grid where patterns drift off-screen and eventually die away.",
        options: [
            SettingOption("Toroidal", GridMode.toroidal, blurb: "Edges wrap around — patterns leaving one side reappear on the other."),
            SettingOption("Infinite", GridMode.infinite, blurb: "Unbounded grid — patterns drift off-screen and eventually die away."),
        ]
    )

    public static let respawnMode = (
        title: "Respawn",
        description: "What happens when the simulation reaches stasis. Fresh Start clears the board; Add Life seeds new cells onto the existing pattern.",
        options: [
            SettingOption("Fresh Start", RespawnMode.freshStart, blurb: "Clears the board before seeding new life."),
            SettingOption("Add Life", RespawnMode.addLife, blurb: "Adds new life on top of existing cells, leading to more varied patterns."),
        ]
    )

    public static let cameraMode = (
        title: "Camera",
        description: "Static keeps a fixed view. Ken Burns slowly zooms and pans the camera for added motion.",
        options: [
            SettingOption("Static", CameraMode.static, blurb: "Fixed camera (default)."),
            SettingOption("Ken Burns", CameraMode.kenBurns, blurb: "Slow, smooth zoom and pan effect."),
        ]
    )

    public static let deathFade = (
        title: "Death Fade",
        description: "When a cell dies, it fades into the background. With death fade off, the cell color persists until that cell comes back to life as another color."
    )

    public static let shiftingColors = (
        title: "Shifting Colors",
        description: "Newly born squares are slightly mutated each generation, leading to a slow color shift over time."
    )

    public static let randomColorPreset = (
        title: "Random Preset on Each Start",
        description: "Pick a different color preset every time the screensaver starts."
    )
}
