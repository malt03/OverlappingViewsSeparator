//
//  CoreGraphics+Operators.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import CoreGraphics

func += (lhs: inout CGPoint, rhs: CGVector) {
    lhs = CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

func -= (lhs: inout CGPoint, rhs: CGVector) {
    lhs = CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
}

func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}
