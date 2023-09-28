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
    case center
    case right
}

enum NextRotationDirection {
    case left
    case right
}

class DistanceUtils {
    static let timeToRotate180 = 2.1
    static let timeToRotate45 = 0.525
    static let angel10DegreeRotationTime = 0.116
    static let angel10DegreeXAxisDistance = 0.0555
    static let midXAxis = 0.5
    
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
    
    static func rotationAllAngelInfo(largestGroupMidX: Double) -> RotateInfo? {
        
        let distanceFromTheMiddleX = abs(midXAxis - largestGroupMidX)
        
        let distanceDiffIn10Degree = distanceFromTheMiddleX / angel10DegreeXAxisDistance
        
        let rotationTimeNeeded = distanceDiffIn10Degree * angel10DegreeRotationTime
        
        let rotationDirection = largestGroupMidX < midXAxis ? RotationDirection.left : RotationDirection.right
        
        
        return RotateInfo(direction: rotationDirection, angel: distanceDiffIn10Degree * 10, duration: rotationTimeNeeded > angel10DegreeRotationTime ? rotationTimeNeeded : 0.0)
    }
    
    static func rotationThreeAngelInfo(largestGroupMidX: Double, currentRotation: RotationDirection) -> RotationDirection? {
        
        switch currentRotation {
        case .left:
            if largestGroupMidX >= 0.8 {
                return .center
            }
        case .center:
            if largestGroupMidX >= 0.7 {
                return .right
            } else if largestGroupMidX <= 0.3 {
                return .left
            }
        case .right:
            if largestGroupMidX <= 0.2 {
                return .center
            }
        }
        
        return nil
    }
    
    static func rotationInfo(direction: RotationDirection) -> RotateInfo {
        switch direction {
        case .left:
            return RotateInfo(direction: .left, angel: 45, duration: 0.25)
        case .center:
            return RotateInfo(direction: .center, angel: 90, duration: 0.5)
        case .right:
            return RotateInfo(direction: .right, angel: 135, duration: 0.75)
        }
    }
    
    static func nextRotationInfo(currentRotation: RotationDirection, expectedRotation: RotationDirection) -> NextRotationDirection? {
        switch currentRotation {
        case .left:
            if expectedRotation == .center {
                return .right
            }
        case .center:
            if expectedRotation == .left {
                return .left
            } else if expectedRotation == .right {
                return .right
            }
        case .right:
            if expectedRotation == .center {
                return .left
            }
        }
        return nil
    }
}
