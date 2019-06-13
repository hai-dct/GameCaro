//
//  CaroCell.swift
//  GameCaro
//
//  Created by MBA0237P on 11/25/18.
//  Copyright © 2018 Hai Nguyen H.P. All rights reserved.
//

import UIKit

final class CaroCell: UICollectionViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var tagLabel: UILabel!

    // MARK: - IBOutlet
    var viewModel = CaroCellViewModel() {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }

}

// MARK: - Config
extension CaroCell {

    private func configView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
    }

    private func updateView() {
        switch viewModel.option {
        case .none:
            tagLabel.text = ""
        case .zero:
            tagLabel.text = "O"
            tagLabel.textColor = .blue
        case .xman:
            tagLabel.text = "X"
            tagLabel.textColor = .red
        }
    }
}
