//
//  CaroViewController.swift
//  GameCaro
//
//  Created by MBA0237P on 11/25/18.
//  Copyright © 2018 Hai Nguyen H.P. All rights reserved.
//

import UIKit
import AVFoundation

final class CaroViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Properties
    private var viewModel = CaroViewModel()
    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Caro IQ100"
        configCollectionView()
        configViewModel()
//        playSound()
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "camnang", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
    }
}

// MARK: - UICollectionViewDataSource
extension CaroViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Config.number * Config.number
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let name = String(describing: CaroCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: name, for: indexPath)
        if let cell = cell as? CaroCell {
            cell.viewModel = viewModel.viewModelForItem(at: indexPath)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CaroViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CaroCell,
            cell.viewModel.option == .none else { return }
        viewModel.updateData(at: indexPath)
        collectionView.reloadData()

        viewModel.machineRunning()
        collectionView.reloadData()
    }
}

// MARK: - CaroViewModelDelegate
extension CaroViewController: CaroViewModelDelegate {

    func viewModel(_ viewModel: CaroViewModel, needperform action: CaroViewModel.Action) {
        switch action {
        case .gameOver(let isWinner):
            let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let this = self else { return }
                this.navigationController?.popViewController(animated: true)
            }
            if isWinner {
                let alert = UIAlertController(title: "You were win", message: nil, preferredStyle: .alert)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "You were lose", message: nil, preferredStyle: .alert)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Config
extension CaroViewController {

    private func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = Config.itemSize
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = Config.contenInset

        let bundle = Bundle.main
        let name = String(describing: CaroCell.self)
        let nib = UINib(nibName: name, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func configViewModel() {
        viewModel.delegate = self
    }

    struct Config {
        static let number = 9
        static let width = (UIScreen.main.bounds.width - contenInset.left * 2) / CGFloat(number)
        static let itemSize = CGSize(width: width, height: width)
        static let contenInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
