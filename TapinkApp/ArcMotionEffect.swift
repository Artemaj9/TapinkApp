//
//  ArcMotionEffect.swift
//  TapinkApp
//
//  Created by Artem on 17.09.2025.
//


import SwiftUI

struct ArcMotionEffect: GeometryEffect {
    var progress: CGFloat // 0 -> 1
    var start: CGPoint
    var end: CGPoint
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        // Midpoint for the arc
        let midX = (start.x + end.x) / 2
        let midY = min(start.y, end.y) - 100 // lift the arc by 100 points
        
        // Quadratic Bezier formula
        let x = pow(1 - progress, 2) * start.x + 2 * (1 - progress) * progress * midX + pow(progress, 2) * end.x
        let y = pow(1 - progress, 2) * start.y + 2 * (1 - progress) * progress * midY + pow(progress, 2) * end.y
        
        return ProjectionTransform(CGAffineTransform(translationX: x - start.x, y: y - start.y))
    }
}

import SwiftUI

struct ArcAroundSmallEffect: GeometryEffect {
    var progress: CGFloat
    var start: CGPoint
    var small: CGPoint
    var radius: CGFloat
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        // Target point: symmetrical position relative to small
        let end = CGPoint(x: small.x + (small.x - start.x),
                          y: small.y + (small.y - start.y))
        
        // Control point for slight arc: midpoint + vertical offset
        let mid = CGPoint(x: (start.x + end.x) / 2,
                          y: (start.y + end.y) / 2 - radius / 2) // lift for arc
        
        // Quadratic Bézier
        let x = pow(1 - progress, 2) * start.x + 2 * (1 - progress) * progress * mid.x + pow(progress, 2) * end.x
        let y = pow(1 - progress, 2) * start.y + 2 * (1 - progress) * progress * mid.y + pow(progress, 2) * end.y
        
        return ProjectionTransform(CGAffineTransform(translationX: x - start.x, y: y - start.y))
    }
}
