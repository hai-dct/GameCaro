//
//  MenuViewController.swift
//  GameCaro
//
//  Created by MBA0237P on 11/25/18.
//  Copyright © 2018 Hai Nguyen H.P. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Merry Chirstmas"
    }

    @IBAction func playButtonTouchUpInside(_ sender: UIButton) {
        let vc1 = CaroViewController()
        navigationController?.pushViewController(vc1, animated: true)
    }
}
