//
//  MortonOrder.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/08.
//

import UIKit

struct MortonOrder {
    let level: Int
    let number: UInt64
}

extension CGPoint {
    func morton(for window: UIWindow) -> UInt64 {
        let mortonX = CGPoint.morton(x, window.bounds.width)
        let mortonY = CGPoint.morton(x, window.bounds.width)
        return CGPoint.spread(mortonX) | (CGPoint.spread(mortonY) << 1)
    }
    
    private static func spread(_ x: UInt32) -> UInt64 {
        var r = UInt64(x)
        r = (r | (r << 16)) & 0x0000ffff0000ffff
        r = (r | (r << 8)) & 0x00ff00ff00ff00ff
        r = (r | (r << 4)) & 0x0f0f0f0f0f0f0f0f
        r = (r | (r << 2)) & 0x3333333333333333
        r = (r | (r << 1)) & 0x5555555555555555
        return r
    }
    
    private static let exp232: CGFloat = exp2(32)
    private static func morton(_ x: CGFloat, _ r: CGFloat) -> UInt32 {
        let p = (x + r) / (3 * r)
        return UInt32(p * exp232)
    }
}

extension UIView {
    func morton(for window: UIWindow) -> MortonOrder {
        let rect = convert(bounds, to: window)
        let leftTopMorton = rect.origin.morton(for: window)
        let rightBottomMorton = CGPoint(x: rect.maxX, y: rect.maxY).morton(for: window)
        let level = UIView.level(leftTop: leftTopMorton, rightBottom: rightBottomMorton)
        return .init(level: level, number: leftTopMorton)
    }
    
    private static func level(leftTop: UInt64, rightBottom: UInt64) -> Int {
        var mask: UInt64 = 3 << 63
        let xor = leftTop ^ rightBottom
        for level in 0..<32 {
            if mask & xor != 0 { return level }
            mask >>= 2
        }
        return 31
    }
}
