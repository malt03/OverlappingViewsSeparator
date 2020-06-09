//
//  Tree.swift
//  OverlappingViewsSeparator
//
//  Created by Koji Murata on 2020/06/09.
//

import UIKit

final class Tree {
    private var trees = [UIWindow: Node]()
    private var nodes = [Element: Node]()
    
    enum Element: Hashable {
        case flexible(UIView)
        case stuck(UIView)
        
        var view: UIView {
            switch self {
            case .flexible(let view): return view
            case .stuck(let view): return view
            }
        }
    }

    typealias ElementWithRect = (element: Element, rect: CGRect)

    func processCollisionCombination(spacing: CGFloat, handler: (ElementWithRect, ElementWithRect) -> Void) {
        for tree in trees.values {
            tree.processCollisionCombination(spacing: spacing, handler: handler)
        }
    }
    
    init<S1: Sequence, S2: Sequence>(views: S1, stuckViews: S2) where S1.Element == UIView, S2.Element == UIView {
        let flexible = AnySequence(views.lazy.map({ Element.flexible($0) }))
        let stuck = AnySequence(stuckViews.lazy.map({ Element.stuck($0) }))
        for element in [flexible, stuck].joined() {
            let view = element.view
            guard let window = view.window else { continue }
            let morton = view.morton(for: window)
            let root = trees.getOrInit(for: window)
            nodes[element] = root.add(element: element, morton: morton, currentLevel: 0)
        }
    }
    
    func update<S: Sequence>(views: S) where S.Element == UIView {
        for element in views.lazy.map({ Element.flexible($0) }) {
            let view = element.view
            guard let window = view.window else { continue }
            let morton = view.morton(for: window)
            let node = trees.getOrInit(for: window).add(element: element, morton: morton, currentLevel: 0)
            if nodes[element] !== node {
                nodes[element]?.remove(element: element)
                nodes[element] = node
            }
        }
    }
    
    final class Node {
        func processCollisionCombination(spacing: CGFloat, handler: (ElementWithRect, ElementWithRect) -> Void) {
            for childNode in children.values {
                childNode.processCollisionCombination(spacing: spacing, handler: handler)
            }

            if elements.isEmpty { return }
            
            func handlerWithCollisionCheck(_ a: Element, _ b: Element) {
                guard let aRect = a.view.rectInWindow, let bRect = b.view.rectInWindow else { return }
                if !aRect.isCollision(to: bRect, spacing: spacing) { return }
                handler((a, aRect), (b, bRect))
            }

            let elements = Array(self.elements)
            for i in 0..<elements.count {
                let a = elements[i]
                if a.view.isHidden { continue }
                for j in (i + 1)..<elements.count {
                    let b = elements[j]
                    if b.view.isHidden { continue }
                    handlerWithCollisionCheck(a, b)
                }
                processChildViews { handlerWithCollisionCheck(a, $0) }
            }
        }
        
        private func processChildViews(handler: (Element) -> Void) {
            for childNode in children.values {
                for element in childNode.elements {
                    if element.view.isHidden { continue }
                    handler(element)
                }
                childNode.processChildViews(handler: handler)
            }
        }
        
        private var parent: Node?
        private var children = [Child: Node]()
        private var elements = Set<Element>()
        private enum Child: UInt64 {
            case leftTop = 0
            case rightTop = 1
            case leftBottom = 2
            case rightBottom = 3
        }
        
        func remove(element: Element) {
            elements.remove(element)
        }
        
        func add(element: Element, morton: MortonOrder, currentLevel: Int) -> Node {
            if morton.level == currentLevel {
                elements.insert(element)
                return self
            }
            let child = Child(rawValue: (morton.number >> (62 - currentLevel * 2)) & 3)!
            return children.getOrInit(for: child).add(element: element, morton: morton, currentLevel: currentLevel + 1)
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
