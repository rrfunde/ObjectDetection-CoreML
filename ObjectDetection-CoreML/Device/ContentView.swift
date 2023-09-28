//
//  ContentView.swift
//  Spike Essential Connector
//
//  Created by Rohit Funde on 2023/09/08.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                HStack() {
                    if viewModel.isScanning {
                        Button("Scanning...") {
                            viewModel.cancel()
                        }
                    } else {
                        if let name = viewModel.peripheral?.name {
                            Button(action: { viewModel.disconnect() }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                            Text(name)
                        } else {
                            Button("Connect") {
                                viewModel.connect()
                            }
                        }
                    }
                }
                
    
                NavigationLink(destination: NavigationLazyView(MainViewControllerView(characteristic: viewModel.characteristic!, peripheral: viewModel.peripheral!)), isActive: .constant(viewModel.peripheral != nil && viewModel.characteristic != nil)) {
                              Text("Go to Recording Screen")
                                  .padding()
                                  .foregroundColor(.white)
                                  .background(Color.blue)
                                  .cornerRadius(8)
                          }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
