//
//  MenuTableViewController.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 6/26/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

protocol MenuTableDelegate: AnyObject {
    func showColorPresets()
}

class MenuTableViewController: UITableViewController, LifeManagerDelegate {
    @IBOutlet var squareSizeCell: UITableViewCell!
    @IBOutlet var speedCell: UITableViewCell!
    @IBOutlet var deathFadeCell: UITableViewCell!
    @IBOutlet var randomPresetColorCell: UITableViewCell!
    @IBOutlet var showColorPresetsCell: UITableViewCell!
    @IBOutlet var aboutCell: UITableViewCell!

    weak var manager: LifeManager?
    weak var delegate: MenuTableDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        updatedSettings()
    }

    func updatedSettings() {
        // MARK: - Set up config views

        if let manager = manager {
            switch manager.squareSize {
            case .superSmall:
                squareSizeCell.detailTextLabel?.text = "XX Small"
            case .verySmall:
                squareSizeCell.detailTextLabel?.text = "Tiny"
            case .small:
                squareSizeCell.detailTextLabel?.text = "Small"
            case .medium:
                squareSizeCell.detailTextLabel?.text = "Medium"
            case .large:
                squareSizeCell.detailTextLabel?.text = "Large"
            }

            switch manager.animationSpeed {
            case .normal:
                speedCell.detailTextLabel?.text = "Normal"
            case .fast:
                speedCell.detailTextLabel?.text = "Fast"
            case .slow:
                speedCell.detailTextLabel?.text = "Slow"
            case .off:
                speedCell.detailTextLabel?.text = "Off"
            }

            let randomColorPresetTitle = manager.shiftingColors ? "On" : "Off"
            randomPresetColorCell.detailTextLabel?.text = randomColorPresetTitle
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((indexPath.section, indexPath.row))
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            showSquareSizePicker()
        case (0, 1):
            showSpeedPicker()
        case (0, 2):
            showDeathFadePicker()
        case (0, 3):
            showColorShiftingPicker()
        case (0, 4):
            delegate?.showColorPresets()
        case (1, 0):
            showAboutPage()
        default:
            return
        }
    }

    fileprivate func showColorShiftingPicker() {
        let alert = UIAlertController(
            title: "Shifting Color",
            message: "When this is enabled, the colors of newly born squares will be slightly mutated, leading to a color shift over time.",
            preferredStyle: .actionSheet
        )

        let onAction = UIAlertAction(title: "On", style: .default) { _ in
            self.manager?.setShiftingColors(true)
            self.randomPresetColorCell.detailTextLabel?.text = "On"
        }
        alert.addAction(onAction)

        let offAction = UIAlertAction(title: "Off", style: .default) { _ in
            self.manager?.setShiftingColors(false)
            self.randomPresetColorCell.detailTextLabel?.text = "Off"
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
                This governs how quickly animations occur. \
                Slower speeds lead to more abstract, shifting colors. \
                Faster speeds make the simulation easier to observe. \
                If you turn animations off, the simulation will run as quickly as possible.
            """,
            preferredStyle: .actionSheet
        )

        let defaultAction = UIAlertAction(title: "Normal", style: .default) { _ in
            self.manager?.setAnimationSpeed(.normal)
            self.speedCell.detailTextLabel?.text = "Normal"
        }
        alert.addAction(defaultAction)

        let fastAction = UIAlertAction(title: "Fast", style: .default) { _ in
            self.manager?.setAnimationSpeed(.fast)
            self.speedCell.detailTextLabel?.text = "Fast"
        }
        alert.addAction(fastAction)

        let slowAction = UIAlertAction(title: "Slow", style: .default) { _ in
            self.manager?.setAnimationSpeed(.slow)
            self.speedCell.detailTextLabel?.text = "Slow"
        }
        alert.addAction(slowAction)

        let offAction = UIAlertAction(title: "Off", style: .default) { _ in
            self.manager?.setAnimationSpeed(.off)
            self.speedCell.detailTextLabel?.text = "Off"
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
            self.manager?.setDeathFade(true)
            self.deathFadeCell.detailTextLabel?.text = "On"
        }
        alert.addAction(onAction)

        let offAction = UIAlertAction(title: "Off", style: .default) { _ in
            self.manager?.setDeathFade(false)
            self.deathFadeCell.detailTextLabel?.text = "Off"
        }
        alert.addAction(offAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func showSquareSizePicker() {
        // Square Size Picker
        let alert = UIAlertController(
            title: "Square Size",
            message: """
                This governs the size of the squares on screen. \
                Larger squares are more abstract, while smaller squares allow you to see the simulation easier.
            """,
            preferredStyle: .actionSheet
        )
        let xSmallAction = UIAlertAction(title: "Tiny", style: .default) { _ in
            print("Selected Small")
            self.manager?.setSquareSize(.verySmall)
            self.squareSizeCell.detailTextLabel?.text = "Tiny"
        }
        let smallAction = UIAlertAction(title: "Small", style: .default) { _ in
            print("Selected Small")
            self.manager?.setSquareSize(.small)
            self.squareSizeCell.detailTextLabel?.text = "Small"
        }
        let mediumAction = UIAlertAction(title: "Medium", style: .default) { _ in
            print("Selected Medium")
            self.manager?.setSquareSize(.medium)
            self.squareSizeCell.detailTextLabel?.text = "Medium"
        }
        let largeAction = UIAlertAction(title: "Large", style: .default) { _ in
            print("Selected Large")
            self.manager?.setSquareSize(.large)
            self.squareSizeCell.detailTextLabel?.text = "Large"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alert.addAction(xxSmallAction)
        alert.addAction(xSmallAction)
        alert.addAction(smallAction)
        alert.addAction(mediumAction)
        alert.addAction(largeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
