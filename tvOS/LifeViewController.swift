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
            titleLabel.centerYAnchor.constraint(equalTo: view.contentView.centerYAnchor, constant: -10),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor, constant: 375)
        ])

        return view
    }()

    // Footer view for main menu
    private lazy var footerView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular))
        let view = UIVisualEffectView(effect: vibrancyEffect)
        view.translatesAutoresizingMaskIntoConstraints = false

        let urlLabel = UILabel()
        urlLabel.text = "https://amiantos.net/lifesaver"
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

    // MARK: - Data Sources

    let tableViewSource: [Int: [LifePreset]] = [0: settingsPresets, 1: colorPresets]

    var pressedMenuButtonRecognizer: UITapGestureRecognizer?
    var propertyAnimators: [UIViewPropertyAnimator] = []
    var menuHintBounceAnimation: UIViewPropertyAnimator?

    // Menu cells for updating detail labels
    private var squareSizeCell: UITableViewCell?
    private var speedCell: UITableViewCell?
    private var deathFadeCell: UITableViewCell?
    private var shiftingColorsCell: UITableViewCell?

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
            mainMenuView.widthAnchor.constraint(equalToConstant: 700),

            headerView.topAnchor.constraint(equalTo: mainMenuView.contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 250),

            menuTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor, constant: -100),
            menuTableView.heightAnchor.constraint(equalToConstant: 670),

            footerView.topAnchor.constraint(equalTo: menuTableView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: mainMenuView.contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: mainMenuView.contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: mainMenuView.contentView.bottomAnchor)
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
        mainMenuLeadingConstraint.constant = -700
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
        showMainMenu()
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
            self.pressedMenuButtonRecognizer?.isEnabled = true

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
            self.pressedMenuButtonRecognizer?.isEnabled = false

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
            self.pressedMenuButtonRecognizer?.isEnabled = true

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
        let selectedPresetTitle = manager.selectedPresetTitle == "" ? "Default" : manager.selectedPresetTitle
        var filteredPresets = colorPresets.filter { $0.title == selectedPresetTitle }
        if filteredPresets.isEmpty {
            filteredPresets = settingsPresets.filter { $0.title == selectedPresetTitle }
        }
        if let selectedPreset = filteredPresets.first {
            var index = colorPresets.firstIndex(where: { $0.title == selectedPreset.title })
            var section = 1
            if index == nil {
                section = 0
                index = settingsPresets.firstIndex(where: { $0.title == selectedPreset.title })
            }
            colorPresetsTableView.selectRow(
                at: IndexPath(
                    row: index ?? colorPresets.count - 1,
                    section: section
                ),
                animated: false,
                scrollPosition: .top
            )
        }
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
        if let manager = Optional(manager) {
            switch manager.squareSize {
            case .superSmall:
                squareSizeCell?.detailTextLabel?.text = "XX Small"
            case .verySmall:
                squareSizeCell?.detailTextLabel?.text = "Tiny"
            case .small:
                squareSizeCell?.detailTextLabel?.text = "Small"
            case .medium:
                squareSizeCell?.detailTextLabel?.text = "Medium"
            case .large:
                squareSizeCell?.detailTextLabel?.text = "Large"
            case .ultraSmall:
                squareSizeCell?.detailTextLabel?.text = "XXX Small"
            }

            switch manager.animationSpeed {
            case .normal:
                speedCell?.detailTextLabel?.text = "Normal"
            case .fast:
                speedCell?.detailTextLabel?.text = "Fast"
            case .slow:
                speedCell?.detailTextLabel?.text = "Slow"
            case .off:
                speedCell?.detailTextLabel?.text = "Instant"
            case .fastest:
                speedCell?.detailTextLabel?.text = "Fastest"
            }

            let randomColorPresetTitle = manager.shiftingColors ? "On" : "Off"
            shiftingColorsCell?.detailTextLabel?.text = randomColorPresetTitle

            let deathFadeTitle = manager.deathFade ? "On" : "Off"
            deathFadeCell?.detailTextLabel?.text = deathFadeTitle
        }
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

        For more information, visit https://amiantos.net/lifesaver
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

        let defaultAction = UIAlertAction(title: "Normal", style: .default) { _ in
            self.manager.setAnimationSpeed(.normal)
        }
        alert.addAction(defaultAction)

        let fastAction = UIAlertAction(title: "Fast", style: .default) { _ in
            self.manager.setAnimationSpeed(.fast)
        }
        alert.addAction(fastAction)

        let offAction = UIAlertAction(title: "Instant", style: .default) { _ in
            self.manager.setAnimationSpeed(.off)
        }
        alert.addAction(offAction)

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
        let xSmallAction = UIAlertAction(title: "Tiny", style: .default) { _ in
            self.manager.setSquareSize(.verySmall)
        }
        alert.addAction(xSmallAction)

        let smallAction = UIAlertAction(title: "Small", style: .default) { _ in
            self.manager.setSquareSize(.small)
        }
        alert.addAction(smallAction)

        let mediumAction = UIAlertAction(title: "Medium", style: .default) { _ in
            self.manager.setSquareSize(.medium)
        }
        alert.addAction(mediumAction)

        let largeAction = UIAlertAction(title: "Large", style: .default) { _ in
            self.manager.setSquareSize(.large)
        }
        alert.addAction(largeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Delegate & DataSource

extension LifeViewController: UITableViewDelegate, UITableViewDataSource {

    // Menu sections/rows
    private enum MenuSection: Int {
        case settings = 0
        case about = 1
    }

    private enum SettingsRow: Int {
        case squareSize = 0
        case animationSpeed = 1
        case deathFade = 2
        case shiftingColors = 3
        case showPresets = 4
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === menuTableView {
            return 2
        } else {
            // Color presets table
            return 2
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView === menuTableView {
            return nil
        } else {
            if section == 1 {
                return "Color Presets"
            } else {
                return "Presets"
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === menuTableView {
            if section == 0 {
                return 5 // Square Size, Animation, Death Fade, Shifting Colors, Show Presets
            } else {
                return 1 // About
            }
        } else {
            // Color presets table
            if section == 1 {
                return colorPresets.count - 1
            } else {
                return settingsPresets.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === menuTableView {
            return menuCellForRowAt(indexPath)
        } else {
            return presetCellForRowAt(tableView, indexPath: indexPath)
        }
    }

    private func menuCellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case SettingsRow.squareSize.rawValue:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Square Size"
                cell.accessoryType = .disclosureIndicator
                squareSizeCell = cell
                updateSquareSizeCellText()
                return cell

            case SettingsRow.animationSpeed.rawValue:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Animation"
                cell.accessoryType = .disclosureIndicator
                speedCell = cell
                updateSpeedCellText()
                return cell

            case SettingsRow.deathFade.rawValue:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Death Fade"
                cell.accessoryType = .disclosureIndicator
                deathFadeCell = cell
                updateDeathFadeCellText()
                return cell

            case SettingsRow.shiftingColors.rawValue:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Shifting Colors"
                cell.accessoryType = .disclosureIndicator
                shiftingColorsCell = cell
                updateShiftingColorsCellText()
                return cell

            case SettingsRow.showPresets.rawValue:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Show Presets"
                return cell

            default:
                return UITableViewCell()
            }
        } else {
            // About section
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "About"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    private func presetCellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ColorPresetTableViewCell.reuseIdentifier, for: indexPath) as? ColorPresetTableViewCell,
            let preset = tableViewSource[indexPath.section]?[indexPath.row] {
            cell.titleLabel.text = preset.title
            return cell
        }

        return UITableViewCell()
    }

    private func updateSquareSizeCellText() {
        switch manager.squareSize {
        case .superSmall:
            squareSizeCell?.detailTextLabel?.text = "XX Small"
        case .verySmall:
            squareSizeCell?.detailTextLabel?.text = "Tiny"
        case .small:
            squareSizeCell?.detailTextLabel?.text = "Small"
        case .medium:
            squareSizeCell?.detailTextLabel?.text = "Medium"
        case .large:
            squareSizeCell?.detailTextLabel?.text = "Large"
        case .ultraSmall:
            squareSizeCell?.detailTextLabel?.text = "XXX Small"
        }
    }

    private func updateSpeedCellText() {
        switch manager.animationSpeed {
        case .normal:
            speedCell?.detailTextLabel?.text = "Normal"
        case .fast:
            speedCell?.detailTextLabel?.text = "Fast"
        case .slow:
            speedCell?.detailTextLabel?.text = "Slow"
        case .off:
            speedCell?.detailTextLabel?.text = "Instant"
        case .fastest:
            speedCell?.detailTextLabel?.text = "Fastest"
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === menuTableView {
            tableView.deselectRow(at: indexPath, animated: true)
            handleMenuSelection(indexPath)
        } else {
            handlePresetSelection(indexPath)
        }
    }

    private func handleMenuSelection(_ indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, SettingsRow.squareSize.rawValue):
            showSquareSizePicker()
        case (0, SettingsRow.animationSpeed.rawValue):
            showSpeedPicker()
        case (0, SettingsRow.deathFade.rawValue):
            showDeathFadePicker()
        case (0, SettingsRow.shiftingColors.rawValue):
            showColorShiftingPicker()
        case (0, SettingsRow.showPresets.rawValue):
            showColorPresets()
        case (1, 0):
            showAboutPage()
        default:
            return
        }
    }

    private func handlePresetSelection(_ indexPath: IndexPath) {
        if let preset = tableViewSource[indexPath.section]?[indexPath.row] {
            manager.configure(with: preset)
        }
    }
}
