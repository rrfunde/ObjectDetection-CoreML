//
//  LazyNavitationView.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/25.
//  Copyright © 2023 Ventii. All rights reserved.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
