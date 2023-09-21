//
//  DBScan.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/21.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation

class DBScan {
    static func dbscan(_ array: [Double], epsilon: Double, minPts: Int) -> [[Double]] {
        var visited = Set<Double>()
        var clusters: [[Double]] = []
        
        for point in array {
            if visited.contains(point) {
                continue
            }
            visited.insert(point)
            
            let neighbors = regionQuery(array, point: point, epsilon: epsilon)
            
            if neighbors.count < minPts {
                continue
            }
            
            var cluster: [Double] = []
            var queue = neighbors
            
            while !queue.isEmpty {
                let nextPoint = queue.removeFirst()
                if !visited.contains(nextPoint) {
                    visited.insert(nextPoint)
                    let nextNeighbors = regionQuery(array, point: nextPoint, epsilon: epsilon)
                    if nextNeighbors.count >= minPts {
                        queue.append(contentsOf: nextNeighbors)
                    }
                }
                if !cluster.contains(nextPoint) {
                    cluster.append(nextPoint)
                }
            }
            
            clusters.append(cluster)
        }
        
        return clusters
    }

    func regionQuery(_ array: [Double], point: Double, epsilon: Double) -> [Double] {
        return array.filter { abs($0 - point) <= epsilon }
    }

    let array = [2.1, 2.2, 2.4, 4.1, 4.3, 10.0, 10.2]
    let epsilon = 0.3
    let minPts = 2
    let clusters = dbscan(array, epsilon: epsilon, minPts: minPts)
    print(clusters) // Output: [[2.1, 2.2], [4.1, 4.3], [10.0, 10.2]]

}
