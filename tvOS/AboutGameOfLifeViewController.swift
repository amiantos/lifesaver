//
//  AboutGameOfLifeViewController.swift
//  Life Saver tvOS
//
//  Created by Brad Root on 2026-02-01.
//  Copyright © 2026 Brad Root. All rights reserved.
//

import UIKit

class AboutGameOfLifeViewController: UIViewController {

    private lazy var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Conway's Game of Life"
        label.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "A cellular automaton created in 1970"
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
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 38)
        button.addTarget(self, action: #selector(closeTapped), for: .primaryActionTriggered)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [closeButton]
    }

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(contentStackView)
        view.addSubview(closeButton)

        // Create three columns
        let column1 = createCard(
            heading: "What Is It?",
            body: "A cellular automaton devised by British mathematician John Horton Conway.\n\nDespite its name, it's not a traditional game—there are no players. You set an initial pattern and watch it evolve according to simple rules.\n\nThese rules create complex patterns: still lifes, oscillators, and \"spaceships\" that glide across the grid."
        )

        let column2 = createCard(
            heading: "The Rules",
            body: "Every cell interacts with its eight neighbors. At each step:\n\n• Birth — A dead cell with exactly 3 neighbors becomes alive.\n\n• Survival — A living cell with 2 or 3 neighbors stays alive.\n\n• Death — A living cell with < 2 or > 3 neighbors dies."
        )

        let column3 = createCard(
            heading: "John Conway",
            body: "John Horton Conway (1937–2020) was a British mathematician known for group theory, number theory, and geometry.\n\nThe Game of Life was popularized by Martin Gardner's Scientific American column.\n\nHe also invented surreal numbers and made discoveries in knot theory."
        )

        contentStackView.addArrangedSubview(column1)
        contentStackView.addArrangedSubview(column2)
        contentStackView.addArrangedSubview(column3)

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
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createCard(heading: String, body: String) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        card.layer.cornerRadius = 20

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.text = heading
        headingLabel.font = UIFont.systemFont(ofSize: 38, weight: .semibold)
        headingLabel.textColor = .white
        headingLabel.numberOfLines = 1

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 1.0, alpha: 0.15)

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = body
        bodyLabel.font = UIFont.systemFont(ofSize: 26)
        bodyLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        bodyLabel.numberOfLines = 0

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedBody = NSAttributedString(
            string: body,
            attributes: [
                .font: UIFont.systemFont(ofSize: 28),
                .foregroundColor: UIColor(white: 0.9, alpha: 1.0),
                .paragraphStyle: paragraphStyle
            ]
        )
        bodyLabel.attributedText = attributedBody

        card.addSubview(headingLabel)
        card.addSubview(divider)
        card.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            headingLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            headingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),

            divider.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            divider.heightAnchor.constraint(equalToConstant: 1),

            bodyLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 28),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -28),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -24)
        ])

        return card
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
