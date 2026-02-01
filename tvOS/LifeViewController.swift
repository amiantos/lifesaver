//
//  LifeViewController.swift
//  Life Saver
//
//  Created by Bradley Root on 6/25/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import GameplayKit
import SpriteKit
import UIKit

enum UIState {
    case colorPresets
    case mainMenu
    case allClosed
}

class LifeViewController: UIViewController, LifeManagerDelegate {
    var scene: LifeScene?
    let manager = LifeManager()
    var state: UIState = .allClosed

    // MARK: - UI Components

    private lazy var colorPresetsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ColorPresetTableViewCell.self, forCellReuseIdentifier: ColorPresetTableViewCell.reuseIdentifier)
        tableView.sectionHeaderHeight = 66
        tableView.sectionFooterHeight = 66
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var colorPresetsView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var mainMenuView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var menuHintToast: UIVisualEffectView = {
        let view = createToast(text: "Press Menu Button")
        return view
    }()

    private lazy var colorMenuCloseToast: UIVisualEffectView = {
        let view = createToast(text: "Swipe → to close")
        return view
    }()

    private lazy var mainMenuCloseToast: UIVisualEffectView = {
        let view = createToast(text: "Swipe ← to close")
        return view
    }()

    private lazy var kludgeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private lazy var initialOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    // Menu table view (merged from MenuTableViewController)
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // Header view for main menu
    private lazy var headerView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular))
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Life Saver"
        titleLabel.font = UIFont.systemFont(ofSize: 78)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "by Brad Root"
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = UIColor(white: 0.9, alpha: 0.6)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.contentView.addSubview(titleLabel)
        view.contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.contentView.centerYAnchor, constant: -20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 450)
        ])

        return view
    }()

    // Footer view for main menu
    private lazy var footerView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular))
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false

        let urlLabel = UILabel()
        urlLabel.text = "https://github.com/amiantos/lifesaver"
        urlLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        urlLabel.translatesAutoresizingMaskIntoConstraints = false

        view.contentView.addSubview(urlLabel)

        NSLayoutConstraint.activate([
            urlLabel.centerXAnchor.constraint(equalTo: view.contentView.centerXAnchor),
            urlLabel.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor, constant: -40)
        ])

        return view
    }()

    // MARK: - Constraints

    private var mainMenuLeadingConstraint: NSLayoutConstraint!
    private var colorMenuTrailingConstraint: NSLayoutConstraint!
    private var menuHintToastConstraint: NSLayoutConstraint!

    // Tracks whether the main menu shows presets (false) or settings (true)
    private var isCustomizeMode: Bool = false

    var pressedMenuButtonRecognizer: UITapGestureRecognizer?
    var propertyAnimators: [UIViewPropertyAnimator] = []
    var menuHintBounceAnimation: UIViewPropertyAnimator?

    // Menu cells for updating detail labels
    private var squareSizeCell: UITableViewCell?
    private var speedCell: UITableViewCell?
    private var deathFadeCell: UITableViewCell?
    private var shiftingColorsCell: UITableViewCell?
    private var startingPatternCell: UITableViewCell?
    private var gridModeCell: UITableViewCell?
    private var respawnModeCell: UITableViewCell?
    private var cameraModeCell: UITableViewCell?

    // MARK: - View Lifecycle

    override func loadView() {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .black
        view = skView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupGestureRecognizers()

        manager.settingsDelegate = self

        // Migrate deprecated "Instant" speed to "Fastest"
        if manager.animationSpeed == .off {
            manager.setAnimationSpeed(.fastest)
        }

        if !manager.hasPressedMenuButton {
            bounceOrHideMenuHintToast(reverse: false)
        } else {
            menuHintToast.alpha = 0
        }

        createScene()
        hideInitialOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isUserInteractionEnabled = true
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if state == .colorPresets {
            return [colorPresetsView]
        } else {
            return [mainMenuView]
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        isCustomizeMode = manager.isCustomizeMode
        setupMainMenuPanel()
        setupColorPresetsPanel()
        setupToasts()
        setupKludgeButton()
        setupInitialOverlay()
        setupConstraints()
        setupPresetMenu()
    }

    private func setupMainMenuPanel() {
        view.addSubview(mainMenuView)

        mainMenuView.contentView.addSubview(headerView)
        mainMenuView.contentView.addSubview(menuTableView)
        mainMenuView.contentView.addSubview(footerView)

        NSLayoutConstraint.activate([
            mainMenuView.topAnchor.constraint(equalTo: view.topAnchor),
            mainMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainMenuView.widthAnchor.constraint(equalToConstant: 800),

            headerView.topAnchor.constraint(equalTo: mainMenuView.contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 225),

            menuTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30),
            menuTableView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor, constant: -100),
            // menuTableView.heightAnchor.constraint(equalToConstant: 770),
            menuTableView.bottomAnchor.constraint(equalTo: mainMenuView.contentView.bottomAnchor),

//            footerView.topAnchor.constraint(equalTo: menuTableView.bottomAnchor),
//            footerView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
//            footerView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor),
//            footerView.bottomAnchor.constraint(equalTo: mainMenuView.contentView.bottomAnchor)
        ])
    }

    private func setupColorPresetsPanel() {
        view.addSubview(colorPresetsView)

        colorPresetsView.contentView.addSubview(colorPresetsTableView)

        NSLayoutConstraint.activate([
            colorPresetsView.topAnchor.constraint(equalTo: view.topAnchor),
            colorPresetsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            colorPresetsView.widthAnchor.constraint(equalToConstant: 550),

            colorPresetsTableView.topAnchor.constraint(equalTo: colorPresetsView.contentView.layoutMarginsGuide.topAnchor),
            colorPresetsTableView.bottomAnchor.constraint(equalTo: colorPresetsView.contentView.layoutMarginsGuide.bottomAnchor),
            colorPresetsTableView.leadingAnchor.constraint(equalTo: colorPresetsView.contentView.layoutMarginsGuide.leadingAnchor, constant: 80),
            colorPresetsTableView.trailingAnchor.constraint(equalTo: colorPresetsView.contentView.layoutMarginsGuide.trailingAnchor, constant: -60)
        ])
    }

    private func setupToasts() {
        view.addSubview(menuHintToast)
        view.addSubview(mainMenuCloseToast)
        view.addSubview(colorMenuCloseToast)

        menuHintToast.layer.cornerRadius = 37.5
        menuHintToast.clipsToBounds = true
        menuHintToast.alpha = 1

        mainMenuCloseToast.layer.cornerRadius = 37.5
        mainMenuCloseToast.clipsToBounds = true
        mainMenuCloseToast.alpha = 0

        colorMenuCloseToast.layer.cornerRadius = 37.5
        colorMenuCloseToast.clipsToBounds = true
        colorMenuCloseToast.alpha = 0
    }

    private func setupKludgeButton() {
        view.addSubview(kludgeButton)
    }

    private func setupInitialOverlay() {
        view.addSubview(initialOverlayView)
    }

    private func setupConstraints() {
        mainMenuLeadingConstraint = mainMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        mainMenuLeadingConstraint.constant = -800
        mainMenuLeadingConstraint.isActive = true

        colorMenuTrailingConstraint = colorPresetsView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        colorMenuTrailingConstraint.constant = 550
        colorMenuTrailingConstraint.isActive = true

        menuHintToastConstraint = menuHintToast.leadingAnchor.constraint(equalTo: mainMenuView.trailingAnchor, constant: 35)
        menuHintToastConstraint.isActive = true

        NSLayoutConstraint.activate([
            menuHintToast.centerYAnchor.constraint(equalTo: mainMenuView.centerYAnchor),

            mainMenuCloseToast.leadingAnchor.constraint(equalTo: mainMenuView.trailingAnchor, constant: 35),
            mainMenuCloseToast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),

            colorMenuCloseToast.trailingAnchor.constraint(equalTo: colorPresetsView.leadingAnchor, constant: -35),
            colorMenuCloseToast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),

            kludgeButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            kludgeButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            initialOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            initialOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            initialOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            initialOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func createToast(text: String) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false

        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .prominent))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false

        vibrancyView.contentView.addSubview(label)
        blurView.contentView.addSubview(vibrancyView)

        NSLayoutConstraint.activate([
            vibrancyView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            vibrancyView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            vibrancyView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            vibrancyView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),

            label.topAnchor.constraint(equalTo: vibrancyView.contentView.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: vibrancyView.contentView.bottomAnchor, constant: -20),
            label.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: 30),
            label.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor, constant: -30)
        ])

        return blurView
    }

    // MARK: - UI Interactions

    fileprivate func setupGestureRecognizers() {
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeFromRight.direction = .left
        swipeFromRight.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        view.addGestureRecognizer(swipeFromRight)

        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeFromLeft.direction = .right
        swipeFromLeft.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        view.addGestureRecognizer(swipeFromLeft)

        pressedMenuButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(didPressMenuButton))
        pressedMenuButtonRecognizer!.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(pressedMenuButtonRecognizer!)
    }

    @objc func didPressMenuButton(gesture _: UIGestureRecognizer) {
        if state == .allClosed {
            showMainMenu()
        } else {
            hideAllMenus()
        }
    }

    @objc func didSwipeLeft(gesture _: UIGestureRecognizer) {
        if state == .mainMenu {
            hideAllMenus()
        }

        if state == .allClosed {
            showColorPresets()
        }
    }

    @objc func didSwipeRight(gesture _: UIGestureRecognizer) {
        if state == .colorPresets {
            hideAllMenus()
        }

        if state == .allClosed {
            showMainMenu()
        }
    }

    func showColorPresets() {
        cancelRunningAnimators()
        DispatchQueue.main.async {
            self.colorMenuTrailingConstraint.constant = 0
            self.mainMenuLeadingConstraint.constant = -self.mainMenuView.frame.width
            self.state = .colorPresets

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = 1
                self.mainMenuCloseToast.alpha = 0
            })
            propertyAnimator.addCompletion { _ in
                self.kludgeButton.alpha = 0
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            self.propertyAnimators.append(propertyAnimator)
            propertyAnimator.startAnimation()
        }
    }

    func showMainMenu() {
        cancelRunningAnimators()
        if !manager.hasPressedMenuButton {
            manager.setHasPressedMenuButton(true)
        }
        DispatchQueue.main.async {
            self.colorMenuTrailingConstraint.constant = self.colorPresetsView.frame.width
            self.mainMenuLeadingConstraint.constant = 0
            self.state = .mainMenu

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = 0
                self.mainMenuCloseToast.alpha = 1
            })
            propertyAnimator.addCompletion { _ in
                self.kludgeButton.alpha = 0
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            self.propertyAnimators.append(propertyAnimator)
            propertyAnimator.startAnimation()
        }
    }

    func hideAllMenus() {
        cancelRunningAnimators()
        DispatchQueue.main.async {
            self.colorMenuTrailingConstraint.constant = self.colorPresetsView.frame.width
            self.mainMenuLeadingConstraint.constant = -self.mainMenuView.frame.width
            self.state = .allClosed

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = 0
                self.mainMenuCloseToast.alpha = 0
            })
            propertyAnimator.addCompletion { _ in
                self.kludgeButton.alpha = 1
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            self.propertyAnimators.append(propertyAnimator)
            propertyAnimator.startAnimation()
        }
    }

    func cancelRunningAnimators() {
        propertyAnimators.forEach {
            $0.pauseAnimation()
            $0.stopAnimation(true)
        }
        propertyAnimators.removeAll()
    }

    // MARK: - View Setup

    fileprivate func createScene() {
        if let view = self.view as? SKView {
            scene = LifeScene(size: view.bounds.size)
            scene!.scaleMode = .aspectFit

            scene!.manager = manager

            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            view.presentScene(scene)
        }
    }

    fileprivate func setupPresetMenu() {
        // No initial selection - presets are actions, not persistent selections
    }

    fileprivate func hideInitialOverlay() {
        let fadeAction = UIViewPropertyAnimator(duration: 2, curve: .easeInOut) {
            self.initialOverlayView.alpha = 0
        }
        fadeAction.addCompletion { state in
            switch state {
            case .end:
                self.initialOverlayView.removeFromSuperview()
                self.setNeedsFocusUpdate()
            default:
                return
            }
        }
        fadeAction.startAnimation(afterDelay: 1)
    }

    fileprivate func bounceOrHideMenuHintToast(reverse: Bool) {
        if !manager.hasPressedMenuButton {
            menuHintToastConstraint.constant = reverse ? 35 : 15
            menuHintBounceAnimation = UIViewPropertyAnimator(duration: 1.5, curve: .easeInOut, animations: nil)
        } else {
            menuHintBounceAnimation?.stopAnimation(true)
            menuHintToastConstraint.constant = 35
            menuHintBounceAnimation = UIViewPropertyAnimator(duration: 1, curve: .easeIn, animations: nil)
            menuHintBounceAnimation?.addAnimations {
                self.menuHintToast.alpha = 0
            }
        }
        menuHintBounceAnimation?.addAnimations {
            self.view.layoutIfNeeded()
        }
        menuHintBounceAnimation?.addCompletion { state in
            if state == .end {
                self.bounceOrHideMenuHintToast(reverse: !reverse)
            }
        }
        menuHintBounceAnimation?.startAnimation()
    }

    // MARK: - LifeManagerDelegate

    func updatedSettings() {
        updateSquareSizeCellText()
        updateSpeedCellText()
        updateShiftingColorsCellText()
        updateDeathFadeCellText()
        updateStartingPatternCellText()
        updateGridModeCellText()
        updateRespawnModeCellText()
        updateCameraModeCellText()
    }

    // MARK: - Menu Picker Methods (from MenuTableViewController)

    fileprivate func showColorShiftingPicker() {
        let alert = UIAlertController(
            title: "Shifting Color",
            message: "When this is enabled, the colors of newly born squares will be slightly mutated, leading to a color shift over time.",
            preferredStyle: .actionSheet
        )

        let onAction = UIAlertAction(title: "On", style: .default) { _ in
            self.manager.setShiftingColors(true)
        }
        alert.addAction(onAction)

        let offAction = UIAlertAction(title: "Off", style: .default) { _ in
            self.manager.setShiftingColors(false)
        }
        alert.addAction(offAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showAboutPage() {
        let alert = UIAlertController(title: "About Life Saver", message: """
        Life Saver is an artistic implementation of the Game of Life, a cellular automaton created by mathematician John Conway in 1972.

        Life Saver is open source software, which means you can see how it works and use it to make your own versions or modifications.

        For more information, visit https://github.com/amiantos/lifesaver
        """, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showSpeedPicker() {
        let alert = UIAlertController(
            title: "Animation Speed",
            message: """
            This governs how quickly change animations occur. \
            Slower speeds lead to more abstract, shifting colors. \
            Faster speeds make the simulation easier to observe.
            """,
            preferredStyle: .actionSheet
        )

        let slowAction = UIAlertAction(title: "Slowest", style: .default) { _ in
            self.manager.setAnimationSpeed(.slow)
        }
        alert.addAction(slowAction)

        let normalAction = UIAlertAction(title: "Slower", style: .default) { _ in
            self.manager.setAnimationSpeed(.normal)
        }
        alert.addAction(normalAction)

        let fastAction = UIAlertAction(title: "Slow", style: .default) { _ in
            self.manager.setAnimationSpeed(.fast)
        }
        alert.addAction(fastAction)

        let mediumAction = UIAlertAction(title: "Medium", style: .default) { _ in
            self.manager.setAnimationSpeed(.medium)
        }
        alert.addAction(mediumAction)

        let fastestAction = UIAlertAction(title: "Fast", style: .default) { _ in
            self.manager.setAnimationSpeed(.fastest)
        }
        alert.addAction(fastestAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    fileprivate func showDeathFadePicker() {
        let alert = UIAlertController(
            title: "Death Fade",
            message: """
            With death fade turned on, when a cell dies, it will fade into the background, \
            and eventually fade out completely. With death fade turned off, the cell color \
            will persist on the screen until it comes back to life as another color.
            """,
            preferredStyle: .actionSheet
        )

        let onAction = UIAlertAction(title: "On", style: .default) { _ in
            self.manager.setDeathFade(true)
        }
        alert.addAction(onAction)

        let offAction = UIAlertAction(title: "Off", style: .default) { _ in
            self.manager.setDeathFade(false)
        }
        alert.addAction(offAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showSquareSizePicker() {
        let alert = UIAlertController(
            title: "Square Size",
            message: """
            This governs the size of the squares on screen. \
            Larger squares are more abstract, while smaller squares allow you to see the simulation easier.
            """,
            preferredStyle: .actionSheet
        )

        let largeAction = UIAlertAction(title: "Large", style: .default) { _ in
            self.manager.setSquareSize(.large)
        }
        alert.addAction(largeAction)

        let mediumAction = UIAlertAction(title: "Medium", style: .default) { _ in
            self.manager.setSquareSize(.medium)
        }
        alert.addAction(mediumAction)

        let smallAction = UIAlertAction(title: "Small", style: .default) { _ in
            self.manager.setSquareSize(.small)
        }
        alert.addAction(smallAction)

        let tinyAction = UIAlertAction(title: "Tiny", style: .default) { _ in
            self.manager.setSquareSize(.verySmall)
        }
        alert.addAction(tinyAction)

        let miniAction = UIAlertAction(title: "Mini", style: .default) { _ in
            self.manager.setSquareSize(.superSmall)
        }
        alert.addAction(miniAction)

        let microAction = UIAlertAction(title: "Micro", style: .default) { _ in
            self.manager.setSquareSize(.ultraSmall)
        }
        alert.addAction(microAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showGridModePicker() {
        let alert = UIAlertController(
            title: "Grid Mode",
            message: """
            Toroidal: Edges wrap around - patterns that exit one side reappear on the opposite side.
            Infinite: Simulates an unbounded grid - patterns smoothly exit the screen and eventually die off-screen.
            """,
            preferredStyle: .actionSheet
        )

        let toroidalAction = UIAlertAction(title: "Toroidal", style: .default) { _ in
            self.manager.setGridMode(.toroidal)
            self.updateGridModeCellText()
        }
        alert.addAction(toroidalAction)

        let infiniteAction = UIAlertAction(title: "Infinite", style: .default) { _ in
            self.manager.setGridMode(.infinite)
            self.updateGridModeCellText()
        }
        alert.addAction(infiniteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showRespawnModePicker() {
        let alert = UIAlertController(
            title: "Respawn Mode",
            message: """
            Fresh Start: Clears the board before spawning new life when stasis is detected.
            Add Life: Adds new life to existing cells, which can lead to more varied patterns over time.
            """,
            preferredStyle: .actionSheet
        )

        let freshStartAction = UIAlertAction(title: "Fresh Start", style: .default) { _ in
            self.manager.setRespawnMode(.freshStart)
            self.updateRespawnModeCellText()
        }
        alert.addAction(freshStartAction)

        let addLifeAction = UIAlertAction(title: "Add Life", style: .default) { _ in
            self.manager.setRespawnMode(.addLife)
            self.updateRespawnModeCellText()
        }
        alert.addAction(addLifeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showCameraModePicker() {
        let alert = UIAlertController(
            title: "Camera",
            message: """
            Static: Fixed camera view (default behavior).
            Ken Burns: Slow, smooth zoom and pan effect for visual interest.
            """,
            preferredStyle: .actionSheet
        )

        let staticAction = UIAlertAction(title: "Static", style: .default) { _ in
            self.manager.setCameraMode(.static)
            self.updateCameraModeCellText()
        }
        alert.addAction(staticAction)

        let kenBurnsAction = UIAlertAction(title: "Ken Burns", style: .default) { _ in
            self.manager.setCameraMode(.kenBurns)
            self.updateCameraModeCellText()
        }
        alert.addAction(kenBurnsAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showStartingPatternPicker() {
        let alert = UIAlertController(
            title: "Starting Pattern",
            message: """
            This controls how life spawns when the grid is empty or reaches stasis.
            """,
            preferredStyle: .actionSheet
        )

        let defaultAction = UIAlertAction(title: "Default", style: .default) { _ in
            self.manager.setStartingPattern(.defaultRandom)
            self.updateStartingPatternCellText()
        }
        alert.addAction(defaultAction)

        let sparseAction = UIAlertAction(title: "Sparse", style: .default) { _ in
            self.manager.setStartingPattern(.sparse)
            self.updateStartingPatternCellText()
        }
        alert.addAction(sparseAction)

        let glidersAction = UIAlertAction(title: "Gliders", style: .default) { _ in
            self.manager.setStartingPattern(.gliders)
            self.updateStartingPatternCellText()
        }
        alert.addAction(glidersAction)

        let sparseGlidersAction = UIAlertAction(title: "Sparse Gliders", style: .default) { _ in
            self.manager.setStartingPattern(.sparseGliders)
            self.updateStartingPatternCellText()
        }
        alert.addAction(sparseGlidersAction)

        let lonelyGlidersAction = UIAlertAction(title: "Lonely Gliders", style: .default) { _ in
            self.manager.setStartingPattern(.lonelyGliders)
            self.updateStartingPatternCellText()
        }
        alert.addAction(lonelyGlidersAction)
        
        let gosperGunAction = UIAlertAction(title: "Gosper Gun", style: .default) { _ in
            self.manager.setStartingPattern(.gosperGun)
            self.updateStartingPatternCellText()
        }
        alert.addAction(gosperGunAction)

        let rPentominoAction = UIAlertAction(title: "R-pentomino", style: .default) { _ in
            self.manager.setStartingPattern(.rPentomino)
            self.updateStartingPatternCellText()
        }
        alert.addAction(rPentominoAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Delegate & DataSource

extension LifeViewController: UITableViewDelegate, UITableViewDataSource {

    // Main menu sections
    private enum MenuSection: Int {
        case mainContent = 0  // Either presets or settings depending on mode
        case navigation = 1
    }

    private enum NavigationRow: Int {
        case showPresets = 0
        case toggleMode = 1  // "Customize" or "Quick Start" depending on mode
        case about = 2
    }

    private enum SettingsRow: Int {
        case squareSize = 0
        case animationSpeed = 1
        case deathFade = 2
        case shiftingColors = 3
        case startingPattern = 4
        case gridMode = 5
        case respawnMode = 6
        case cameraMode = 7
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === menuTableView {
            return 2  // Main content + Navigation
        } else {
            // Color presets table
            return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === menuTableView {
            if section == MenuSection.mainContent.rawValue {
                return isCustomizeMode ? "Settings" : "Quick Start"
            }
            return nil
        } else {
            // Color presets table
            return "Color Presets"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === menuTableView {
            if section == MenuSection.mainContent.rawValue {
                return isCustomizeMode ? 8 : settingsPresets.count
            } else {
                return 3  // Show Color Presets, Customize/Quick Start, About
            }
        } else {
            // Color presets table - only color presets (excluding Custom)
            return colorPresets.count - 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === menuTableView {
            return menuCellForRowAt(indexPath)
        } else {
            return colorPresetCellForRowAt(tableView, indexPath: indexPath)
        }
    }

    private func menuCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == MenuSection.mainContent.rawValue {
            if isCustomizeMode {
                return settingsCellForRowAt(indexPath)
            } else {
                return presetCellForRowAt(indexPath)
            }
        } else {
            return navigationCellForRowAt(indexPath)
        }
    }

    private func presetCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "PresetCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "PresetCell")

        let preset = settingsPresets[indexPath.row]
        cell.textLabel?.text = preset.title
        cell.accessoryType = .none
        return cell
    }

    private func settingsCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "SettingsCell")
            ?? UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")

        cell.accessoryType = .disclosureIndicator

        switch indexPath.row {
        case SettingsRow.squareSize.rawValue:
            cell.textLabel?.text = "Square Size"
            squareSizeCell = cell
            updateSquareSizeCellText()

        case SettingsRow.animationSpeed.rawValue:
            cell.textLabel?.text = "Animation"
            speedCell = cell
            updateSpeedCellText()

        case SettingsRow.deathFade.rawValue:
            cell.textLabel?.text = "Death Fade"
            deathFadeCell = cell
            updateDeathFadeCellText()

        case SettingsRow.shiftingColors.rawValue:
            cell.textLabel?.text = "Shifting Colors"
            shiftingColorsCell = cell
            updateShiftingColorsCellText()

        case SettingsRow.startingPattern.rawValue:
            cell.textLabel?.text = "Starting Pattern"
            startingPatternCell = cell
            updateStartingPatternCellText()

        case SettingsRow.gridMode.rawValue:
            cell.textLabel?.text = "Grid Mode"
            gridModeCell = cell
            updateGridModeCellText()

        case SettingsRow.respawnMode.rawValue:
            cell.textLabel?.text = "Respawn Mode"
            respawnModeCell = cell
            updateRespawnModeCellText()

        case SettingsRow.cameraMode.rawValue:
            cell.textLabel?.text = "Camera"
            cameraModeCell = cell
            updateCameraModeCellText()

        default:
            break
        }

        return cell
    }

    private func navigationCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "NavigationCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "NavigationCell")

        // Reset cell state
        cell.textLabel?.text = nil
        cell.accessoryType = .none

        switch indexPath.row {
        case NavigationRow.showPresets.rawValue:
            cell.textLabel?.text = "Show Color Presets"

        case NavigationRow.toggleMode.rawValue:
            cell.textLabel?.text = isCustomizeMode ? "Quick Start" : "Customize"

        case NavigationRow.about.rawValue:
            cell.textLabel?.text = "About"
            cell.accessoryType = .disclosureIndicator

        default:
            break
        }

        return cell
    }

    private func colorPresetCellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ColorPresetTableViewCell.reuseIdentifier, for: indexPath) as? ColorPresetTableViewCell {
            let preset = colorPresets[indexPath.row]
            cell.titleLabel.text = preset.title
            return cell
        }

        return UITableViewCell()
    }

    private func updateSquareSizeCellText() {
        switch manager.squareSize {
        case .large:
            squareSizeCell?.detailTextLabel?.text = "Large"
        case .medium:
            squareSizeCell?.detailTextLabel?.text = "Medium"
        case .small:
            squareSizeCell?.detailTextLabel?.text = "Small"
        case .verySmall:
            squareSizeCell?.detailTextLabel?.text = "Tiny"
        case .superSmall:
            squareSizeCell?.detailTextLabel?.text = "Mini"
        case .ultraSmall:
            squareSizeCell?.detailTextLabel?.text = "Micro"
        }
    }

    private func updateSpeedCellText() {
        switch manager.animationSpeed {
        case .slow:
            speedCell?.detailTextLabel?.text = "Slowest"
        case .normal:
            speedCell?.detailTextLabel?.text = "Slower"
        case .fast:
            speedCell?.detailTextLabel?.text = "Slow"
        case .medium:
            speedCell?.detailTextLabel?.text = "Medium"
        case .fastest:
            speedCell?.detailTextLabel?.text = "Fast"
        case .off:
            speedCell?.detailTextLabel?.text = "Instant"
        }
    }

    private func updateDeathFadeCellText() {
        let deathFadeTitle = manager.deathFade ? "On" : "Off"
        deathFadeCell?.detailTextLabel?.text = deathFadeTitle
    }

    private func updateShiftingColorsCellText() {
        let shiftingColorsTitle = manager.shiftingColors ? "On" : "Off"
        shiftingColorsCell?.detailTextLabel?.text = shiftingColorsTitle
    }

    private func updateStartingPatternCellText() {
        switch manager.startingPattern {
        case .defaultRandom:
            startingPatternCell?.detailTextLabel?.text = "Default"
        case .sparse:
            startingPatternCell?.detailTextLabel?.text = "Sparse"
        case .gliders:
            startingPatternCell?.detailTextLabel?.text = "Gliders"
        case .sparseGliders:
            startingPatternCell?.detailTextLabel?.text = "Sparse Gliders"
        case .lonelyGliders:
            startingPatternCell?.detailTextLabel?.text = "Lonely Gliders"
        case .gosperGun:
            startingPatternCell?.detailTextLabel?.text = "Gosper Gun"
        case .rPentomino:
            startingPatternCell?.detailTextLabel?.text = "R-pentomino"
        case .acorn:
            startingPatternCell?.detailTextLabel?.text = "Acorn"
        case .pulsar:
            startingPatternCell?.detailTextLabel?.text = "Pulsar"
        case .pufferTrain:
            startingPatternCell?.detailTextLabel?.text = "Puffer Train"
        case .piFusePuffer:
            startingPatternCell?.detailTextLabel?.text = "Pi Fuse Puffer"
        }
    }

    private func updateGridModeCellText() {
        switch manager.gridMode {
        case .toroidal:
            gridModeCell?.detailTextLabel?.text = "Toroidal"
        case .infinite:
            gridModeCell?.detailTextLabel?.text = "Infinite"
        }
    }

    private func updateRespawnModeCellText() {
        switch manager.respawnMode {
        case .freshStart:
            respawnModeCell?.detailTextLabel?.text = "Fresh Start"
        case .addLife:
            respawnModeCell?.detailTextLabel?.text = "Add Life"
        }
    }

    private func updateCameraModeCellText() {
        switch manager.cameraMode {
        case .static:
            cameraModeCell?.detailTextLabel?.text = "Static"
        case .kenBurns:
            cameraModeCell?.detailTextLabel?.text = "Ken Burns"
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === menuTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            handleMenuSelection(indexPath)
        } else {
            handleColorPresetSelection(indexPath)
        }
    }

    private func handleMenuSelection(_ indexPath: IndexPath) {
        if indexPath.section == MenuSection.mainContent.rawValue {
            if isCustomizeMode {
                handleSettingsSelection(indexPath)
            } else {
                let preset = settingsPresets[indexPath.row]
                manager.configure(with: preset)
            }
        } else {
            // Navigation section
            switch indexPath.row {
            case NavigationRow.showPresets.rawValue:
                showColorPresets()
            case NavigationRow.toggleMode.rawValue:
                toggleCustomizeMode()
            case NavigationRow.about.rawValue:
                showAboutPage()
            default:
                break
            }
        }
    }

    private func handleSettingsSelection(_ indexPath: IndexPath) {
        switch indexPath.row {
        case SettingsRow.squareSize.rawValue:
            showSquareSizePicker()
        case SettingsRow.animationSpeed.rawValue:
            showSpeedPicker()
        case SettingsRow.deathFade.rawValue:
            showDeathFadePicker()
        case SettingsRow.shiftingColors.rawValue:
            showColorShiftingPicker()
        case SettingsRow.startingPattern.rawValue:
            showStartingPatternPicker()
        case SettingsRow.gridMode.rawValue:
            showGridModePicker()
        case SettingsRow.respawnMode.rawValue:
            showRespawnModePicker()
        case SettingsRow.cameraMode.rawValue:
            showCameraModePicker()
        default:
            break
        }
    }

    private func handleColorPresetSelection(_ indexPath: IndexPath) {
        let preset = colorPresets[indexPath.row]
        manager.configure(with: preset)
    }

    private func toggleCustomizeMode() {
        isCustomizeMode = !isCustomizeMode
        manager.setIsCustomizeMode(isCustomizeMode)
        menuTableView.reloadData()

        // Deselect all cells and scroll to top
        if let selectedIndexPath = menuTableView.indexPathForSelectedRow {
            menuTableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        menuTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)

        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
}
