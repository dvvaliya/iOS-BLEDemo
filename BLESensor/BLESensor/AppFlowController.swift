//
//  AppFlowController.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import UIKit

class AppFlowController {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BLERoleSelectViewController") as! BLERoleSelectViewController
        viewController.onChoice = { [weak self] choice in
            let nextViewController: UIViewController
            switch choice {
            case .central:
                let viewController = DiscoveryViewController()
                viewController.onConnected = {
                    let accelerometerViewController = AccelerometerViewController()
                    accelerometerViewController.central = viewController.central
                    self?.window.rootViewController = accelerometerViewController
                }
                nextViewController = viewController
            case .peripheral:
                nextViewController = PeripheralViewController()
            }
            self?.window.rootViewController = nextViewController
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
