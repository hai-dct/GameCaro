//
//  CaroViewModel.swift
//  GameCaro
//
//  Created by MBA0237P on 11/25/18.
//  Copyright © 2018 Hai Nguyen H.P. All rights reserved.
//

import Foundation

protocol CaroViewModelDelegate: class {
    func viewModel(_ viewModel: CaroViewModel, needperform action: CaroViewModel.Action)
}
final class CaroViewModel {

    private var data = [[Int]]()
    private var evalData = [[Int]]()  // Điểm đánh giá từ 0 -> n * n
    private var isMyTurn: Bool = true
    private var playerOption: Option = .xman
    private var isGameOver: Bool = false {
        didSet {
            delegate?.viewModel(self, needperform: .gameOver(isMyTurn))
        }
    }
    weak var delegate: CaroViewModelDelegate?

    init() {
        data = newData
    }

    private func getColumAndRow(from indexPath: IndexPath) -> Location {
        let row = indexPath.row / numberColumn
        let column = indexPath.row - numberColumn * row
        return (row, column)
    }

    private func getLocationForCheck() -> Location {
        var mI = 0
        var mJ = 0
        repeat {
            mI = Int.random(in: 0..<numberColumn)
            mJ = Int.random(in: 0..<numberColumn)
        } while evalData[mI][mJ] != getMaxPoint()
        return (mI, mJ)
    }

    func getMaxPoint() -> Int {
        var max = 0
        for row in 0..<numberColumn {
            for col in 0..<numberColumn where max < evalData[row][col] {
                max = evalData[row][col]
            }
        }
        return max
    }
}

extension CaroViewModel {

    func viewModelForItem(at indexPath: IndexPath) -> CaroCellViewModel {
        var i = 0
        let result = getColumAndRow(from: indexPath)
        let rawValue = data[result.row][result.column]
        guard let option = Option(rawValue: rawValue) else {
            return CaroCellViewModel(option: .none)
        }
        let vm = CaroCellViewModel(option: option)
        return vm
    }

    func updateData(at indexPath: IndexPath) {
        guard !isGameOver else { return }
        let location = getColumAndRow(from: indexPath)
        data[location.row][location.column] = playerOption.rawValue
        checkWin()
    }

    func machineRunning() {
        guard !isGameOver else { return }
        eval()
        let location = getLocationForCheck()
        data[location.row][location.column] = playerOption.opsite.rawValue
        checkWin()
    }
}

// MARK: - Eval func
extension CaroViewModel {

    private func evalRow(option: Option) {
        var dT = 0, dP = 0 // Đếm bên trái ô (i,j) trống, đếm bên phải ô (i,j) trống
        var jT: Int, jP: Int
        for row in 0..<numberColumn {
            for col in 0..<numberColumn where data[row][col] == Option.none.rawValue {
                jT = col - 1 // Ô bên trái ij
                dT = 0 // Đếm bên trái các <Option> liên tục
                while jT >= 0 && data[row][jT] == option.rawValue {
                    dT += 1
                    jT -= 1
                }
                dP = 0
                jP = col + 1
                while jP < numberColumn && data[row][jP] == option.rawValue { // Đếm bên phải các <Option> liên tục
                    dP += 1
                    jP += 1
                }
                // Đếm xong cho điểm
                if dT + dP >= 4 {
                    evalData[row][col] = option == playerOption ? 90 : 95
                } else if dT + dP == 3 { // Đủ 3
                    // Trống 2 đầu
                    if data[row][jT] == Option.none.rawValue && data[row][jP] == Option.none.rawValue {
                        evalData[row][col] += option == playerOption ? 50 : 55
                    } else if jT <= 0 || data[row][jT] == option.opsite.rawValue {
                        // Đụng biên trái hay bên trái bị chặn
                        evalData[row][col] += option == playerOption ? 10 : 15
                    } else if jP >= numberColumn || data[row][jP] == option.opsite.rawValue {
                        // Đụng biên phải hay bên phải bị chặn
                        evalData[row][col] += option == .xman ? 10 : 15
                    }
                } else if option != playerOption {
                    if dT + dP == 2 {
                        evalData[row][col] += 5
                    } else if dT + dP == 1 {
                        evalData[row][col] += 1
                    }
                }
            }
        }
    }

