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

struct MainViewControllerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let viewController = storyboard.instantiateViewController(withIdentifier: "RecordingViewController") as? ViewController {
            return viewController
        }
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the UI
    }
}
