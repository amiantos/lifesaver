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

class LifeViewController: UIViewController, MenuTableDelegate {
    var scene: LifeScene?
    let manager = LifeManager()
    var state: UIState = .allClosed

    @IBOutlet var colorPresetsTableView: UITableView!
    @IBOutlet var colorPresetsView: UIVisualEffectView!
    @IBOutlet var mainMenuView: UIVisualEffectView!

    @IBOutlet var mainMenuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var colorMenuTrailingConstraint: NSLayoutConstraint!

    @IBOutlet var colorMenuCloseToast: UIVisualEffectView!
    @IBOutlet var mainMenuCloseToast: UIVisualEffectView!

    @IBOutlet weak var kludgeButton: UIButton!
    @IBOutlet weak var initialOverlayView: UIView!

    var menuTableViewController: MenuTableViewController?
    var pressedMenuButton: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupView()
        hideInitialOverlay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.isUserInteractionEnabled = true

        setupPresetMenu()
        setupGestureRecognizers()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if state == .colorPresets {
            return [colorPresetsView]
        } else {
            return [mainMenuView]
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "menuEmbedSegue" {
            if let tableViewController = segue.destination as? MenuTableViewController {
                menuTableViewController = tableViewController
                menuTableViewController?.manager = manager
                menuTableViewController?.delegate = self
                manager.settingsDelegate = tableViewController
            }
        }
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

        pressedMenuButton = UITapGestureRecognizer(target: self, action: #selector(didPressMenuButton))
        pressedMenuButton!.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(pressedMenuButton!)
    }

    @objc func didPressMenuButton(gesture: UIGestureRecognizer) {
        print("Pressed Menu")
        showMainMenu()
    }

    @objc func didSwipeLeft(gesture _: UIGestureRecognizer) {
        DispatchQueue.main.async {
            var colorMenuToastAlpha: CGFloat = 0
            let mainMenuToastAlpha: CGFloat = 0

            if self.state == .allClosed {
                self.colorMenuTrailingConstraint.constant = 0
                colorMenuToastAlpha = 1
                self.state = .colorPresets
            }

            if self.state == .mainMenu {
                self.mainMenuLeadingConstraint.constant = -self.mainMenuView.frame.width
                self.state = .allClosed
            }

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = colorMenuToastAlpha
                self.mainMenuCloseToast.alpha = mainMenuToastAlpha
            })
            propertyAnimator.addCompletion { _ in
                if self.state == .allClosed {
                    self.kludgeButton.alpha = 1
                } else {
                    self.kludgeButton.alpha = 0
                }
                self.pressedMenuButton?.isEnabled = true
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            propertyAnimator.startAnimation()
        }
    }

    @objc func didSwipeRight(gesture _: UIGestureRecognizer) {
        DispatchQueue.main.async {
            let colorMenuToastAlpha: CGFloat = 0
            var mainMenuToastAlpha: CGFloat = 0

            if self.state == .allClosed {
                self.mainMenuLeadingConstraint.constant = 0
                mainMenuToastAlpha = 1
                self.state = .mainMenu
            }

            if self.state == .colorPresets {
                self.colorMenuTrailingConstraint.constant = -self.colorPresetsView.frame.width
                self.state = .allClosed
            }

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = colorMenuToastAlpha
                self.mainMenuCloseToast.alpha = mainMenuToastAlpha
            })
            propertyAnimator.addCompletion { _ in
                if self.state == .allClosed {
                    self.kludgeButton.alpha = 1
                    self.pressedMenuButton?.isEnabled = true
                } else {
                    self.kludgeButton.alpha = 0
                    self.pressedMenuButton?.isEnabled = false
                }
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            propertyAnimator.startAnimation()
        }
    }

    func showColorPresets() {
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
                self.pressedMenuButton?.isEnabled = false
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            propertyAnimator.startAnimation()
        }
    }

    func showMainMenu() {
        DispatchQueue.main.async {
            self.colorMenuTrailingConstraint.constant = -self.colorPresetsView.frame.width
            self.mainMenuLeadingConstraint.constant = 0
            self.state = .mainMenu

            let propertyAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
                self.view.layoutIfNeeded()
                self.colorMenuCloseToast.alpha = 0
                self.mainMenuCloseToast.alpha = 1
            })
            propertyAnimator.addCompletion { _ in
                self.kludgeButton.alpha = 0
                self.pressedMenuButton?.isEnabled = false
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
            propertyAnimator.startAnimation()
        }
    }

    // MARK: - View Setup

    fileprivate func setupView() {
        colorMenuCloseToast.layer.cornerRadius = colorMenuCloseToast.frame.height / 2
        colorMenuCloseToast.clipsToBounds = true
        colorMenuCloseToast.alpha = 0
        colorMenuTrailingConstraint.constant = -colorPresetsView.frame.width

        mainMenuCloseToast.layer.cornerRadius = colorMenuCloseToast.frame.height / 2
        mainMenuCloseToast.clipsToBounds = true
        mainMenuCloseToast.alpha = 0
        mainMenuLeadingConstraint.constant = -mainMenuView.frame.width

        updateViewConstraints()

        if let view = self.view as? SKView {
            scene = LifeScene(size: view.bounds.size)
            scene!.scaleMode = .aspectFit

            scene!.manager = manager

            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            view.presentScene(scene)

            colorPresetsTableView.delegate = self
            colorPresetsTableView.dataSource = self
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

}

extension LifeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Color Presets"
        } else {
            return "Presets"
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return colorPresets.count - 1
        } else {
            return settingsPresets.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1,
            let cell = tableView.dequeueReusableCell(withIdentifier: "presetCell", for: indexPath) as? ColorPresetTableViewCell {
            let colorPreset = colorPresets[indexPath.row]
            cell.titleLabel.text = colorPreset.title
            return cell
        }

        if indexPath.section == 0,
            let cell = tableView.dequeueReusableCell(withIdentifier: "presetCell", for: indexPath) as? ColorPresetTableViewCell {
            let settingPreset = settingsPresets[indexPath.row]
            cell.titleLabel.text = settingPreset.title
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let colorPreset = colorPresets[indexPath.row]
            manager.configure(with: colorPreset)
        } else if indexPath.section == 0 {
            let settingPreset = settingsPresets[indexPath.row]
            manager.configure(with: settingPreset)
        }
    }
}