    private func evalCol(option: Option) {
        var demT: Int, demD: Int, iT: Int, iD: Int // Trên và dưới
        for row in 0..<numberColumn {
            for col in 0..<numberColumn where data[row][col] == Option.none.rawValue { // Đánh gia ô trống
                demT = 0
                iT = row - 1
                while iT >= 0 && data[iT][col] == option.rawValue {
                    demT += 1
                    iT -= 1 // Đi lên
                }
                demD = 0
                iD = row + 1
                while iD < numberColumn && data[iD][col] == option.rawValue {
                    demD += 1
                    iD += 1 // Đi lên
                }
                // Đếm xong cho điểm
                if demD + demT >= 4 {
                    evalData[row][col] = option == playerOption ? 90 : 95
                } else if demD + demT >= 3 { // Đủ 3
                    if iT < 0 || data[iT][col] == option.opsite.rawValue {
                        // Đụng biên trên hay bị chặn trên
                        evalData[row][col] += option == playerOption ? 10 : 15
                    } else if iD >= numberColumn || data[iD][col] == option.opsite.rawValue {
                        // Đụng biên dưới hay bị chặn dưới
                        evalData[row][col] += option == playerOption ? 10 : 15
                    } else if data[iD][col] == Option.none.rawValue && data[iT][col] == Option.none.rawValue {
                        // Trống 2 đầu
                        evalData[row][col] += option == playerOption ? 50 : 55
                    }
                } else if option != playerOption {
                    if demT + demD == 2 {
                        evalData[row][col] += 5
                    } else if demT + demD == 1 {
                        evalData[row][col] += 1
                    }
                }
            }
        }
    }

    private func evalDiagonalUp(option: Option) {
        var demL: Int, demX: Int, iL: Int, iX: Int, jL: Int, jX: Int
        for row in 0..<numberColumn {
            for col in 0..<numberColumn where data[row][col] == Option.none.rawValue {
                // Đếm lên
                demL = 0
                iL = row - 1
                jL = col + 1
                while iL >= 0 && jL < numberColumn && data[iL][jL] == option.rawValue {
                    demL += 1
                    iL -= 1
                    jL += 1
                }
                demX = 0
                iX = row + 1
                jX = col - 1

                while iX < numberColumn && jX >= 0 && data[iX][jX] == option.rawValue {
                    demX += 1
                    iX += 1
                    jX -= 1
                }

                // Đếm xong cho điểm
                if demX + demL >= 4 {
                    evalData[row][col] = option == playerOption ? 90 : 95
                } else if demX + demL == 3 { // Đủ 3
                    if iL < 0 || jL >= numberColumn || data[iL][jL] == option.opsite.rawValue {
                        // Đụng biên trên hoặc chăn trên
                        evalData[row][col] = option == playerOption ? 10 : 15
                    } else if iX >= numberColumn || jX < 0 || data[iX][jX] == option.opsite.rawValue {
                        // Đụng biên dưới hoặc chặn dưới
                        evalData[row][col] = option == playerOption ? 10 : 15
                    } else if data[iL][jL] == Option.none.rawValue && data[iX][jX] == Option.none.rawValue {
                        // Hai đầu trống
                        evalData[row][col] = option == playerOption ? 50 : 55
                    }
                } else if option != playerOption {
                    if demX + demL == 2 {
                        evalData[row][col] += 5
                    } else if demX + demL == 1 {
                        evalData[row][col] += 1
                    }
                }
            }
        }
    }

    private func evalDiagonalDown(option: Option) {
        var demL: Int, demX: Int, iL: Int, iX: Int, jL: Int, jX: Int
        for row in 0..<numberColumn {
            for col in 0..<numberColumn where data[row][col] == Option.none.rawValue {
                // Đếm lên
                demL = 0
                iL = row - 1
                jL = col - 1
                while iL >= 0 && jL >= 0 && data[iL][jL] == option.rawValue {
                    demL += 1
                    iL -= 1
                    jL -= 1
                }
                // Đếm xuống
                demX = 0
                iX = row + 1
                jX = col + 1

                while iX < numberColumn && jX < numberColumn && data[iX][jX] == option.rawValue {
                    demX += 1
                    iX += 1
                    jX += 1
                }

                // Đếm xong cho điểm
                if demX + demL >= 4 {
                    evalData[row][col] = option == playerOption ? 90 : 95
                } else if demX + demL == 3 { // Đủ 3
                    if iL < 0 || jL < 0 || data[iL][jL] == option.opsite.rawValue {
                        // Đụng biên trên hoặc chăn trên
                        evalData[row][col] = option == playerOption ? 10 : 15
                    } else if iX >= numberColumn || jX >= numberColumn || data[iX][jX] == option.opsite.rawValue {
                        // Đụng biên dưới hoặc chặn dưới
                        evalData[row][col] = option == playerOption ? 10 : 15
                    } else if data[iL][jL] == Option.none.rawValue && data[iX][jX] == Option.none.rawValue {
                        // Hai đầu trống
                        evalData[row][col] = option == playerOption ? 50 : 55
                    }
                } else if option != playerOption {
                    if demX + demL == 2 {
                        evalData[row][col] += 5
                    } else if demX + demL == 1 {
                        evalData[row][col] += 1
                    }
                }
            }
        }
    }

