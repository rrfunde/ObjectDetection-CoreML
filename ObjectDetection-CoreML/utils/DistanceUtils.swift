//
//  DistanceUtils.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/21.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation

class DistanceUtils {
    static func getCenterOfGravity(playersXAxis: [Double]) -> Double? {
        if playersXAxis.isEmpty  { return nil }
        let dbClusters = DBScan.dbscan(playersXAxis, epsilon: 0.07, minPts: 1)
                
        let largestGroupOfPlayersPositions = dbClusters.max(by: { $0.count < $1.count })
        
        if largestGroupOfPlayersPositions == nil {
            return nil
        }
        
        let sum = largestGroupOfPlayersPositions!.reduce(0, +)
        let count = Double(largestGroupOfPlayersPositions!.count)
        
        print("yyyyyy \(playersXAxis), \(dbClusters), \(largestGroupOfPlayersPositions!), \(sum/count)")
        return sum / count
        
    }
    
    static func mostFrequentElement<T: Hashable>(in array: [T]) -> T? {
        var frequencyDict: [T: Int] = [:]
        var maxCount = 0
        var mostFrequentElement: T?
        
        for element in array {
            let count = (frequencyDict[element] ?? 0) + 1
            frequencyDict[element] = count
            
            if count > maxCount {
                maxCount = count
                mostFrequentElement = element
            }
        }
        
        return mostFrequentElement
    }

}
