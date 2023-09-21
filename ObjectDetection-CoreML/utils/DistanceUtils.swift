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
        if playersXAxis.count  { return nil }
        let kMinCluster = kMeans(points: playersXAxis, k: 5, iterations: 4)
        let mostOccuredNumber = mostFrequentElement(in: kMinCluster)
        
        if mostOccuredNumber == nil { return nil }
        
        var largestGroupOfPlayersPositions = [Double]()
        
        for (index, element) in kMinCluster.enumerated() {
            if element == mostOccuredNumber {
                largestGroupOfPlayersPositions.append(playersXAxis[index])
            }
        }
        
        let sum = largestGroupOfPlayersPositions.reduce(0, +)
        let count = Double(largestGroupOfPlayersPositions.count)
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