    // Đánh giá nước đi cho máy
    private func eval() {
        evalData = newData
        // 1. 0 điểm cho ô đã có và 1 điểm cho ô trống
        for row in 0..<numberColumn {
            for col in 0..<numberColumn {
                if data[row][col] != Option.none.rawValue {
                    evalData[row][col] = 0
                } else {
                    evalData[row][col] = 1
                }
            }
        }

        // 2. Đánh giá theo hàng
        do {
            evalRow(option: .xman)
            evalRow(option: .zero)
        }

        // 3. Đánh giá theo cột
        do {
            evalCol(option: .xman)
            evalCol(option: .zero)
        }

        // 4. Đánh giá theo đường chéo lên
        do {
            evalDiagonalUp(option: .xman)
            evalDiagonalUp(option: .zero)
        }

        // 5. Đánh giá theo đường chéo xuống
        do {
            evalDiagonalDown(option: .xman)
            evalDiagonalDown(option: .zero)
        }
    }
}

// MAKR: - Find winner
extension CaroViewModel {

    private func checkRow(option: Option) {
        guard !isGameOver, option != .none else { return }
        var dem = 0
        for row in 0..<numberColumn {
            for col in 0..<numberColumn {
                if data[row][col] == option.rawValue {
                    dem += 1
                    if dem == 5 {
                        isGameOver = true
                        break
                    }
                } else {
                    dem = 0
                }
            }
        }
    }

    private func checkColumn(option: Option) {
        guard !isGameOver, option != .none else { return }
        var dem = 0
        for row in 0..<numberColumn {
            for col in 0..<numberColumn {
                if data[col][row] == option.rawValue {
                    dem += 1
                    if dem == 5 {
                        isGameOver = true
                        break
                    }
                } else {
                    dem = 0
                }
            }
        }
    }

    private func checkUp(option: Option) {
        guard !isGameOver, option != .none else { return }
        var dem = 0
        for temp in 4..<(2 * numberColumn - 1) {
            for row in 0..<numberColumn {
                for col in 0..<numberColumn where row + col == temp {
                    if data[row][col] == option.rawValue {
                        dem += 1
                        if dem == 5 {
                            isGameOver = true
                            break
                        }
                    } else {
                        dem = 0
                    }
                }
            }
        }
    }

    private func checkDown(option: Option) {
        guard !isGameOver, option != .none else { return }
        var dem = 0
        for temp in (1 - numberColumn)..<(numberColumn - 1) {
            for row in 0..<numberColumn {
                for col in 0..<numberColumn where row - col == temp {
                    if data[row][col] == option.rawValue {
                        dem += 1
                        if dem == 5 {
                            isGameOver = true
                            break
                        }
                    } else {
                        dem = 0
                    }
                }
            }
        }
    }

    private func checkWin() {
        checkRow(option: .xman)
        checkRow(option: .zero)
        checkColumn(option: .xman)
        checkColumn(option: .zero)
        checkUp(option: .xman)
        checkUp(option: .zero)
        checkDown(option: .xman)
        checkDown(option: .zero)
    }
}

extension CaroViewModel {
    typealias Option = CaroCellViewModel.Option
    typealias Location = (row: Int, column: Int)

    enum Action {
        case gameOver(Bool)
    }

    var newData: [[Int]] {
        let array = [Int](repeating: 0, count: numberColumn)
        return [[Int]](repeating: array, count: numberColumn)
    }

    var numberColumn: Int {
        return CaroViewController.Config.number
    }
}
