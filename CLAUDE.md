# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Life Saver is an artistic implementation of Conway's Game of Life built with SpriteKit. Targets:
- **Life Saver** - macOS host app that registers the screensaver extension (macOS Tahoe)
- **Life Saver Extension** - ExtensionKit screensaver extension embedded in the host app
- **LifeSaverCore** - Shared framework consumed by the host app and extension
- **Life Saver macOS** - Legacy SKView debug companion (kept for inspecting the raw scene)
- **Life Saver tvOS** - Apple TV app

## Build Commands

Open `Life Saver.xcodeproj` in Xcode, select a target, and build/run. No external dependencies required.

## Architecture

### Core Components (Shared/)

- **LifeScene.swift** - Main SpriteKit scene managing the Game of Life grid, cell updates, and animations. Contains the core game rules (cells with >3 or <2 neighbors die; dead cells with exactly 3 neighbors become alive). Includes stasis detection and regeneration when population dies out.

- **LifeManager.swift** - Configuration manager using delegate pattern to notify LifeScene of setting changes. Bridges between LifeDatabase and the scene.

- **LifeNode.swift** - Individual cell sprite (SKSpriteNode subclass) with alive/dead state management and fade animations.

- **LifeDatabase.swift** - UserDefaults wrapper for persistent settings storage.

- **LifePreset.swift** - Defines color schemes and settings presets. Contains 20+ color presets (Santa Fe, Braineater, Meditation, etc.) and 5 settings presets for different size/speed configurations.

### Utilities (Shared/Utilities/)

- **ToroidalMatrix.swift** - Matrix data structure that wraps edges (toroidal topology), enabling efficient neighbor calculations for the Game of Life grid.

### Platform-Specific Code

- **Life Saver/** - Host macOS app that hosts and registers the screensaver extension
- **Life Saver Extension/** - ExtensionKit-based screensaver: `LifeSaverView`, `LifeScreensaverExtension`, `LifeConfigurationViewController`, `LifeViewController` (uses `ScreenSaverPrivate.h` to bridge to the private `PrivateScreenSaver.framework`)
- **LifeSaverCore/** - Framework target that builds the `Shared/` sources for consumption by the host app and extension
- **macOS/** - Legacy AppDelegate and ViewController for the debug companion app
- **tvOS/** - View controllers and table view cells for Apple TV menu navigation