//
//  OverlappingViewsSeparator.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/08.
//

import UIKit

public final class OverlappingViewsSeparator {
    private let minSpacing: CGFloat
    
    public init(minSpacing: CGFloat = 0) {
        self.minSpacing = minSpacing
    }
    
    private var allViews = Set<WeakHolder<UIView>>()
    private var allStuckViews = Set<WeakHolder<UIView>>()
    
    public func register(view: UIView) {
        allViews.insert(.init(view))
    }
    
    public func register<S: Sequence>(views: S) where S.Element: UIView {
        for view in views { register(view: view) }
    }
    
    public func register(stuckView: UIView) {
        allStuckViews.insert(.init(stuckView))
    }
    
    public func register<S: Sequence>(stuckViews: S) where S.Element: UIView {
        for view in stuckViews { register(stuckView: view) }
    }
    
    public func unregister(view: UIView) {
        allViews.remove(.init(view))
    }
    
    public func reset() {
        for view in allViews {
            view.value?.transform = .identity
        }
    }
    
    public func apply() {
        allViews = .init(AnySequence(allViews)) // remove nil elements

        let tree = Tree(
            views: allViews.lazy.compactMap { $0.value },
            stuckViews: allStuckViews.lazy.compactMap { $0.value }
        )

        var hasCollision = false
        repeat {
            hasCollision = false
            var result = [UIView: CGPoint]()
            tree.processCollisionCombination(spacing: minSpacing) { (a, b) in
                let unit = unitVector(from: a.rect.center, to: b.rect.center)
                if case .flexible(let view) = a.element {
                    result[view, default: .zero] -= unit * 5
                }
                if case .flexible(let view) = b.element {
                    result[view, default: .zero] += unit * 5
                }
                hasCollision = true
            }
            for (view, point) in result {
                view.transform = view.transform.translatedBy(x: point.x, y: point.y)
            }
            tree.update(views: result.keys)
        } while hasCollision
    }
}

func unitVector(from a: CGPoint, to b: CGPoint) -> CGVector {
    let distance = sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2))
    if distance == 0 {
        return CGVector(dx: 0, dy: 1)
    }
    return CGVector(dx: (b.x - a.x) / distance, dy: (b.y - a.y) / distance)
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }
}
