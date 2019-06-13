//
//  CaroCellViewModel.swift
//  GameCaro
//
//  Created by MBA0237P on 11/25/18.
//  Copyright © 2018 Hai Nguyen H.P. All rights reserved.
//

import Foundation

final class CaroCellViewModel {

    let option: Option

    init(option: Option = .none) {
        self.option = option
    }
}

extension CaroCellViewModel {

    enum Option: Int {
        case none
        case xman
        case zero

        var opsite: Option {
            switch self {
            case .xman:
                return .zero
            case .zero:
                return .xman
            default:
                return .none
            }
        }
    }
}
