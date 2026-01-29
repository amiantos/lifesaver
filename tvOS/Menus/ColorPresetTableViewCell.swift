//
//  ColorPresetTableViewCell.swift
//  Life Saver tvOS
//
//  Created by Bradley Root on 6/25/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//

import UIKit

class ColorPresetTableViewCell: UITableViewCell {
    static let reuseIdentifier = "presetCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 38)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)

        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.titleLabel.textColor = .black
            } else {
                self.titleLabel.textColor = .white
            }
        }, completion: nil)
    }
}
