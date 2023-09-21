//
//  KMeanCluster.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/21.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation

func kMeans(points: [Double], k: Int, iterations: Int) -> [Int] {
    // Initialize the centroids randomly from the data points
    var centroids: [Double] = Array(points.prefix(k))
    
    // Assign each point to a cluster
    var clusterAssignments: [Int] = Array(repeating: 0, count: points.count)
    
    for _ in 0..<iterations {
        // 1. Assign each point to the closest centroid
        for i in 0..<points.count {
            let point = points[i]
            var minDistance = Double.infinity
            for j in 0..<k {
                let centroid = centroids[j]
                let distance = abs(point - centroid)
                if distance < minDistance {
                    minDistance = distance
                    clusterAssignments[i] = j
                }
            }
        }
        
        // 2. Update the centroids
        for j in 0..<k {
            var clusterPoints: [Double] = []
            for i in 0..<points.count {
                if clusterAssignments[i] == j {
                    clusterPoints.append(points[i])
                }
            }
            let newCentroid = clusterPoints.reduce(0, +) / Double(clusterPoints.count)
            centroids[j] = newCentroid
        }
    }
    
    return clusterAssignments
}
