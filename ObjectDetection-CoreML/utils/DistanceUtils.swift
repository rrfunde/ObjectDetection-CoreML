//
//  DistanceUtils.swift
//  ObjectDetection-CoreML
//
//  Created by Rohit Funde on 2023/09/21.
//  Copyright © 2023 Ventii. All rights reserved.
//

import Foundation

enum RotationDirection {
    case left
    case right
}

class DistanceUtils {
    static func centerOfGravity(playersXAxis: [Double]) -> Double? {
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
    
    static func rotationInfo(largestGroupMidX: Double) -> RotateInfo? {
        let timeToRotate180 = 2.1
        let angel10DegreeRotationTime = 0.116
        let angel10DegreeXAxisDistance = 0.0555
        let midXAxis = 0.5
        
        let distanceFromTheMiddleX = abs(midXAxis - largestGroupMidX)
        
        let distanceDiffIn10Degree = distanceFromTheMiddleX / angel10DegreeXAxisDistance
        
        let rotationTimeNeeded = distanceDiffIn10Degree * angel10DegreeRotationTime
        
        let rotationDirection = largestGroupMidX < midXAxis ? RotationDirection.left : RotationDirection.right
        
        
        return RotateInfo(direction: rotationDirection, angel: distanceDiffIn10Degree * 10, duration: rotationTimeNeeded > angel10DegreeRotationTime ? rotationTimeNeeded : 0.0)
    }
}
