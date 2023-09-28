//
//  DeviceUtils.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/25.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation
import AsyncBluetooth
import BoostBLEKit

enum Port: UInt8 {
    case A
    case B
    case C
    case D
}

class DeviceUtils {
    let characteristic: Characteristic?
    let peripheral: Peripheral?
    
    init(characteristic: Characteristic?, peripheral: Peripheral?) {
        self.characteristic = characteristic
        self.peripheral = peripheral
    }
    
    func rotate(direction: NextRotationDirection) {
        setPower(direction == .left ? -20 : 20)
        DispatchQueue.main.asyncAfter(deadline: .now() + DistanceUtils.timeToRotate45) {
            self.stop()
        }
    }
    
     func setPower(_ power: Int) {
        let power = Int8(clamping: power)
        sendCommand(MotorStartPowerCommand(portId: Port.A.rawValue, power: power))
        sendCommand(MotorStartPowerCommand(portId: Port.B.rawValue, power: power))
    }
    
     func sendCommand(_ command: Command) {
        Task {
            do {
                if let characteristic = characteristic {
                    try await peripheral?.writeValue(command.data, for: characteristic, type: .withoutResponse)
                }
            } catch {
                print(error)
            }
        }
    }
    
     func stop() {
        setPower(0)
    }
    
}
