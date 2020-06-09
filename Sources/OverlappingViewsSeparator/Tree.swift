//
//  Tree.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import UIKit

typealias UIViewWithRect = (view: UIView, rect: CGRect)

final class Tree {
    private var trees = [UIWindow: Node]()
    private var nodes = [UIView: Node]()
    
    func processCollisionCombination(spacing: CGFloat, handler: (UIViewWithRect, UIViewWithRect) -> Void) {
        for tree in trees.values {
            tree.processCollisionCombination(spacing: spacing, handler: handler)
        }
    }
    
    init<S: Sequence>(views: S) where S.Element == UIView {
        for view in views {
            guard let window = view.window else { continue }
            let morton = view.morton(for: window)
            let root = trees.getOrInit(for: window)
            nodes[view] = root.add(view: view, morton: morton, currentLevel: 0)
        }
    }
    
    func update<S: Sequence>(views: S) where S.Element == UIView {
        for view in views {
            guard let window = view.window else { continue }
            let morton = view.morton(for: window)
            let node = trees.getOrInit(for: window).add(view: view, morton: morton, currentLevel: 0)
            if nodes[view] !== node {
                nodes[view]?.remove(view: view)
                nodes[view] = node
            }
        }
    }
    
    final class Node {
        func processCollisionCombination(spacing: CGFloat, handler: (UIViewWithRect, UIViewWithRect) -> Void) {
            for childNode in children.values {
                childNode.processCollisionCombination(spacing: spacing, handler: handler)
            }

            if views.isEmpty { return }
            
            func handlerWithCollisionCheck(_ a: UIView, _ b: UIView) {
                guard let aRect = a.rectInWindow, let bRect = b.rectInWindow else { return }
                if !aRect.isCollision(to: bRect, spacing: spacing) { return }
                handler((a, aRect), (b, bRect))
            }

            var nilIndexes = [Int]()
            for i in 0..<views.count {
                guard let a = views[i].value else {
                    nilIndexes.append(i)
                    continue
                }
                for j in (i + 1)..<views.count {
                    guard let b = views[j].value else { continue }
                    handlerWithCollisionCheck(a, b)
                }
                processChildViews { handlerWithCollisionCheck(a, $0) }
            }
            for i in nilIndexes.reversed() {
                views.remove(at: i)
            }
        }
        
        private func processChildViews(handler: (UIView) -> Void) {
            for childNode in children.values {
                for view in childNode.views {
                    if let view = view.value {
                        handler(view)
                    }
                }
                childNode.processChildViews(handler: handler)
            }
        }
        
        private var parent: Node?
        private var children = [Child: Node]()
        private var views = [WeakHolder<UIView>]()
        private enum Child: UInt64 {
            case leftTop = 0
            case rightTop = 1
            case leftBottom = 2
            case rightBottom = 3
        }
        
        func remove(view: UIView) {
            guard let index = views.firstIndex(where: { $0.value == view }) else { return }
            views.remove(at: index)
        }
        
        func add(view: UIView, morton: MortonOrder, currentLevel: Int) -> Node {
            if morton.level == currentLevel {
                if views.contains(where: { $0.value == view }) { return self }
                views.append(WeakHolder(value: view))
                return self
            }
            let child = Child(rawValue: (morton.number >> (62 - currentLevel * 2)) & 3)!
            return children.getOrInit(for: child).add(view: view, morton: morton, currentLevel: currentLevel + 1)
        }
    }
}

extension Dictionary where Value == Tree.Node {
    mutating func getOrInit(for key: Key) -> Value {
        if let value = self[key] { return value }
        let value = Tree.Node()
        self[key] = value
        return value
    }
}

extension UIView {
    var rectInWindow: CGRect? {
        guard let window = window else { return nil }
        return convert(bounds, to: window)
    }
}

extension CGRect {
    func isCollision(to rect: CGRect, spacing: CGFloat) -> Bool {
        minX < rect.maxX + spacing && maxX + spacing > rect.minX && minY < rect.maxY + spacing && maxY + spacing > rect.minY
    }
}
