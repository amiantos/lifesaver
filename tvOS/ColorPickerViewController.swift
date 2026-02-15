//
//  ColorPickerViewController.swift
//  Life Saver tvOS
//
//  Created with Claude Code on 2026-02-15.
//  Copyright © 2026 Brad Root. All rights reserved.
//

import SpriteKit
import UIKit

protocol ColorPickerDelegate: AnyObject {
    func colorPickerDidSave(colors: [(SKColor, Colors)])
}

class ColorPickerViewController: UIViewController {

    weak var delegate: ColorPickerDelegate?
    private let manager: LifeManager

    // MARK: - UI Components

    private lazy var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Custom Colors"
        label.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Colors will be applied when you save"
        label.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        label.textColor = UIColor(white: 0.7, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 40
        return stack
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save & Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 38)
        button.addTarget(self, action: #selector(closeTapped), for: .primaryActionTriggered)
        return button
    }()

    private var colorCards: [ColorCard] = []

    // MARK: - Initialization

    init(manager: LifeManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let firstCard = colorCards.first {
            return [firstCard]
        }
        return [closeButton]
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(contentStackView)
        view.addSubview(closeButton)

        let colors: [(String, SKColor, Colors)] = [
            ("Color 1", manager.color1, .color1),
            ("Color 2", manager.color2, .color2),
            ("Color 3", manager.color3, .color3),
        ]

        for (title, color, slot) in colors {
            let card = ColorCard(title: title, color: color, colorSlot: slot)
            colorCards.append(card)
            contentStackView.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            contentStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 36),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80),
            contentStackView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -30),

            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func closeTapped() {
        let colors = colorCards.map { ($0.currentColor, $0.colorSlot) }
        delegate?.colorPickerDidSave(colors: colors)
        dismiss(animated: true)
    }
}

// MARK: - ColorCard

class ColorCard: UIView {

    let colorSlot: Colors
    private var hue: CGFloat = 0
    private var saturation: CGFloat = 0
    private var brightness: CGFloat = 0

    private let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.2).cgColor
        return view
    }()

    private var hueSlider: TVSlider!
    private var saturationSlider: TVSlider!
    private var brightnessSlider: TVSlider!

    init(title: String, color: SKColor, colorSlot: Colors) {
        self.colorSlot = colorSlot
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        layer.cornerRadius = 20

        // Decompose color to HSB
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

        setupCard(title: title)
        updatePreview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [hueSlider]
    }

    private func setupCard(title: String) {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 38, weight: .semibold)
        titleLabel.textColor = .white

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 1.0, alpha: 0.15)

        addSubview(titleLabel)
        addSubview(divider)
        addSubview(previewView)

        hueSlider = TVSlider(label: "Hue", value: hue)
        hueSlider.onValueChanged = { [weak self] _ in self?.sliderChanged() }

        saturationSlider = TVSlider(label: "Saturation", value: saturation)
        saturationSlider.onValueChanged = { [weak self] _ in self?.sliderChanged() }

        brightnessSlider = TVSlider(label: "Brightness", value: brightness)
        brightnessSlider.onValueChanged = { [weak self] _ in self?.sliderChanged() }

        let sliderStack = UIStackView(arrangedSubviews: [hueSlider, saturationSlider, brightnessSlider])
        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        sliderStack.axis = .vertical
        sliderStack.spacing = 16
        addSubview(sliderStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),

            divider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            divider.heightAnchor.constraint(equalToConstant: 1),

            previewView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            previewView.heightAnchor.constraint(equalToConstant: 240),

            sliderStack.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 20),
            sliderStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            sliderStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            sliderStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -24),
        ])
    }

    var currentColor: SKColor {
        SKColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }

    private func sliderChanged() {
        hue = hueSlider.value
        saturation = saturationSlider.value
        brightness = brightnessSlider.value
        updatePreview()
    }

    private func updatePreview() {
        previewView.backgroundColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

// MARK: - TVSlider (Custom focusable slider for tvOS)

class TVSlider: UIControl {

    var value: CGFloat {
        didSet {
            value = min(max(value, 0), 1)
            updateFillWidth()
            valueLabel.text = "\(Int(value * 100))%"
        }
    }

    var onValueChanged: ((CGFloat) -> Void)?

    private var isActivated: Bool = false {
        didSet { updateAppearance() }
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 26)
        label.textColor = UIColor(white: 0.8, alpha: 1.0)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 26)
        label.textColor = UIColor(white: 0.8, alpha: 1.0)
        label.textAlignment = .right
        return label
    }()

    private let trackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        view.layer.cornerRadius = 5
        return view
    }()

    private let fillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        view.layer.cornerRadius = 5
        view.isUserInteractionEnabled = false
        return view
    }()

    private var fillWidthConstraint: NSLayoutConstraint!
    private let trackHeight: CGFloat = 10
    private var panGesture: UIPanGestureRecognizer!

    override var canBecomeFocused: Bool { true }

    init(label: String, value: CGFloat) {
        self.value = min(max(value, 0), 1)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = label
        valueLabel.text = "\(Int(self.value * 100))%"

        addSubview(nameLabel)
        addSubview(valueLabel)
        addSubview(trackView)
        trackView.addSubview(fillView)

        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: max(self.value, 0.001))

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            valueLabel.topAnchor.constraint(equalTo: topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),

            trackView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.heightAnchor.constraint(equalTo: trackView.heightAnchor),
            fillWidthConstraint,
        ])

        // Pan gesture for adjusting value (only works when activated)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.isEnabled = false
        addGestureRecognizer(panGesture)

        // Tap/click to toggle activation
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        // Deactivate when losing focus
        if !isFocused && isActivated {
            isActivated = false
            panGesture.isEnabled = false
        }
        coordinator.addCoordinatedAnimations({
            self.updateAppearance()
        }, completion: nil)
    }

    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        // When activated, prevent focus from moving away via horizontal swipes
        // so the pan gesture can capture them instead
        if isActivated && context.focusHeading == .left || isActivated && context.focusHeading == .right {
            return false
        }
        return super.shouldUpdateFocus(in: context)
    }

    @objc private func handleTap() {
        isActivated = !isActivated
        panGesture.isEnabled = isActivated
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        // Siri Remote touchpad: scale translation to a reasonable speed
        let delta = translation.x / 800
        value += delta
        gesture.setTranslation(.zero, in: self)
        onValueChanged?(value)
    }

    private func updateAppearance() {
        if isActivated {
            // Activated: bright tint to show editing mode
            trackView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
            fillView.backgroundColor = UIColor.systemBlue
            trackView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
            nameLabel.textColor = UIColor.systemBlue
            valueLabel.textColor = UIColor.systemBlue
        } else if isFocused {
            trackView.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            fillView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            trackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.6)
            nameLabel.textColor = .white
            valueLabel.textColor = .white
        } else {
            trackView.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
            fillView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            trackView.transform = .identity
            nameLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
            valueLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        }
    }

    private func updateFillWidth() {
        fillWidthConstraint.isActive = false
        let multiplier = max(value, 0.001)
        fillWidthConstraint = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: multiplier)
        fillWidthConstraint.isActive = true
    }
}
