//
//  BLECentral.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var manager: CBCentralManager!
    private(set) var discoveredPeripherals = [DiscoveredPeripheral]()
    private var connectedPeripheral: CBPeripheral?
    private let decoder = JSONDecoder()
    
    var onDiscovered: (() -> Void)?
    var onDataUpdated: ((AccelerometerData) -> Void)?
    var onConnected: (() -> Void)?
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        manager.scanForPeripherals(withServices: [CBUUID(string: BLEIdentifiers.serviceIdentifier)], options: options)
    }
    
    func connect(at index: Int) {
        guard index >= 0, index < discoveredPeripherals.count else { return }
        
        manager.stopScan()
        manager.connect(discoveredPeripherals[index].peripheral, options: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scanForPeripherals()
        } else {
            print("central is unavailable: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let existingPeripheral = discoveredPeripherals.first(where: {$0.peripheral == peripheral}) {
            existingPeripheral.advertisementData = advertisementData
            existingPeripheral.rssi = RSSI
        } else {
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData))
        }
        onDiscovered?()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("central did connect")
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices([CBUUID(string: BLEIdentifiers.serviceIdentifier)])
        onConnected?()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("central did fail to connect")
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("peripheral failed to discover services: \(error.localizedDescription)")
        } else {
            peripheral.services?.forEach({ (service) in
                print("service discovered: \(service)")
                peripheral.discoverCharacteristics([CBUUID(string: BLEIdentifiers.characteristicIdentifier)], for: service)
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("peripheral failed to discover characteristics: \(error.localizedDescription)")
        } else {
            service.characteristics?.forEach({ (characteristic) in
                print("characteristic discovered: \(characteristic)")
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                } else if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                peripheral.discoverDescriptors(for: characteristic)
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("peripheral failed to discover descriptor: \(error.localizedDescription)")
        } else {
            characteristic.descriptors?.forEach({ (descriptor) in
                print("descriptor discovered: \(descriptor)")
                peripheral.readValue(for: descriptor)
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("peripheral error updating value for characteristic: \(error.localizedDescription)")
        } else {
            print("descriptor value updated: \(characteristic)")
            if let value = characteristic.value {
                if let accelerometerData = try? decoder.decode(AccelerometerData.self, from: value) {
                    print(accelerometerData)
                    onDataUpdated?(accelerometerData)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("peripheral error updating value for descriptor: \(error.localizedDescription)")
        } else {
            print("descriptor value updated: \(descriptor)")
        }
    }
}
