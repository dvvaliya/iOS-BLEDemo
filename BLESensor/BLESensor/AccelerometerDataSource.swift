//
//  AccelerometerDataSource.swift
//  BLESensor
//
//  Created by Dharmendra Valiya on 05/18/20.
//  Copyright © 2020 Dharmendra Valiya. All rights reserved.
//

import Foundation

struct AccelerometerData: Codable {
    let timestamp: TimeInterval
    let x: Double
    let y: Double
    let z: Double
}

protocol AccelerometerDataSource {
    var onUpdate: ((AccelerometerData) -> Void)? { get set }
    
    func start()
    func stop()
}
