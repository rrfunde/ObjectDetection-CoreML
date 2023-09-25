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
    static func setPower(_ power: Int, peripheral: Peripheral?, characteristic: Characteristic?) {
        let power = Int8(clamping: power)
        sendCommand(MotorStartPowerCommand(portId: Port.A.rawValue, power: power), peripheral: peripheral, characteristic: characteristic)
        sendCommand(MotorStartPowerCommand(portId: Port.B.rawValue, power: power), peripheral: peripheral, characteristic: characteristic)
    }
    
    static func sendCommand(_ command: Command, peripheral: Peripheral?, characteristic: Characteristic?) {
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
}
