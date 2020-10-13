//
//  ARUtilities.swift
//  ARDemo
//
//  Created by Ilgiz Fazlyev on 13.10.2020.
//

import Foundation
import ARKit

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}

// MARK: - ARSCNView extensions

extension ARSCNView {
    
    func smartHitTest(_ point: CGPoint) -> ARRaycastQuery? {
        // 1. Check for a result on an existing plane using geometry.
        if let existingPlaneUsingGeometryResult = self.raycastQuery(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal) {
            return existingPlaneUsingGeometryResult
        }
        
        // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
        if let infinitePlaneResult = self.raycastQuery(from: point, allowing: .existingPlaneInfinite, alignment: .horizontal) {
            return infinitePlaneResult
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        return self.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .horizontal)
    }
    
}

extension SCNNode {
    var extents: SIMD3<Float> {
        let (min, max) = boundingBox
        return SIMD3<Float>(max) - SIMD3<Float>(min)
    }
}

// MARK: - float4x4 extensions

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(vector.x, vector.y, vector.z, 1))
    }
    
    var translation: SIMD3<Float> {
        let translation = columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
