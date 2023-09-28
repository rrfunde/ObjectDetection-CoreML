//
//  MainViewControllerView.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/22.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation

import SwiftUI
import UIKit
import AsyncBluetooth

struct MainViewControllerView: UIViewControllerRepresentable {
    var characteristic: Characteristic
    var peripheral: Peripheral
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let viewController = storyboard.instantiateViewController(withIdentifier: "RecordingViewController") as? ViewController {
            viewController.peripheral = peripheral
            viewController.characteristic = characteristic
            return viewController
        }
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the UI
    }
}
