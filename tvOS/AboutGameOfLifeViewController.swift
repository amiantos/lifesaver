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
        label.font = UIFont.systemFont(ofSize: 76, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = 80
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
        view.addSubview(contentStackView)
        view.addSubview(closeButton)

        // Create three columns
        let column1 = createColumn(
            heading: "What Is It?",
            body: """
            The Game of Life is a cellular automaton devised by British mathematician John Horton Conway in 1970.

            Despite its name, it's not a traditional game with players. You create an initial pattern and observe how it evolves according to simple rules on an infinite grid of cells.

            These simple rules create complex patterns: still lifes, oscillators, and "spaceships" that travel across the grid.
            """
        )

        let column2 = createColumn(
            heading: "The Rules",
            body: """
            Every cell interacts with its eight neighbors. At each step:

            Birth: A dead cell with exactly 3 living neighbors becomes alive.

            Survival: A living cell with 2 or 3 neighbors stays alive.

            Death: A living cell with fewer than 2 or more than 3 neighbors dies.
            """
        )

        let column3 = createColumn(
            heading: "About John Conway",
            body: """
            John Horton Conway (1937–2020) was a British mathematician known for contributions to group theory, number theory, and geometry.

            He invented the Game of Life in 1970, popularized by Martin Gardner's Scientific American column.

            Conway also invented surreal numbers and made significant discoveries in knot theory.
            """
        )

        contentStackView.addArrangedSubview(column1)
        contentStackView.addArrangedSubview(column2)
        contentStackView.addArrangedSubview(column3)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            contentStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 90),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -90),

            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createColumn(heading: String, body: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let headingLabel = UILabel()
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.text = heading
        headingLabel.font = UIFont.systemFont(ofSize: 46, weight: .semibold)
        headingLabel.textColor = .white
        headingLabel.numberOfLines = 1

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = body
        bodyLabel.font = UIFont.systemFont(ofSize: 32)
        bodyLabel.textColor = UIColor(white: 0.85, alpha: 1.0)
        bodyLabel.numberOfLines = 0

        container.addSubview(headingLabel)
        container.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: container.topAnchor),
            headingLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            headingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            bodyLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor)
        ])

        return container
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
