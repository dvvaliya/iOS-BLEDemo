//
//  DeviceAccelerometerDataSource.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import Foundation
import CoreMotion

class DeviceAccelerometerDataSource: AccelerometerDataSource {
    
    var onUpdate: ((AccelerometerData) -> Void)?
    
    private let manager = CMMotionManager()
    
    func start() {
        guard manager.isAccelerometerAvailable else {
            print("accelerometer is not available")
            return
        }
        
        if manager.isAccelerometerActive { return }
        
        manager.accelerometerUpdateInterval = 1.0
        manager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
            if let error = error {
                print("error accelerometer updates: \(error.localizedDescription)")
            } else if let data = data {
                print("accelerometer data: \(data)")
                let accelerometerData = AccelerometerData(timestamp: data.timestamp, x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                self?.onUpdate?(accelerometerData)
            }
        }
    }
    
    func stop() {
        manager.stopAccelerometerUpdates()
    }
    
    
}
