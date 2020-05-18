//
//  DiscoveredPeripheral.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import Foundation
import CoreBluetooth

class DiscoveredPeripheral {
    var peripheral: CBPeripheral
    var rssi: NSNumber
    var advertisementData: [String: Any]
    
    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: [String: Any]) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
}
