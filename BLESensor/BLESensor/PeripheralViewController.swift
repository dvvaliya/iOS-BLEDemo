//
//  PeripheralViewController.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import UIKit

class PeripheralViewController: UIViewController {
    
    var peripheral: BLEPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()

        peripheral = BLEPeripheral(dataSource: DeviceAccelerometerDataSource())
    }

}
