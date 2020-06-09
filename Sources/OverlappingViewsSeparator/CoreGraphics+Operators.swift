//
//  CoreGraphics+Operators.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import CoreGraphics

func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

func + (lhs: CGVector, rhs: CGVector) -> CGVector {
    CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

func += (lhs: inout CGVector, rhs: CGVector) {
    lhs = lhs + rhs
}

func - (lhs: CGVector, rhs: CGVector) -> CGVector {
    CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
}

func -= (lhs: inout CGVector, rhs: CGVector) {
    lhs = lhs - rhs
}

func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}
